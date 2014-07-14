% Resample an image so that its power-of-two pyramid has integer grid sizes
% down to the specified minimum grid size.
%
% [im bounds] = multiscale_resize(im, scale, pad, [xmin ymin])
%
% Input:
%    im            - image
%    scale         - upsampling factor                   (default: 1)
%    pad           - minimum border padding              (default: 0)
%    [xmin ymin]   - minimum grid size in image pyramid  (default: [50 50])
%
% Output:
%    im            - resampled and padded image
%    bounds        - coordinate bounds for removing padding
function [im bounds] = multiscale_resize(im, scale, pad, sz_min)
   % default arguments
   if (nargin < 2), scale = 1; end
   if (nargin < 3), pad = 0; end
   if (nargin < 4), sz_min = [50 50]; end
   % get image size after upsampling
   sxu = ceil(size(im,1) .* scale);
   syu = ceil(size(im,2) .* scale);
   % get target image size (after upsampling and padding)
   sx = sxu + 2.*pad;
   sy = syu + 2.*pad;
   % determine number of levels in image pyramid
   nlvlx = floor(log(sx./sz_min(1)) ./ log(2));
   nlvly = floor(log(sy./sz_min(2)) ./ log(2));
   nlvl = min(nlvlx, nlvly);
   % compute pyramid scale change factor
   pscale = 2.^(nlvl);
   % compute size of smallest pyramid level
   xmin = ceil(sx ./ pscale);
   ymin = ceil(sy ./ pscale);
   % compute required image of largest pyramid level
   xmax = xmin .* pscale;
   ymax = ymin .* pscale;
   % upsample image
   im = imresize(im, [sxu syu], 'bilinear');
   % compute border to mirror
   xleft  = floor((xmax - sxu)./2);
   yleft  = floor((ymax - syu)./2);
   xright = xmax - sxu - xleft;
   yright = ymax - syu - yleft;
   % mirror image border
   im = cat(1, im(xleft:-1:1,:,:), im, im(sxu:-1:(sxu-xright+1),:,:));
   im = cat(2, im(:,yleft:-1:1,:), im, im(:,syu:-1:(syu-yright+1),:));
   % compute bounds for grabbing original image
   bounds = [1 1 sxu syu] + [xleft yleft xleft yleft];
end
