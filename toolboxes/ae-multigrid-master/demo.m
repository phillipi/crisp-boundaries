% load image
im = double(imread('grouping/data/101087.jpg'))./255;
im = imresize(im, [480 320], 'bilinear');
% compute pb at multiple scales
pb_arr = multiscale_pb(im);
% compute intervening contour
[C_arr Theta_arr U_arr] = multiscale_ic(pb_arr);
% progressive multigrid multiscale eigensolver
opts = struct( ...
   'k', [1 1 1], ...
   'k_rate', sqrt(2), ...
   'tol_err', 10.^-2, ...
   'disp', true ...
);
% uncomment this line to use ISPC sparse matrix * dense matrix implementation
%opts.use_ispc = 1;
tic;
[evecs evals info] = ae_multigrid(C_arr, Theta_arr, U_arr, 16, opts);
time = toc;
disp(['Wall clock time for eigensolver: ' num2str(time) ' seconds']);
% spectral pb extraction from eigenvectors
[spb_arr spbo_arr spb spbo spb_nmax] = multiscale_spb(evecs, evals, pb_arr);
% display spectral pb results
figure(1); imagesc(im); axis image; axis off; title('Image');
figure(2);
subplot(1,3,1); imagesc(spb_arr{1}); axis image; axis off; title('sPb (coarse)');
subplot(1,3,2); imagesc(spb_arr{2}); axis image; axis off; title('sPb (medium)');
subplot(1,3,3); imagesc(spb_arr{3}); axis image; axis off; title('sPb (fine)');
