% Matrix approximation via randomized subspace iteration.
%
% [A Al_prev] = mx_approx_refine(f, g, A, nl, nr, k, reorth_flag)
%
% Given some guess A for an (ne x (nl+nr)) matrix whose leftmost nl columns
% approximate the range of an (ne x ne) matrix M, refine the approximation
% through alternating application of M' and M.  The rightmost nr columns of A
% are treated as a separate approximate basis, intended for use in convergence
% testing, and are similarly refined.
%
% The leftmost nl and rightmost nr columns of A are updated by orthonormalizing
% the corresponding columns of ((M*M')^k)*A using QR-factorization.
%
% Rather than explicitly specifying M, the user must specify functions f and g
% that apply M and M', respectively, to a matrix X.  That is:
%    f(X) = M*X
%    g(X) = M'*X
% Specifying these functions allows the user to take advantage of efficient
% factorizations of M, should they exist.  To use M directly, one can set:
%    f = @(X) M*X;
%    g = @(X) M'*X;
%
% Input:
%    f           - function for computing M*X given X  (eg @(X) M*X)
%    g           - function for computing M'*X given X (eg @(X) M'*X)
%    A           - initial (ne x (nl+nr)) approximation matrix
%    nl          - number of basis vectors for approximation
%    nr          - number of basis vectors for convergence testing
%    k           - number of iterations to run
%    reorth_flag - reorthonormalize on each intermediate step? (default: false)
%
% Output:
%    A           - updated (ne x (nl+nr)) approximation matrix
%    Al_prev     - (ne x nl) orthonomal basis just prior to the final update
function [A Al_prev] = mx_approx_refine(f, g, A, nl, nr, k, reorth_flag)
   % default arguments
   if (nargin < 7), reorth_flag = false; end
   % check whether performing intermediate reorthonormalization
   if (reorth_flag)
      % alternate application of M' and M
      for j = 1:(k-1)
         % apply M' and reorthonormalize
         A = mx_approx_reorth(g(A), nl, nr);
         % apply M and reorthonormalize
         A = mx_approx_reorth(f(A), nl, nr);
      end
      % grab left basis prior to final update
      Al_prev = A(:, 1:nl);
      % orthonormalize left basis if not already done
      if (k == 1), [Al_prev Rl] = qr(Al_prev, 0); end
      % final update - apply M' and reorthonormalize
      A = mx_approx_reorth(g(A), nl, nr);
      % final update - apply M and reorthonormalize
      A = mx_approx_reorth(f(A), nl, nr);
   else
      % alternate application of M' and M
      for j = 1:(k-1)
         A = f(g(A));
      end
      % grab left basis prior to final update
      Al_prev = A(:, 1:nl);
      % orthonormalize left basis
      [Al_prev Rl] = qr(Al_prev, 0);
      % final update - apply M' and M
      A = f(g(A));
      % reorthonormalize
      A = mx_approx_reorth(A, nl, nr);
   end
end
