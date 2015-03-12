function [] = vizPMI(p,I,opts)
    
    %% evaluate at a grid of feature values
    [xx,yy] = meshgrid(0:0.01:1.05,0:0.01:1.05); yy = 1.05-yy;
    
    F_unary1 = xx(:); F_unary2 = yy(:);
    F = cat(2,F_unary1,F_unary2); % {A,B} pairs
    F_unary = cat(1,F_unary1,F_unary2); % A followed by B
    A_idx = 1:size(F_unary1,1); B_idx = (size(F_unary1,1)+1):2*size(F_unary1,1);
    
    %%
    [~,pJoint,pProd] = evalPMI(p,F,F_unary,A_idx,B_idx,opts);
    
    %%
    w1 = pJoint;
    w2 = (pJoint.^1)./pProd; % this gives PMI_1
    
    w1 = reshape(w1,size(xx,1),size(xx,2));
    w2 = reshape(w2,size(xx,1),size(xx,2));
    
    %%
    subplot(131); imshow(I); title('input image');
    
    %%
    subplot(132); [~,ch] = contourf(xx,yy,(((log(w1)).^1)),20); xlabel('Luminance A'); ylabel('Luminance B'); title('log P(A,B)'); axis('image'); colorbar; set(ch,'edgecolor','k');
        
    %%
    subplot(133); [~,ch] = contourf(xx,yy,(((log(w2)).^1)),20); xlabel('Luminance A'); ylabel('Luminance B'); title('PMI_1(A,B)'); axis('image'); colorbar; set(ch,'edgecolor','k');
end