function [spb_arr,spbo_arr] = ae_multigrid_custom(Ws,nvec,im_sizes,im)

    %%
    nlvls = length(Ws);
    C_arr     = cell([1 nlvls]);
    Theta_arr = cell([1 nlvls]);
    U_arr     = cell([1 nlvls]);
    % get number of elements at each level
    ne = zeros([1 nlvls]);
    for n = 1:nlvls
      ne(n) = prod(im_sizes{n});
    end
    ne_cum = cumsum(ne);
    %%
    for n = 1:nlvls
      % retrieve the affinity matrix
      C = Ws{n};
      % compute cross-level constraint matrix
      U = [];
      if (n > 1)
         % compute constraint matrix
         sz_prev = im_sizes{n-1};
         sz_curr = im_sizes{n};
         U = grid_interp(sz_prev, sz_curr);
         % adjust constraint matrix indices
         ne_offset = ne_cum(n-1) - ne(n-1);
         [ui uj uval] = find(U);
         U = sparse(ui + ne_offset, uj, uval, ne_cum(n), ne(n-1));
      end
      % store
      C_arr{n}     = C;
      Theta_arr{n} = [];
      U_arr{n}     = U;
    end

    %%
    % progressive multigrid multiscale eigensolver
    opts = struct( ...
       'k', ones(1,length(im_sizes)), ...
       'k_rate', sqrt(2), ...
       'tol_err', 10.^-1, ... %10.^-2
       'disp', true, ...
       'tol_ichol', 2.^-4 ... %2.^-8; 2.^-20
    );
    % uncomment this line to use ISPC sparse matrix * dense matrix implementation
    %opts.use_ispc = 1;
    tic;
    [evecs evals info] = ae_multigrid(C_arr, Theta_arr, U_arr, nvec, opts);
    time = toc;
    disp(['Wall clock time for eigensolver: ' num2str(time) ' seconds']);
    % spectral pb extraction from eigenvectors
    [spb_arr spbo_arr spb spbo] = multiscale_spb_custom(evecs, evals, im_sizes);
    %{
    % display spectral pb results
    figure(1); imagesc(im); axis image; axis off; title('Image');
    figure(2);
    for i=1:length(spb_arr)
        subplot(1,3,i); imagesc(spb_arr{i}'); axis image; axis off; title(sprintf('sPb scale %d',i));
    end
    %}
end
