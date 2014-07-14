%% function [E_oriented] = borderSuppress(E_oriented)
% suppress E_oriented values that are right next to an image border and aligned
% with that border
%
% 
% INPUTS
%  E_oriented - NxMxO boundary map split into boundaries energy at O orientations
%
% OUTPUTS
%  E_oriented - same as input but after image border suppression
%
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

function [E_oriented] = borderSuppress(E_oriented)
    
    border_rad = 10;
    
    [xx,yy] = meshgrid(1:size(E_oriented,2),1:size(E_oriented,1));
    
    aspect_ratio = size(E_oriented,2)/size(E_oriented,1);
    m1 = xx>(aspect_ratio*yy);
    m2 = fliplr(m1);
    %%
    vert_border_suppressor = min(((xx-1)/border_rad).^2,1).*(~m1&m2) + ~(~m1&m2);
    vert_border_suppressor = 1 - vert_border_suppressor.*fliplr(vert_border_suppressor);  
    hort_border_suppressor = min(((yy-1)/border_rad).^2,1).*(m1&m2) + ~(m1&m2);
    hort_border_suppressor = 1 - hort_border_suppressor.*flipud(hort_border_suppressor);
    
    %%
    norient = size(E_oriented,3);
    dtheta = pi/norient;
    ch_per = [4 3 2 1 8 7 6 5];
    
    border_suppressor = [];
    for o=1:norient
        theta = dtheta*o;
        border_suppressor(:,:,ch_per(o)) = abs(cos(theta)).*hort_border_suppressor + abs(sin(theta)).*vert_border_suppressor; 
    end
    border_suppressor = 1-border_suppressor;
    
    %%
    E_oriented = border_suppressor.*E_oriented;
end