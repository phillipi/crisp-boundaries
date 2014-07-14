%% function [pmi,pJoint,pProd] = evalPMI(p,F,F_unaryA,F_unaryB,opts)
%
% INPUTS
%  p        - model for P(A,B) (Eqn. 1 in paper)
%  F        - each row is a feature pair {A,B} at which to evaluate P(A,B)
%              A and B each have equal dimensionality
%  F_unary  - each row is a feature A or B at which to evaluate P(A) or P(B)
%  A_idx    - indices in F_unary at which to evaluate P(A)
%  B_idx    - indices in F_unary at which to evaluate P(B)
%  opts     - parameter settings (see setEnvironment)
%
% OUTPUTS
%  pmi      - PMI_{\rho}(A,B) evaluated at all {A,B} in F (Eqn. 2 in paper)
%  pJoint   - P(A,B) evaluated at all {A,B} in F (Eqn. 1 in paper)
%  pProd    - P(A)P(B) evaluated at all {A,B} in F
%
% -------------------------------------------------------------------------
% Crisp Boundaries Toolbox
% Phillip Isola, 2014 [phillpi@mit.edu]
% Please email me if you find bugs, or have suggestions or questions
% -------------------------------------------------------------------------

function [pmi,pJoint,pProd] = evalPMI(p,F,F_unary,A_idx,B_idx,opts)
    %% evaluate p(A,B)
    reg = opts.p_reg;
    tol = opts.kde.kdtree_tol;
    pJoint = reg + evaluate_batches(p,F',tol)/2; % divided by 2 since we only modeled half the space

    %% evaluate p(A)p(B)
    N = floor(size(F,2)/2); assert((round(N)-N)==0);
    p2_1 = marginal(p,1:N);
    p2_2 = marginal(p,N+1:(2*N));
    p2 = joinTrees(p2_1,p2_2,0.5);
    pMarg = zeros(size(F_unary,1),1);
    ii = find(~isnan(F_unary(:,1))); % only evaluate where not nan (A_idx and B_idx will only refer to non-nan entries)
    pMarg(ii) = evaluate_batches(p2,F_unary(ii,:)',tol);
    pProd = pMarg(A_idx).*pMarg(B_idx)+reg;

    %% calculate pmi
    pmi = log((pJoint.^(opts.joint_exponent))./pProd);
end

%% function [v] = evaluate_batches(p,F,tol)
% the point of this function is to speed up kde.evaluate
% the run time of kde.evaulate depends dramatically on the number of points
% input on each call to the function. This is perhaps because BallTree can
% be slow for large point sets?
function [v] = evaluate_batches(p,F,tol)
    
    v = zeros(size(F,2),1);
    n = 100000;
    m = floor(size(F,2)/n);
    end_i = 0;
    eps = 10e-6;
    for i=1:m
        start_i = (i-1)*n+1;
        end_i = start_i + n;
        tmp = F(:,start_i:end_i);
        tmp = tmp+eps*(rand(size(tmp))-0.5); % add a tiny bit of noise to make 'evaluate' 
                                             % faster (not sure why this is necessary, but 
                                             % evaluate is super slow when there are 
                                             % lots of identical points)
        v(start_i:end_i) = evaluate(p,tmp,tol);
    end
    tmp = F(:,end_i+1:end);
    tmp = tmp+eps*(rand(size(tmp))-0.5);
    v(end_i+1:end) = evaluate(p,tmp,tol);
end