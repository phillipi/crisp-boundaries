function [im] = pcaIm(im)
    im_size = size(im(:,:,1));
    
    X = reshape(im,[size(im,1)*size(im,2),size(im,3)]);
        
    %[U,mu] = pca(X');
    %Y = pcaApply( X', U, mu, size(im,3) )';
    [~,Y] = princomp(X);
    
    im = reshape(Y,[im_size,size(im,3)]);
end