%% function [F] = orderAB(F)
% orders A and B so that we only have to model half the space 
% (assumes symmetry: p(A,B) = p(B,A))
% 
% INPUTS
%  F - each row is a feature pair {A,B}
%       A and B each have equal dimensionality
% 
% OUTPUTS
%  F - same as input but with ordered so that A always refers to a pixel on
%      one canonical side of the joint space {A,B}, and B refers to a pixel
%      on the other side
% 
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

function [F] = orderAB(F)
    swap_idx1 = 1; swap_idx2 = (1+(size(F,2)/2));
    m = F(:,swap_idx1)<=F(:,swap_idx2);
    F_tmp = F;
    F(m,swap_idx1) = F_tmp(m,swap_idx2);
    F(m,swap_idx2) = F_tmp(m,swap_idx1);
end