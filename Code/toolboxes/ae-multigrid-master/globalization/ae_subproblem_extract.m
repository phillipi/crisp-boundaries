% Subproblem extraction for multilevel constrained Angular Embedding.
%
% ae_prob = ae_subproblem_extract(C_arr, Theta_arr, U_arr)
%
% Extract and return vector representations of the sparse confidence, ordering,
% and constraint matrices comprising the multilevel Angular Embedding (AE)
% problem defined by the ordered set of linked subproblems {(C, Theta, U)}.
%
% See also ae_multigrid, ae_subproblem_fold.
%
% Input:
%    C_arr         - cell array of symmetric confidence matrices
%    Theta_arr     - cell array of skew-symmetric ordering matrices
%    U_arr         - cell array of constraint matrices
%
% Output:
%    ae_prob.      - vector representation of multilevel AE problem
%       ne            - total # of elements in problem
%       ne_arr        - # of elements in each level
%       ne_cum        - # of elements in each pyramid
%       nu            - total # of constraints in problem
%       nu_arr        - # of constraints in each level
%       nu_cum        - # of constraints in each pyramid
%       w_len         - total # of nonzero entries in all W matrices
%       w_size        - # of nonzero entries in W matrix for each level
%       w_size_cum    - # of nonzero entries in W matrix for each pyramid
%       u_len         - total # of nonzero entires in all U matrices
%       u_size        - # of nonzero entries in U matrix for each level
%       u_size_cum    - # of nonzero entries in U matrix for each pyramid
%       wi_vec        - column indices of nonzero W (or C) matrix entries
%       wj_vec        - row indicies of nonzero W (or C) matrix entries
%       cval_vec      - C matrix values at corresponding (wi,wj) indices
%       tval_vec      - Theta matrix values at corresponding (wi,wj) indices
%       ui_vec        - column indices of nonzero U matrix entries
%       uj_vec        - row indices of nonzero U matrix entries
%       uval_vec      - U matrix values at corresponding (ui,uj) indices
%       dval_vec      - D matrix diagonal values (vector of length ne)
%       is_complex    - flag indicating whether embedding is complex-valued
function ae_prob = ae_subproblem_extract(C_arr, Theta_arr, U_arr)
   % get number of levels
   nlvls = numel(C_arr);
   % check for correct input size
   if ((nlvls ~= numel(Theta_arr)) || (nlvls ~= numel(U_arr)))
      error('invalid multilevel Angular Embedding problem specification');
   end
   % get subproblem sizes
   ne_arr = zeros([nlvls 1]); % number of elements at each level
   nu_arr = zeros([nlvls 1]); % number of constraints at each level
   w_size = zeros([nlvls 1]); % number of nonzero entries in W matrices
   u_size = zeros([nlvls 1]); % number of nonzero entries in U matrices
   for s = 1:nlvls
      ne_arr(s) = size(C_arr{s},1);
      nu_arr(s) = size(U_arr{s},2);
      w_size(s) = nnz(C_arr{s});
      u_size(s) = nnz(U_arr{s});
   end
   % compute cumulative and total problem sizes
   ne_cum = cumsum(ne_arr);
   nu_cum = cumsum(nu_arr);
   ne = sum(ne_arr);
   nu = sum(nu_arr);
   % compute cumulative and total matrix sizes
   w_size_cum = cumsum(w_size);
   u_size_cum = cumsum(u_size);
   w_len = sum(w_size);
   u_len = sum(u_size);
   % allocate vector representation of sparse matrices
   wi_vec   = zeros([w_len 1]);
   wj_vec   = zeros([w_len 1]);
   cval_vec = zeros([w_len 1]);
   tval_vec = zeros([w_len 1]);
   ui_vec   = zeros([u_len 1]);
   uj_vec   = zeros([u_len 1]);
   uval_vec = zeros([u_len 1]);
   % allocate vector representation of diagonal degree matrix
   dval_vec = zeros([ne 1]);
   % extract sparse matrices into vector representations
   ne_pos = 1; % position within elements
   nu_pos = 1; % position within constraints
   w_pos  = 1; % position within affinity matrix entries
   u_pos  = 1; % position within constraint matrix entries
   for s = 1:nlvls
      % retrieve current level subproblem
      C     = C_arr{s};
      Theta = Theta_arr{s};
      U     = U_arr{s};
      % extract confidence matrix
      [ci cj cval] = find(C);
      wi_vec(w_pos:w_size_cum(s))   = ci + (ne_pos-1);
      wj_vec(w_pos:w_size_cum(s))   = cj + (ne_pos-1);
      cval_vec(w_pos:w_size_cum(s)) = cval;
      % compute confidence degree matrix
      dval_vec(ne_pos:ne_cum(s)) = sum(C,2);
      % compute indices into ordering matrix
      inds = sub2ind([ne_arr(s) ne_arr(s)], ci, cj);
      % extract ordering matrix
      if (~isempty(Theta))
         tval = full(Theta(inds));
      else
         tval = zeros(size(cval));
      end
      tval_vec(w_pos:w_size_cum(s)) = tval;
      % extract constraint matrix
      [ui uj uval] = find(U);
      ui_vec(u_pos:u_size_cum(s))   = ui;  % no increment on element index
      uj_vec(u_pos:u_size_cum(s))   = uj + (nu_pos-1);
      uval_vec(u_pos:u_size_cum(s)) = uval;
      % increment position in element and constraint block matrices
      ne_pos = ne_cum(s) + 1;
      nu_pos = nu_cum(s) + 1;
      % increment position in vector representation
      w_pos = w_size_cum(s) + 1;
      u_pos = u_size_cum(s) + 1;
   end
   % determine whether embedding is real- or complex-valued
   is_complex = any(tval_vec);
   % pack problem data structure
   ae_prob = struct( ...
      'ne',         ne, ...
      'ne_arr',     ne_arr, ...
      'ne_cum',     ne_cum, ...
      'nu',         nu, ...
      'nu_arr',     nu_arr, ...
      'nu_cum',     nu_cum, ...
      'w_len',      w_len, ...
      'w_size',     w_size, ...
      'w_size_cum', w_size_cum, ...
      'u_len',      u_len, ...
      'u_size',     u_size, ...
      'u_size_cum', u_size_cum, ...
      'wi_vec',     wi_vec, ...
      'wj_vec',     wj_vec, ...
      'cval_vec',   cval_vec, ...
      'tval_vec',   tval_vec, ...
      'ui_vec',     ui_vec, ...
      'uj_vec',     uj_vec, ...
      'uval_vec',   uval_vec, ...
      'dval_vec',   dval_vec, ...
      'is_complex', is_complex ...
   );
end
