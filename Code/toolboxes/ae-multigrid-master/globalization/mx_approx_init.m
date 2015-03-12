% Matrix approximation via randomized subspace iteration.
%
% A = mx_approx_init(f, ne, nl, nr, is_complex)
%
% Given an (ne x ne) matrix M, generate an initial guess for an (ne x (nl+nr))
% matrix A whose leftmost nl columns approximate the range of M and whose
% rightmost nr columns serve as a basis for testing convergence.
%
% Initialization proceeds by drawing an (ne x (nl+nr)) Gaussian random matrix
% Omega, setting A = M*Omega, and separately orthonormalizing the leftmost nl
% and rightmost nr columns of A.
%
% Rather than explicitly specifying M, the user must specify a function f that
% applies M to a matrix X.  That is: f(X) = M*X.  This allows the user to take
% advantage of an efficient factorization of M, should one exist.  To use M
% directly, one can set: f = @(X) M*X;
%
% Input:
%    f          - function for computing M*X given X (eg @(X) M*X)
%    ne         - number of elements in single basis vector (= size(M,1))
%    nl         - desired number of basis vectors for approximation
%    nr         - desired number of basis vectors for convergence testing
%    is_complex - is M complex-valued? (default: false)
%
% Output:
%    A          - (ne x (nl+nr)) approximation (complex iff M is complex)
function A = mx_approx_init(f, ne, nl, nr, is_complex)
   % default arguments
   if (nargin < 5), is_complex = false; end
   % sample gaussian random matrix
   if (is_complex)
      Omega = complex(randn([ne (nl+nr)]), randn([ne (nl+nr)]));
   else
      Omega = randn([ne (nl+nr)]);
   end
   % apply M to Omega and orthonormalize
   A = mx_approx_reorth(f(Omega), nl, nr);
end
