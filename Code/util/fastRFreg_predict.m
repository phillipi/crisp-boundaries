function [y] = fastRFreg_predict(X,rf)
    
    scores = zeros(size(X,1),1);
    
    for i=1:rf.Ntrees
        scores = scores + eval(rf.Trees{i},X);
    end
    y = scores./rf.Ntrees;
end