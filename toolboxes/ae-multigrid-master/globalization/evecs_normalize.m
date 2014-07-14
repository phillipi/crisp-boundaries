% Normalize each eigenvector by scaling by the mean distance of its entries
% from the origin.
%
% evecs = normalize_evecs(evecs)
%
% Input:
%    evecs - ne x nv matrix with eigenvectors in columns
%
% Output:
%    evecs - normalized eigenvectors (ne x nv matrix)
function evecs = normalize_evecs(evecs)
   [ne nv] = size(evecs);
   for n = 1:nv
      a = abs(evecs(:,n));
      evecs(:,n) = evecs(:,n)./max(a(:));
   end
end
