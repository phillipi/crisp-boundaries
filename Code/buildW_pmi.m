%% function [W] = buildW_pmi(f_maps,rf,p,opts,samples)
% builds an affinity matrix W for image im based on PMI
% 
% INPUTS
%  f_maps   - NxMxF array of F feature maps for an NxM image
%  rf       - the learned random forest for approximating PMI (unused if ~opts.approximate_PMI)
%  p        - P(A,B) (unused if opts.approximate_PMI)
%  opts     - parameter settings (see setEnvironment)
%  samples   - either the number of samples from the full affinity matrix to
%               compute, or the indices of the full affinity matrix to compute, or empty,
%               in which case the full affinity matrix is computed
%
% OUTPUTS
%  W - affinity matrix
%
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

function [W] = buildW_pmi(f_maps,rf,p,opts,samples)
    
    if (~exist('samples','var'))
        samples = [];
    end
    
    im_size = size(f_maps(:,:,1));
    
    %% get local pixel pairs
    if (isempty(samples) || size(samples,2)==1)
        [ii,jj] = getLocalPairs(im_size,[],[],samples);
    else
        ii = samples(:,1);
        jj = samples(:,2);
    end
    
    %% initialize affinity matrix
    Npixels = prod(im_size);
    W = sparse(double(ii),double(jj),0,Npixels,Npixels);
    
    %% extract features F
    [F,F_unary] = extractF(f_maps,ii,jj,opts);
    
    %% evaluate affinities
    if (opts.approximate_PMI)
        w = exp(fastRFreg_predict(F,rf));
    else
        pmi = evalPMI(p,F,F_unary,ii,jj,opts);
        w = exp(pmi);
    end
    
    %%
    W2 = sparse(double(ii),double(jj),w,Npixels,Npixels);
    W = W+W2;
    W = (W+W'); % we only computed one half of the affinities, now assume they are symmetric
end