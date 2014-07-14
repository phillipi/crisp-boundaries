% extract edges from eigenvectors
function [pb pbos] = evecs_to_edges(evecs, weights)
   % get size
   [sx sy nscale nvec] = size(evecs);
   % gradient parameters
   hil = 0;
   deriv = 1;
   support = 3;
   sigma = 1;
   norient = 8;
   dtheta = pi/norient;
   ch_per = [4 3 2 1 8 7 6 5];
   % compute pixel gradients
   pbos = zeros([sx sy norient nscale]);
   for scale = 1:nscale
      for v = 1:nvec
         if (weights(v) > 0),
            vec = evecs(:,:,scale,v).*weights(v);
            for o = 1:norient,
               theta = dtheta*o;
               f = oeFilter_custom(sigma, support, theta, deriv, hil);
               pbos(:,:,ch_per(o),scale) = ...
                  pbos(:,:,ch_per(o),scale) + abs(applyFilter(f, vec));
            end
         end
      end
   end
   % mean over scales
   pb = mean(pbos,4);
   % take maximum over orientations
   pb = max(pb,[],3);
   % normalize
   %pb = pb./max(pb(:));
end
