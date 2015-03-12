% Evaluation script for crisp boundaries
%
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2015 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

%% setup
% first cd to the 'Code' directory, then run:
compile; % this will check to make sure everything is compiled properly; if it is not, will try to compile it

%% choose parameter settings to evaluate
%type = 'speedy'; 
type = 'accurate_low_res';
%type = 'accurate_high_res';
%type = 'accurate_multiscale';
%type = 'MS_algorithm_from_paper';

%% paths (modify these to point where you want)
DATA_DIR = 'PATH/TO/BSDS';
IMG_DIR = fullfile(DATA_DIR,'BSR/BSDS500/data/images/test/');
GT_DIR = fullfile(DATA_DIR,'BSR/BSDS500/data/groundTruth/test/');
RESULTS_DIR = sprintf('../Results/%s',type);

%%
evalAll(IMG_DIR,GT_DIR,RESULTS_DIR,type);


%% Below are the benchmark numbers you should get for each type of parameter settings
%{
../Results/speedy
Boundary
ODS: F( 0.74, 0.72 ) = 0.73   [th = 0.07]
OIS: F( 0.76, 0.75 ) = 0.75
Area_PR = 0.78

Region
GT covering: ODS = 0.59 [th = 0.13]. OIS = 0.64. Best = 0.74
Rand Index: ODS = 0.82 [th = 0.10]. OIS = 0.85.
Var. Info.: ODS = 1.70 [th = 0.19]. OIS = 1.51.



../Results/accurate_low_res
Boundary
ODS: F( 0.73, 0.75 ) = 0.74   [th = 0.08]
OIS: F( 0.76, 0.77 ) = 0.77
Area_PR = 0.80

Region
GT covering: ODS = 0.61 [th = 0.13]. OIS = 0.66. Best = 0.76
Rand Index: ODS = 0.83 [th = 0.13]. OIS = 0.86.
Var. Info.: ODS = 1.58 [th = 0.20]. OIS = 1.42.



../Results/accurate_high_res
Boundary
ODS: F( 0.73, 0.72 ) = 0.73   [th = 0.06]
OIS: F( 0.77, 0.73 ) = 0.75
Area_PR = 0.78

Region
GT covering: ODS = 0.58 [th = 0.08]. OIS = 0.63. Best = 0.72
Rand Index: ODS = 0.81 [th = 0.04]. OIS = 0.85.
Var. Info.: ODS = 1.75 [th = 0.11]. OIS = 1.54.



../Results/accurate_multiscale
Boundary
ODS: F( 0.72, 0.73 ) = 0.73   [th = 0.04]
OIS: F( 0.77, 0.76 ) = 0.76
Area_PR = 0.77

Region
GT covering: ODS = 0.60 [th = 0.05]. OIS = 0.65. Best = 0.74
Rand Index: ODS = 0.82 [th = 0.04]. OIS = 0.85.
Var. Info.: ODS = 1.68 [th = 0.07]. OIS = 1.47.



../Results/MS_algorithm_from_paper
Boundary
ODS: F( 0.75, 0.72 ) = 0.73   [th = 0.06]
OIS: F( 0.77, 0.76 ) = 0.77
Area_PR = 0.78

Region
GT covering: ODS = 0.60 [th = 0.09]. OIS = 0.66. Best = 0.76
Rand Index: ODS = 0.82 [th = 0.06]. OIS = 0.86.
Var. Info.: ODS = 1.65 [th = 0.13]. OIS = 1.43.


%}
