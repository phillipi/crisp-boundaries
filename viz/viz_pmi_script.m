
%% setup
compile;
addpath(genpath(pwd));

%% parameters
type = 'accurate';
opts = setEnvironment(type);
opts.scale_offset = 0; opts.num_scales = 1; opts.model_half_space_only = false;

%% load image
I = imread('test_images/253027.jpg');

%% get features (luminance)
f_maps = getFeatures(double(I)/255,1,'luminance',opts);

%% learn probability model
p = learnP_A_B(f_maps,opts);

%% viz PMI function for image
vizPMI(p,I,opts);
