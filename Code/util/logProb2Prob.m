%% utility for converting an unnormalized log probability into a probability
% also handles infinities

function [p] = logProb2Prob(lp)
    p = exp(lp-max(lp(~isinf(lp))));
    
    if (sum(p(:))==0)
        p = ones(size(p));
        p = p./sum(p(:));
    else
        p = p./sum(p(:));
    end
end