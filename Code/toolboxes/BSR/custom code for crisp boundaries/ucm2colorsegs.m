% function [colorsegs] = ucm2colorsegs(ucm,im,k)
%
% Phillip Isola
% February 2014

function [colorsegs] = ucm2colorsegs(ucm,im,k)
    
    %
    im = im2double(im);
        
    % get superpixels at scale k without boundaries:
    labels = bwlabel(ucm <= k);
    
    % make higher resolution
    res_scale = 2;
    labels = imresize(labels,res_scale*size(im(:,:,1)),'nearest');
    m = labels==0;
    m = bwmorph(m,'thin');
    labels = inPaint(labels,labels~=0);
    labels(m)=0;
    
    ii = unique(labels);
    ii = ii(2:end); % remove zero label
    
    colorsegs = ones([size(labels),size(im,3)]);
    for i=1:length(ii)
        m = labels==ii(i);
        
        for c=1:size(im,3)
            tmp = imresize(im(:,:,c),res_scale);
            colorsegs_tmp = colorsegs(:,:,c);
            colorsegs_tmp(m) = mean(tmp(m));
            colorsegs(:,:,c) = colorsegs_tmp;
        end
    end    
end