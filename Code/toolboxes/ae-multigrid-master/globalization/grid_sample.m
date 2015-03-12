% Bilinear sampling on a 2D grid.
%
% S = grid_sample([sxc syc], [sxf syf])
%
% Consider a coarse 2D grid of size (sxc x syc) placed atop a fine 2D grid of
% size (sxf x syf) such that their outer borders align.  Treat grid cells as
% rectangular and require that sxc <= sxf and syc <= syf.  Let nc = sxc*syc
% and nf = sxf*syf be the total number of cells in the coarse and fine grids,
% respectively.
%
% This function returns a sparse matrix S that samples a signal on the coarse
% grid from a signal on the fine grid.  Multiplication by S is equivalent to
% sampling using bilinear interpolation.
%
% Input:
%    [sxc syc] - dimensions of coarse grid
%    [sxf syf] - dimensions of fine grid
%
% Output:
%    S         - (nc x nf) sparse matrix for bilinear sampling
function S = grid_sample(size_coarse, size_fine)
   % extract coarse and fine grid sizes
   sxc = size_coarse(1);
   syc = size_coarse(2);
   sxf = size_fine(1);
   syf = size_fine(2);
   % check grid size requirements
   if ((sxc > sxf) || (syc > syf))
      error('dimensions of fine grid must be >= dimensions of coarse grid');
   end
   % compute number of elements in each grid
   nc = sxc.*syc;
   nf = sxf.*syf;
   % compute step size on fine grid per unit coarse step
   step_x = sxf./sxc;
   step_y = syf./syc;
   % allocate storage for ids and weights of points in bilinear sampling
   idc_mx    = repmat(1:nc, [4 1]);
   idf_mx    = zeros([4 nc]);
   weight_mx = zeros([4 nf]);
   % iterate over coarse cells, computing weights for bilinear sampling
   for indc = 1:nc
      % compute coordinate within coarse grid
      xc = mod(indc - 1, sxc) + 1;
      yc = (indc - xc)./sxc + 1;
      % compute real-valued center position within coarse grid
      xc_cntr = xc - 0.5;
      yc_cntr = yc - 0.5;
      % compute real-valued center position within fine grid
      xf_cntr = xc_cntr.*step_x;
      yf_cntr = yc_cntr.*step_y;
      % transform center to sample coordinates
      x = xf_cntr + 0.5;
      y = yf_cntr + 0.5;
      % compute bounding box in sample coordinates
      x_min = floor(x);
      y_min = floor(y);
      x_max = x_min + 1;
      y_max = y_min + 1;
      % get ids of grid sample entries
      id_ll = (y_min - 1).*sxf + x_min;
      id_lr = id_ll + 1;
      id_ul = id_ll + sxf;
      id_ur = id_ul + 1;
      % compute distances from sample points
      dx_left  = x - x_min;
      dx_right = x_max - x;
      dy_lower = y - y_min;
      dy_upper = y_max - y;
      % compute bilinear sampling weights
      w_ll = dy_upper.*dx_right;
      w_lr = dy_upper.*dx_left;
      w_ul = dy_lower.*dx_right;
      w_ur = dy_lower.*dx_left;
      % store ids of grid sample points
      idf_mx(1,indc) = id_ll;
      idf_mx(2,indc) = id_lr;
      idf_mx(3,indc) = id_ul;
      idf_mx(4,indc) = id_ur;
      % store bilinear sampling weights
      weight_mx(1,indc) = w_ll;
      weight_mx(2,indc) = w_lr;
      weight_mx(3,indc) = w_ul;
      weight_mx(4,indc) = w_ur;
   end
   % find all sampling points with nonzero weight
   inds = find(weight_mx);
   % assemble vector representation of sparse matrix for bilinear sampling
   si_vec   = idc_mx(inds);
   sj_vec   = idf_mx(inds);
   sval_vec = weight_mx(inds);
   % assemble sparse matrix for bilinear sampling
   S = sparse(si_vec, sj_vec, sval_vec, nc, nf);
end
