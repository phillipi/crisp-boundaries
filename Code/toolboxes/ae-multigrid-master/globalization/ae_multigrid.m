% Multiscale Angular Embedding via progressive multigrid matrix approximation.
%
% opts = ae_multigrid('opts', m)
%
% Return default solver options for finding m eigenvectors.
%
% [evecs evals info] = ae_multigrid(C_arr, Theta_arr, U_arr, m, opts)
%
% Given a multilevel constrained Angular Embedding (AE) problem defined by an
% ordered set of AE subproblems, {(C, Theta, U)}, indexed by level, solve the
% full AE problem using progressive coarse-to-fine matrix approximation.
%
% The subproblems must have the following properties:
%
% (1) Pairwise generalized affinity relationships exist only between elements
%     at the same subproblem level (no cross-level affinity connections).
%
% (2) Constraints may be arbitrary (within and/or cross-level), but must be
%     organized into incremental constraint sets added at each level.
%
% (3) Each element in a finer level must be tied, directly or indirectly,
%     through constraints, to element(s) in a coarser level.  This property
%     guarantees that each incremental constraint matrix also defines a
%     coarse-to-fine interpolation.
%
% C and Theta specify affinity relationships between elements incrementally
% appearing at each level.  Let ne(s) denote the number of additional elements
% joining in subproblem s and nu(s) the number of additional constraints.  The
% input sparse matrices have the following structure:
%
%    C{s}      (ne(s) x ne(s))        symmetric confidence matrix
%    Theta{s}  (ne(s) x ne(s))        skew-symmetric ordering matrix (or [])
%    U{s}      (sum(ne(1:s)) x nu(s)) constraint matrix
%
% There are sum(ne) total elements to embed and sum(nu) total constraints.
%
% U{1} should contain all constraints involving only the first ne(1) elements.
% U{2} should contain all constraints involving only the first (ne(1) + ne(2))
% elements, that were not already listed in U{1}, and so on.  Excepting U{1},
% each U{s} should be nonempty as the subproblems are connected only by
% constraints.
%
% Note that C{s} should be nonempty for all s.  Setting Theta{s} = [] denotes
% that only pure affinity relationships exist for that level (equivalently,
% Theta{s}(x,y) = 0).  If Theta{s} = [] for all s, the AE problem reduces to
% Normalized Cuts and the returned eigenvectors will be real-valued.
%
% Input:
%    C_arr          - cell array of symmetric confidence matrices
%    Theta_arr      - cell array of skew-symmetric ordering matrices
%    U_arr          - cell array of constraint matrices
%    m              - # of eigenvectors desired      (default: min(min(ne),16))
%    opts.          - multigrid eigensolver execution options
%       nl             - # of basis vectors for approximation   (default: 2.*m)
%       nr             - # of basis vectors for error testing      (default: m)
%       k              - initial # of iterations at each level     (default: 1)
%       k_max          - max # of iterations at each level       (default: inf)
%       k_rate         - rate at which to grow k if not converged  (default: 2)
%       tol_ichol      - tolerance for incomplete Cholesky    (default: 2.^-20)
%       tol_err        - tolerance for solver at each level   (default: 10.^-2)
%       reorth_flag    - reorthonormalize within eigensolver?  (default: false)
%       transform_flag - use constraints to transform weights? (default: false)
%       disp           - show status display?                  (default: false)
%       use_ispc       - use ispc for fast sparse matrix ops?  (default: false)
%
% Output:
%    evecs          - (sum(ne) x m) eigenvectors
%    evals          - (m x 1)       eigenvalues
%    info.          - solver debugging data and statistics
%       A              - (sum(ne) x (nl+nr)) internal matrix approximation
%       V              - (nl x nl) eigenvectors of transformed small problem
%       hist_lvl       - history of active level at each refinement step
%       hist_k         - history of iterations run at each refinement step
%       hist_err       - history of error estimates after each refinement step
%       k_total        - total # of refinement iterations run per level
%       work_refine    - total refinement work per level (in refine units)
%       work_test      - total test work per level (in test units)
%       time_extract   - time to extract problem representation (cputime secs)
%       time_fold      - time to assemble subproblem matrices (cputime secs)
%       time_init      - time to initialize matrix approximation (cputime secs)
%       time_interp    - interpolation time per level (cputime secs)
%       time_refine    - refinement time per level (cputime secs)
%       time_test      - error testing time per level (cputime secs)
%       time_eigs      - time to solve small eigenproblem (cputime secs)
%       time_recover   - time to recover large eigenvectors (cputime secs)
%       time_total     - grand total time (cputime secs)
function [evecs evals info] = ae_multigrid(C_arr, Theta_arr, U_arr, m, opts)
   % check whether requesting default options
   if (ischar(C_arr) && strcmp(C_arr,'opts'))
      % get number of eigenvectors for which to generate options
      if (nargin < 2), m = 16; else, m = Theta_arr; end
      % default options
      opts_def = struct( ...
         'nl',             2.*m, ...
         'nr',             m, ...
         'k',              1, ...
         'k_max',          inf, ...
         'k_rate',         2, ...
         'tol_ichol',      2.^-20, ...
         'tol_err',        10.^-2, ...
         'reorth_flag',    false, ...
         'transform_flag', false, ...
         'disp',           false, ...
         'use_ispc',       false ...
      );
      % return default options
      evecs = opts_def;
      return;
   end
   % start time for grand total time
   t_start = cputime;
   % extract vector representation of subproblems
   t = cputime;
   ae_prob = ae_subproblem_extract(C_arr, Theta_arr, U_arr);
   % set default arguments
   if ((nargin < 4) || isempty(m)), m = min(min(ae_prob.ne_cum),16); end
   if ((nargin < 5) || isempty(opts)), opts = []; end
   % set any missing options to defaults
   opts = set_defaults(opts, ae_multigrid('opts', m));
   % get number of levels
   nlvls = numel(ae_prob.ne_arr);
   % initialize solver debugging data and statistics
   info = struct( ...
      'A',            [], ...
      'V',            [], ...
      'hist_lvl',     [], ...
      'hist_k',       [], ...
      'hist_err',     [], ...
      'k_total',      zeros([1 nlvls]), ...
      'work_refine',  zeros([1 nlvls]), ...
      'work_test',    zeros([1 nlvls]), ...
      'time_extract', (cputime - t), ...
      'time_fold',    0, ...
      'time_init',    0, ...
      'time_interp',  zeros([1 nlvls]), ...
      'time_refine',  zeros([1 nlvls]), ...
      'time_test',    zeros([1 nlvls]), ...
      'time_eigs',    0, ...
      'time_recover', 0, ...
      'time_total',   0 ...
   );
   % check that problem is nonempty
   if (nlvls == 0)
      evecs = zeros([0 0]);
      evals = zeros([0 1]);
      return;
   end
   % assemble matrices needed by solver
   t = cputime;
   ae_mx = ae_subproblem_fold( ...
      ae_prob, opts.tol_ichol, opts.transform_flag ...
   );
   info.time_fold = cputime - t;
   % initialize k (expand to be indexed by subproblem level if needed)
   k      = reshape(max(opts.k, 0),      [1 numel(opts.k)]);
   k_max  = reshape(max(opts.k_max, 0),  [1 numel(opts.k_max)]);
   k_rate = reshape(max(opts.k_rate, 0), [1 numel(opts.k_rate)]);
   if (numel(k) == 1),      k      = repmat(k,      [1 nlvls]); end
   if (numel(k_max) == 1),  k_max  = repmat(k_max,  [1 nlvls]); end
   if (numel(k_rate) == 1), k_rate = repmat(k_rate, [1 nlvls]); end
   % enforce user-specified limits on k
   k = min(k, k_max);
   % check that work is being done on at least one subproblem
   if (max(k) == 0), error('invalid setting for opts.k or opts.k_max'); end
   % check that work is being done on the finest subproblem
   if (k(nlvls) == 0)
      warning('skipping finest subproblem - solution will be interpolated');
   end
   % initialize per-level error tolerances
   tol_err = reshape(opts.tol_err, [1 numel(opts.tol_err)]);
   if (numel(tol_err) == 1), tol_err = repmat(tol_err, [1 nlvls]); end
   % progressive coarse-to-fine matrix approximation
   A = [];
   for s = 1:nlvls
      % lookup diffusion and projection matrices for current subproblem
      P     = ae_mx.P_arr{s};
      U_bar = ae_mx.U_arr{s};
      R     = ae_mx.R_arr{s};
      % check whether current subproblem is constrained
      if (isempty(U_bar))
         % eigensolver matrix application function is diffusion
         if (opts.use_ispc)
            P_csr = sp2csr(P);
            f = @(z) ae_diffuse_ispc(P_csr, z);
         else
            f = @(z) ae_diffuse(P, z);
         end
      else
         % eigensolver matrix application function is diffusion + projection
         if (opts.use_ispc)
            P_csr      = sp2csr(P);
            U_bar_csr  = sp2csr(U_bar);
            U_barp_csr = sp2csr(U_bar');
            f = @(z) ae_diffuse_project_ispc(P_csr, U_bar_csr, U_barp_csr, R, z);
         else
            f = @(z) ae_diffuse_project(P, U_bar, R, z);
         end
      end
      % get starting number of iterations to run at current level
      k_curr = k(s);
      % initialize matrix approximation
      if ((isempty(A)) && (k_curr > 0))
         % initialize with Gaussian random basis
         t = cputime;
         A = mx_approx_init( ...
            f, ae_prob.ne_cum(s), opts.nl, opts.nr, ae_prob.is_complex ...
         );
         info.time_init = cputime - t;
      elseif ((ae_prob.ne_cum(s) > size(A,1)) && (~isempty(A)))
         % lookup interpolation matrices for current subproblem
         Ua = ae_mx.Ua_arr{s};
         Ub = ae_mx.Ub_arr{s};
         Rb = ae_mx.Rb_arr{s};
         % interpolate from coarser approximation
         t = cputime;
         A_ext = Ub * (Rb \ (Rb' \ (-Ua' * A)));
         A = [A; A_ext];
         info.time_interp(s) = cputime - t;
      end
      % refine matrix approximation until convergence
      is_converged = false;
      while ((~is_converged) && (0 < k_curr) && (info.k_total(s) < k_max(s)))
         % compute number of refinement iterations to run
         k_run = min(ceil(k_curr), k_max(s) - info.k_total(s));
         % refine matrix approximation
         t = cputime;
         [A Al_prev] = mx_approx_refine( ...
            f, f, A, opts.nl, opts.nr, k_run, opts.reorth_flag ...
         );
         info.time_refine(s) = info.time_refine(s) + (cputime - t);
         info.work_refine(s) = info.work_refine(s) + k_run.*ae_prob.ne_cum(s);
         % test convergence
         t = cputime;
         Ar = A(:, (opts.nl+1):(opts.nl+opts.nr));
         err = mx_approx_test(Al_prev, Ar);
         is_converged = (err < tol_err(s));
         info.time_test(s) = info.time_test(s) + (cputime - t);
         info.work_test(s) = info.work_test(s) + ae_prob.ne_cum(s);
         % update history
         info.hist_lvl(end+1) = s;
         info.hist_k(end+1)   = k_run;
         info.hist_err(end+1) = err;
         % display status
         if (opts.disp)
            disp([ ...
               'level: '   num2str(s)     '  ' ...
               'k: '       num2str(k_run) '  ' ...
               'err: '     num2str(err)   '  ' ...
               'cputime: ' num2str(cputime-t_start) ' sec' ...
            ]);
         end
         % update k
         info.k_total(s) = info.k_total(s) + k_run;
         k_curr = k_curr.*k_rate(s);
      end
   end
   % solve small eigenproblem directly
   t = cputime;
   Al = A(:, 1:(opts.nl));
   B = Al' * f(Al);
   [V evals] = eigs( ...
      B, m, 'lm', ...
      struct('issym', 0, 'isreal', ~ae_prob.is_complex, 'disp', 0) ...
   );
   info.time_eigs = cputime - t;
   % store A, V
   info.A = A;
   info.V = V;
   % start timer on recovery of large eigenvectors
   t = cputime;
   % recover eigenvectors of large problem
   evecs = Al * V;
   % transform eigenvectors back to original domain
   d_sqrt_inv = reshape(1./sqrt(ae_prob.dval_vec + eps), [ae_prob.ne 1]);
   evecs = repmat(d_sqrt_inv, [1 m]).*evecs;
   evals = 1 - diag(evals);
   % sort by eigenvalue
   [evals inds] = sort(evals);
   evecs = evecs(:, inds);
   % record time for recovering large eigenvectors
   info.time_recover = cputime - t;
   % record grand total time
   info.time_total = cputime - t_start;
end

% Apply AE diffusion operation to a set of column vectors.
%
% Input:
%    P     - (ne x ne) sparse diffusion matrix (D^(-1/2)*W*D^(-1/2))
%    z     - (ne x c)  matrix of c column vectors
%
% Output:
%    y = P * z
function y = ae_diffuse(P, z)
   y = P * z;
end

function y = ae_diffuse_ispc(P, z)
   y = spmul(P, z);
end

% Apply AE diffusion and projection operation to a set of column vectors.
%
% Input:
%    P     - (ne x ne) sparse diffusion matrix (D^(-1/2)*W*D^(-1/2))
%    U_bar - (ne x nu) sparse normalized constraint matrix (D^(-1/2)*U)
%    R     - (nu x nu) sparse incomplete Cholesky factorization of (U'*U)
%    z     - (ne x c)  matrix of c column vectors
%
% Output:
%    y = (I - U_bar*(R \ R' \ U_bar')) * P * (I - U_bar*(R \ R' \ U_bar')) * z
function y = ae_diffuse_project(P, U_bar, R, z)
   y = z - U_bar * (R \ (R' \ (U_bar' * z)));
   z = P * y;
   y = z - U_bar * (R \ (R' \ (U_bar' * z)));
end

function y = ae_diffuse_project_ispc(P, U_bar, U_barp, R, z)
   y = z - spmul(U_bar, (R \ (R' \ (spmul(U_barp, z)))));
   z = spmul(P, y);
   y = z - spmul(U_bar, (R \ (R' \ (spmul(U_barp, z)))));
end
