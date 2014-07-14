function [ii] = randperm_2013b(n,k)
    ii = randperm(n);
    ii = ii(1:k);
end