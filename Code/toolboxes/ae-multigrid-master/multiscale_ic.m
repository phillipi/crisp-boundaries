% Multiscale constrained intervening contour affinities.
function [C_arr Theta_arr U_arr] = multiscale_ic(pb_arr, rho)
   % default arguments
   if (nargin < 2), rho = 0.1; end
   % initialize
   nlvls     = numel(pb_arr);
   C_arr     = cell([1 nlvls]);
   Theta_arr = cell([1 nlvls]);
   U_arr     = cell([1 nlvls]);
   % flip pb ordering to be coarse to fine
   pb_arr = pb_arr(end:-1:1);
   % get number of elements at each level
   ne = zeros([1 nlvls]);
   for n = 1:nlvls
      ne(n) = prod(size(pb_arr{n}));
   end
   ne_cum = cumsum(ne);
   % compute affinities
   for n = 1:nlvls
      % compute affinity matrix
      [wi wj wval] = affinity_pixels(pb_arr{n}, rho);
      C = sparse(wi, wj, wval, ne(n), ne(n));
      % compute cross-level constraint matrix
      U = [];
      if (n > 1)
         % compute constraint matrix
         sz_prev = size(pb_arr{n-1});
         sz_curr = size(pb_arr{n});
         U = grid_interp(sz_prev, sz_curr);
         % adjust constraint matrix indices
         ne_offset = ne_cum(n-1) - ne(n-1);
         [ui uj uval] = find(U);
         U = sparse(ui + ne_offset, uj, uval, ne_cum(n), ne(n-1));
      end
      % store
      C_arr{n}     = C;
      Theta_arr{n} = [];
      U_arr{n}     = U;
   end
end
