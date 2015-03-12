% Matrix approximation via randomized subspace iteration.
%
% A = mx_approx_reorth(A, nl, nr)
%
% Reorthonormalize the bases in the leftmost nl and rightmost nr columns of A.
%
% Input:
%    A  - initial (ne x (nl+nr)) approximation matrix
%    nl - number of basis vectors in left columns
%    nr - number of basis vectors in right columns
%
% Output:
%    A  - updated (ne x (nl+nr)) approximation matrix
function A = mx_approx_reorth(A, nl, nr)
   % grab leftmost nl and rightmost nr columns
   Al = A(:, 1:nl);
   Ar = A(:, (nl+1):(nl+nr));
   % orthonormalize using QR-factorization
   [Al Rl] = qr(Al, 0);
   [Ar Rr] = qr(Ar, 0);
   % concatenate
   A = [Al Ar];
end
