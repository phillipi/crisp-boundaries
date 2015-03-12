%%
% fills in pixels with value of nearest pixel in mask

function [a] = inPaint(a,mask)
    a_size = size(a);
    [~,idx] = bwdist(mask);
    a(:) = a(idx);
end