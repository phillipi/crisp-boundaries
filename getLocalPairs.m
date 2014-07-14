%% function [ii jj] = getLocalPairs(im_size,rad,rad_inner,Nsamples)
% returns pairs of nearby pixel positions in an image of size im_size
% {ii(i),jj(i)} is the i-th pair
% 
% INPUTS
%  im_size       - size of image (num rows x num cols)
%  rad           - only return pairs at most rad pixels apart
%  rad_inner     - only return pairs at least rad_inner pixels apart
%  opts          - parameter settings (see setEnvironment)
%
% OUTPUTS
%  ii - linear indices in image of first pixels in sampled pairs
%  ii - linear indices in image of second pixels in sampled pairs
%
% 
% EQUIVALENCE TO BSR CODE
%  The following call:
%    [ii jj] = getLocalPairs(im_size);
%  
%  will give the same indices ii and jj as the following, which uses buildW
%  from http://www.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/resources.html
%    l{1} = zeros(im_size(1) + 1, im_size(2));
%    l{1}(2:end, :) = ones(im_size);
%    l{2} = zeros(im_size(1), im_size(2) + 1);
%    l{2}(:, 2:end) = ones(im_size);
%    [ii,jj,~] = buildW(l{1},l{2});
%  (note that buildW is not included in the crisp boundaries toolbox)
% 
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

function [ii jj] = getLocalPairs(im_size,rad,rad_inner,Nsamples)
    
    if (~exist('rad','var')||isempty(rad))
        rad = 5;
    end
    if (~exist('rad_inner','var')||isempty(rad_inner))
        rad_inner = 0;
    end
    
    
    cache_file = sprintf('caches/ii_jj_caches/%d_%d.mat',im_size(1),im_size(2));
    if (exist(cache_file,'file'))
        data = load(cache_file); data = data.data;
        assert(data.rad==rad); assert(data.rad_inner==rad_inner);
        ii = data.ii;
        jj = data.jj;
    else
        Npixels = prod(im_size);

        %%
        [xx yy] = meshgrid(1:2*rad+1,1:2*rad+1);
        xx = xx-rad-1; yy = yy-rad-1;
        m = sqrt(xx.^2 + yy.^2)<=rad;
        m(rad+1,rad+1) = 0;

        m_inner = sqrt(xx.^2 + yy.^2)<=rad_inner;
        m = m&~m_inner;

        %%
        W = sparse([],[],[],Npixels,Npixels,sum(m(:))*Npixels);
        for i=-rad:rad
            for j=-rad:rad
                if (m(i+rad+1,j+rad+1))
                    if (i>=0)
                        d = repmat([true(im_size(2)-i,1); zeros(i,1)],im_size(1),1);
                    else
                        d = repmat([zeros(-i,1); true(im_size(2)+i,1)],im_size(1),1);
                    end
                    d = circshift(d,i);
                    if ((i+im_size(2)*j)>0 && (i+im_size(2)*j)<Npixels)
                        W = W+spdiags(d,i+im_size(2)*j,Npixels,Npixels);
                    end
                end
            end
        end

        %%
        [ii jj] = find(W);
        ii = uint32(ii);
        jj = uint32(jj);
        m = ii>=jj;
        ii(m) = [];
        jj(m) = [];
        
        %%
        data.rad = rad;
        data.rad_inner = rad_inner;
        data.ii = ii;
        data.jj = jj;
        parsave(cache_file,data)
    end
    
    %%
    if (exist('Nsamples','var') && ~isempty(Nsamples)) % subsample to just include Nsamples entries
        %which_idx = randperm(length(ii));
        %which_idx = which_idx(1:min(Nsamples,length(which_idx)));
        which_idx = randi(length(ii),min(Nsamples,length(ii)),1);
        ii = ii(which_idx);
        jj = jj(which_idx);
    end
end