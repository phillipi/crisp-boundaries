function acc = isum(x,idx,nbins)
%
% Rewritten version of isum from BSDS500 code
% this version avoids requiring mex since isum is basically just accumarray
%
% Phillip Isola
% July 2014

m = (idx>=1) & (idx<=nbins);
acc = accumarray(idx(m),x(m));
acc = cat(1,acc,zeros(nbins-size(acc,1),1));