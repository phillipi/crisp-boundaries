% Demo of crisp boundaries
%
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------


%% setup
% first cd to the directory containing this file, then run:
compile; % this will check to make sure everything is compiled properly; if it is not, will try to compile it


%% Detect boundaries
% you can control the speed/accuracy tradeoff by setting 'type' to one of the values below
% for more control, feel free to play with the parameters in setEnvironment.m

type = 'speedy'; % use this for fastest results
%type = 'accurate_low_res'; % use this for slightly slower but more accurate results
%type = 'accurate_high_res'; % use this for slow, but high resolution results

I = imread('../test_images/101027.jpg');
[E,E_oriented] = findBoundaries(I,type);

close all; subplot(121); imshow(I); subplot(122); imshow(1-mat2gray(E));


%% Segment image
% builds an Ultrametric Contour Map from the detected boundaries (E_oriented)
% then segments image based on this map
%
% this part of the code is only supported on Mac and Linux

if (~ispc)
    
    thresh = 0.1; % larger values give fewer segments
    E_ucm = contours2ucm_crisp_boundaries(mat2gray(E_oriented));
    S = ucm2colorsegs(E_ucm,I,thresh);

    close all; subplot(121); imshow(I); subplot(122); imshow(S);
end