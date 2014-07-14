% Gaussian smoothing on a 2D grid.
%
% Y = grid_smooth(X, sigma)
%
% Smooth the 2D (or stack of 2D) signal(s) X with a 2D Gaussian kernel of
% standard deviation sigma in both directions.  Return a smoothed signal Y
% of the same size as X.
%
% Input:
%    X     - 2D signal or stack of 2D signals
%    sigma - standard deviation of Gaussian smoothing kernel
%
% Output
%    Y     - smoothed signal
function Y = grid_smooth(X, sigma)
   % get signal size
   [sx sy sz] = size(X);
   % create 1D smoothing kernel
   d = (-ceil(3.*sigma)):1:(ceil(3.*sigma));
   g = exp(-d.*d./(2.*sigma.*sigma));
   g = g./sum(g);
   % smooth each 2D signal in stack
   Y = zeros([sx sy sz]);
   for n = 1:sz
      Y(:,:,n) = conv2(conv2(X(:,:,n), g, 'same'), g.', 'same');
   end
end
