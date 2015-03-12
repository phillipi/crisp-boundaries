% Matrix approximation via randomized subspace iteration.
%
% [err E] = mx_approx_test(Al, Ar)
%
% Given an (ne x nl) orthonormal matrix Al and an (ne x nr) matrix Ar, compute
% the (ne x nr) error matrix E for using the columns of Al as a basis for
% reconstructing Ar.  Also compute an error, err, as the maximum magnitude of
% any vector in the set of nr error vectors appearing in the columns of E.
%
% Input:
%    Al  - (ne x nl) basis matrix
%    Ar  - (ne x nr) test matrix
%
% Output:
%    err - approximation error bound
%    E   - (ne x nr) error matrix
function [err E] = mx_approx_test(Al, Ar)
   % compute error matrix
   E = Ar - Al * (Al' * Ar);
   % compute error bound
   err = max(sqrt(sum(E.*E, 1)));
end
