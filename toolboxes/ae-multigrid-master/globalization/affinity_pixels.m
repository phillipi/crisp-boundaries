% Compute affinity between pixels using the intervening contour cue.
%
% [i j c theta] = affinity_pixels(mpb, rho)
%
% Input:
%    mpb    - multiscale probability of boundary
%             (stored in matrix the same size as the image)
%    rho    - affinity scale parameter
%
% Output:
%    (i,j)  - indices into sparse matrix of pixel-pixel relationships
%    c      - confidence on pairwise relationships
%    theta  - relative pairwise ordering relationships
%
% The returned indices range over the pixel nodes, starting at 1 for the first
% pixel node.
function [i j c theta] = affinity_pixels(mpb, rho)
   % check that rho matches hardcoded value in buildW
   if (rho ~= 0.1), error('rho must be set to 0.1 to match buildW'); end
   % get image size
   [sx sy] = size(mpb);
   % assemble lattice for intervening contour cue computation
   l{1} = zeros(size(mpb, 1) + 1, size(mpb, 2));
   l{1}(2:end, :) = mpb;
   l{2} = zeros(size(mpb, 1), size(mpb, 2) + 1);
   l{2}(:, 2:end) = mpb;
   % build affinity matrix
   [i j c] = buildW(l{1},l{2});
   % flip index order to match matlab indexing
   [yi xi] = ind2sub([sy sx],i);
   [yj xj] = ind2sub([sy sx],j);
   i = sub2ind([sx sy],xi,yi);
   j = sub2ind([sx sy],xj,yj);
   % set relative angular separation to zero
   theta = zeros(size(c));
end
