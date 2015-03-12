% Grid interpolation constraints.
%
% U = grid_interp([sxc syc], [sxf syf])
%
% Consider a coarse 2D grid of size (sxc x syc) placed atop a fine 2D grid of
% size (sxf x syf) such that their outer borders align.  Treat grid cells as
% rectangular and require that sxc <= sxf and syc <= syf.  Let nc = sxc*syc
% and nf = sxf*syf be the total number of cells in the coarse and fine grids,
% respectively.
%
% This function returns a sparse matrix U whose columns represent linear
% matching constraints between signals on the coarse and fine grids.
% Specifically, U states that the coarse signal is a weighted average of the
% fine signal, where the weights derive according to area of grid cell overlap.
%
% Input:
%    [sxc syc] - dimensions of coarse grid
%    [sxf syf] - dimensions of fine grid
%
% Output:
%    U         - ((nc + nf) x nc) sparse constraint matrix
function U = grid_interp(size_coarse, size_fine)
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
   % compute step size on coarse grid per unit fine step
   step_x = sxc./sxf;
   step_y = syc./syf;
   % allocate storage for ids and weights of overlapping cells
   idf_mx    = repmat(1:nf, [4 1]);
   idc_mx    = zeros([4 nf]);
   weight_mx = zeros([4 nf]);
   % iterate over fine cells, placing them within overlapping coarse cells
   for indf = 1:nf
      % compute coordinate within fine grid
      xf = mod(indf - 1, sxf) + 1;
      yf = (indf - xf)./sxf + 1;
      % compute real-valued bounding position within fine grid
      xf_min = xf - 1;
      yf_min = yf - 1;
      xf_max = xf;
      yf_max = yf;
      % transform to real-valued bounding position within coarse grid
      xc_min = xf_min.*step_x;
      yc_min = yf_min.*step_y;
      xc_max = xf_max.*step_x;
      yc_max = yf_max.*step_y;
      % compute lower-left bounding position in coarse grid
      xc_ll = floor(xc_min);
      yc_ll = floor(yc_min);
      % get ids of coarse boxes covering fine box
      id_ll = yc_ll.*sxc + xc_ll + 1;
      id_lr = id_ll + 1;
      id_ul = id_ll + sxc;
      id_ur = id_ul + 1;
      % compute box weighting (check if within coarse grid bounds)
      w_ll = 1.0;
      w_lr = 1.0.*((xc_ll+1) < sxc);
      w_ul = 1.0.*((yc_ll+1) < syc);
      w_ur = w_lr.*w_ul;
      % compute box side overlap lengths within coarse grid
      o_x_left  = min(xc_max, xc_ll+1) - xc_min;
      o_x_right = max(xc_max - (xc_ll+1), 0);
      o_y_lower = min(yc_max, yc_ll+1) - yc_min;
      o_y_upper = max(yc_max - (yc_ll+1), 0);
      % compute box overlap areas within coarse grid
      o_ll = o_y_lower.*o_x_left;
      o_lr = o_y_lower.*o_x_right;
      o_ul = o_y_upper.*o_x_left;
      o_ur = o_y_upper.*o_x_right;
      % store ids of overlapping coarse cells
      idc_mx(1,indf) = id_ll;
      idc_mx(2,indf) = id_lr;
      idc_mx(3,indf) = id_ul;
      idc_mx(4,indf) = id_ur;
      % store weights of overlapping coarse cells
      weight_mx(1,indf) = w_ll.*o_ll;
      weight_mx(2,indf) = w_lr.*o_lr;
      weight_mx(3,indf) = w_ul.*o_ul;
      weight_mx(4,indf) = w_ur.*o_ur;
   end
   % find all cells with nonempty overlap
   inds = find(weight_mx);
   % assemble vector representation of lower (nf x nc) constraint matrix block
   ui_vec   = idf_mx(inds) + nc;
   uj_vec   = idc_mx(inds);
   uval_vec = weight_mx(inds);
   % assemble sparse constraint matrix
   U = sparse(ui_vec, uj_vec, uval_vec, nc + nf, nc);
   U = spdiags(-ones([nc 1]), 0, U);
end
