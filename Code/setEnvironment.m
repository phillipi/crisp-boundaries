%% function [opts] = setEnvironment(type)
% set parameter options
% 
% INPUTS
%  type - specifies which parameter set to use 
%          e.g., can take on values 'speedy' or 'accurate' 
%          feel free to define your custom types at end of this function
%
% OUTPUTS
%  opts - selected parameters
% 
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

function [opts] = setEnvironment(type)

    %% scales                                                   used throughout code:
    opts.num_scales = 3;                                        % how many image scales to measure affinity over
                                                                %  each subsequent scale is half the size of the one before (in both dimensions)
                                                                %  if opts.num_scales>1, then the method of Maire & Yu 2013 is used for globalization (going from affinty to boundaries);
                                                                %  otherwise regular spectral clustering is used
    opts.scale_offset = 0;                                      % if opts.scale_offset==n then the first n image scales are skipped (first scales are highest resolution)
    
    
    %% features                                                 used in getFeatures.m:
    opts.features.which_features = {'color','var'};             % which features to use?
    opts.features.decorrelate = 1;                              % decorrelate feature channels (done separately for each feature type in which_features)?
    
    
    
    %% model and learning for PMI_{\rho}(A,B)                   used in learnP_A_B.m and buildW_pmi.m:
    opts.model_type = 'kde';                                    % what type of density estimate? (kde refers to kernel density estimation, which is the only method currently supported)
    opts.joint_exponent = 1.25;                                 % exponent \rho for PMI_{\rho} (Eqn. 2 in the paper)
    opts.p_reg = 100;                                           % regularization added to numerator and demoninator of PMI calculation
    
    % kde options
    opts.kde.Nkernels = 10000;                                  % how many kernels for kde
    opts.kde.kdtree_tol = 0.001;                                % controls how exact is the kde evaluation (kde uses a kdtree to speed it up)
    opts.kde.learn_bw = true;                                   % adapt the bandwidth of the kde kernels to each test image?
    opts.kde.min_bw = 0.01; opts.kde.max_bw = 0.1;              % min and max bandwidths allowed when adapating bandwidth to test image
    
    opts.model_half_space_only = true;                          % when true we model only half the joint {A,B} space and assume symmetry
    
    % options for Eqn. 1 in paper
    opts.sig = 0.25;                                            % variance in pixels on Gaussian weighting function w(d) (see Eqn. 1 in paper)
    
    % speed up options
    opts.only_learn_on_first_scale = false;                     % setting this to true makes it so kde bandwidths and Affinity predictor are only 
                                                                %  learned on first scale (highest resolution) and assumed to be the same on lower 
                                                                %  resolution scales
                                                                %  (this often works well since image statistics are largely scale invariant)
    
                                                            
    %% approximate PMI with a random forest?                    used in learnPMIpredictor:                                
    opts.approximate_PMI = true;                                % approximate W with a random forest?
    opts.PMI_predictor.Nsamples_learning_PMI_predictor = 10000; % how many samples to learn approximation from
    opts.PMI_predictor.Ntrees = 4;                              % how many trees in the random forest
    
    
    %% globalization (from affinity to boundaries)              used in getE:
    opts.globalization_method = 'spectral_clustering';          % how to go from affinty to boundaries? (spectral clustering is only method currently supported)
    opts.spectral_clustering.approximate = false;               % use the DNcuts approximation from Arbelaez et al. CVPR 2014? (was not included in our published paper)
    opts.spectral_clustering.nvec = 100;                        % how many eigenvectors to use
    
    % post-processing
    opts.border_suppress = 1;                                   % get rid of boundaries that align with image borders and are right next to the borders?
                                                                %  (this helps on images that have false boundaries near borders (like some in BSDS); this kind of suppression
                                                                %   is common in other boundary detection algorithms such as Structured Edges (Dollar & Zitnick 2013) and
                                                                %   Sketch Tokens (Lim et al. 2013))
    
    %% other options
    opts.display_progress = true;                           % set to false if you want to suppress all progress printouts
    
    
    
    %% some example parameter variants for speed versus accuracy
    if (isempty(type))
        return;
    else
        switch type
            case 'speedy' % fastest, low resolution
                opts.kde.Nkernels = 5000;
                opts.kde.learn_bw = false;
                opts.approximate_PMI = true;
                opts.scale_offset = 1; 
                opts.num_scales = 1;
                opts.spectral_clustering.approximate = true;
                
            case 'accurate_low_res' % fast, low resolution, top results on conventional metrics (coarse edge matching)
                opts.kde.Nkernels = 5000;
                opts.kde.learn_bw = false;
                opts.approximate_PMI = true;
                opts.scale_offset = 1; 
                opts.num_scales = 1;
                
            case 'accurate_high_res' % high resolution
                opts.kde.Nkernels = 5000;
                opts.kde.learn_bw = false;
                opts.approximate_PMI = true;
                opts.num_scales = 1;
                opts.spectral_clustering.approximate = true;
                
            case 'accurate_multiscale' % slow, uses multiscale algorithm which gives a tiny boost in performance
                opts.approximate_PMI = true;
                opts.PMI_predictor.Ntrees = 32;
             
            case 'MS_algorithm_from_paper' % very slow, gives another tiny boost in performance
                opts.approximate_PMI = false;
                
            case 'compile_test' % fast check that everything is compiled correctly
                opts.kde.Nkernels = 10;
                opts.kde.learn_bw = false;
                opts.approximate_PMI = true;
                opts.PMI_predictor.Ntrees = 1;
                opts.scale_offset = 0;
                opts.num_scales = 1;
                opts.which_features = {'color'};
                opts.display_progress = false;
                
            otherwise
                error('unknown setting type %s',type);
        end
    end
end