%% function [E,E_oriented] = getE(Ws,im_sizes,I,opts)
% given affinity matrices Ws for image I, computes boundary map E
% 
% INPUTS
%  Ws         - affinity matrices; Ws{i} is the affinity matrix for the image at scale i
%  im_sizes   - im_sizes{i} gives the dimensions of the image at scale i
%               (note: dimensions are num cols x num rows; this is the
%                opposite of matlab's default!)
%  I          - NxMxC query image
%  opts       - parameter settings (see setEnvironment)
%
% OUTPUTS
%  E          - NxM boundary map
%  E_oriented - NxMxO boundary map split into boundaries energy at O orientations
% 
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

function [E,E_oriented] = getE(Ws,im_sizes,I,opts)
    
    switch opts.globalization_method
    
        case 'spectral_clustering'
            %% spectral clustering
            if (opts.display_progress), fprintf('\n\nspectral clustering...'); tic; end
            nvec = opts.spectral_clustering.nvec;
            if (length(im_sizes)>1)
                %% multiscale W
                if(opts.spectral_clustering.approximate), error('approximate spectral clustering note supported for multiscale'); end
                [~,spbo_arr] = ae_multigrid_custom(Ws,nvec,im_sizes,double(I)/255);
                
                % using the multigrid-ae gives a different ordering of oriented filters (since it uses transposed images), so need to shift them here
                E_oriented_ = permute(spbo_arr{end},[2 1 3]);
                E_oriented = zeros(size(E_oriented_));
                E_oriented(:,:,5) = E_oriented_(:,:,1);
                E_oriented(:,:,4) = E_oriented_(:,:,2);
                E_oriented(:,:,3) = E_oriented_(:,:,3);
                E_oriented(:,:,2) = E_oriented_(:,:,4);
                E_oriented(:,:,1) = E_oriented_(:,:,5);
                E_oriented(:,:,8) = E_oriented_(:,:,6);
                E_oriented(:,:,7) = E_oriented_(:,:,7);
                E_oriented(:,:,6) = E_oriented_(:,:,8);
                
            else
                W = Ws{1};

                %% spectral clustering
                if (~opts.spectral_clustering.approximate)
                    E_oriented = spectralPb_custom(W,[im_sizes{1}(2) im_sizes{1}(1)],'',nvec);
                else
                    E_oriented = spectralPb_fast_custom(W,[im_sizes{1}(2) im_sizes{1}(1)],nvec);
                end
            end
            if (opts.display_progress), t = toc; fprintf('done: %1.2f sec\n', t); end
        
        otherwise
            error('unknown globalization method %s',model.opts.globalization_method);
    end
    
    %% post-processing
    if (opts.border_suppress)
        E_oriented = borderSuppress(E_oriented);
    end
    E = max(E_oriented,[],3);
end