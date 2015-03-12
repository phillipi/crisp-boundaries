% Compute multiscale pb cues.
function pb_arr = multiscale_pb(im, sz_min)
   % default size of smallest image grid
   if (nargin < 2), sz_min = [50 50]; end
   % initialize fine to coarse set of pb signals
   pb_arr = {};
   sz_im   = [size(im,1) size(im,2)];
   sz_next = sz_im;
   while (all(sz_next >= sz_min))
      % compute cues - standard scales
      [bg1 bg2 bg3 cga1 cga2 cga3 cgb1 cgb2 cgb3 tg1 tg2 tg3 textons] = ...
         det_mPb(im);
      % smooth cues
      tic;
      gtheta = ...
         [1.5708    1.1781    0.7854    0.3927 ...
          0         2.7489    2.3562    1.9635];
      for o = 1 : size(tg1, 3),
         bg1(:,:,o) = fitparab(bg1(:,:,o),3,3/4,gtheta(o));
         bg2(:,:,o) = fitparab(bg2(:,:,o),5,5/4,gtheta(o));
         bg3(:,:,o) = fitparab(bg3(:,:,o),10,10/4,gtheta(o));

         cga1(:,:,o) = fitparab(cga1(:,:,o),5,5/4,gtheta(o));
         cga2(:,:,o) = fitparab(cga2(:,:,o),10,10/4,gtheta(o));
         cga3(:,:,o) = fitparab(cga3(:,:,o),20,20/4,gtheta(o));

         cgb1(:,:,o) = fitparab(cgb1(:,:,o),5,5/4,gtheta(o));
         cgb2(:,:,o) = fitparab(cgb2(:,:,o),10,10/4,gtheta(o));
         cgb3(:,:,o) = fitparab(cgb3(:,:,o),20,20/4,gtheta(o));

         tg1(:,:,o) = fitparab(tg1(:,:,o),5,5/4,gtheta(o));
         tg2(:,:,o) = fitparab(tg2(:,:,o),10,10/4,gtheta(o));
         tg3(:,:,o) = fitparab(tg3(:,:,o),20,20/4,gtheta(o));
      end
      fprintf('Cues smoothing:%g\n', toc);
      % compute 3 versions of single scale pb
      % (weights not re-learned, so just pass the same scale to mPb 3 times)
      rsz = 1.0;
      pb1_all = mPb_all_from_cues( ...
         bg1, bg1, bg1, cga1, cga1, cga1, cgb1, cgb1, cgb1, tg1, tg1, tg1, rsz);
      pb2_all = mPb_all_from_cues( ...
         bg2, bg2, bg2, cga2, cga2, cga2, cgb2, cgb2, cgb2, tg2, tg2, tg2, rsz);
      pb3_all = mPb_all_from_cues( ...
         bg3, bg3, bg3, cga3, cga3, cga3, cgb3, cgb3, cgb3, tg3, tg3, tg3, rsz);
      % compute grid sizes
      sigma = 2;
      sz1 = sz_im;
      sz2 = round(1./sigma.*sz1);
      sz3 = round(1./sigma.*sz2);
      n1 = prod(sz1);
      n2 = prod(sz2);
      n3 = prod(sz3);
      % compute sampling matrices
      S2 = grid_sample(sz2, sz1);
      S3 = grid_sample(sz3, sz1);
      % resize pb signals
      pb1_all_rsz = pb1_all;
      pb2_all_rsz = reshape(S2*reshape(pb2_all, [n1 8]), [sz2 8]);
      pb3_all_rsz = reshape(S3*reshape(pb3_all, [n1 8]), [sz3 8]);
      % nonmax suppress
      pb1_nmax = nonmax_channels(pb1_all_rsz,pi/16);
      pb2_nmax = nonmax_channels(pb2_all_rsz,pi/16);
      pb3_nmax = nonmax_channels(pb3_all_rsz,pi/16);
      % store pb
      if (all((sz_min <= sz1) & (sz1 <= sz_next)))
         pb_arr{end + 1} = pb1_nmax;
      end
      if (all((sz_min <= sz2) & (sz2 <= sz_next)))
         pb_arr{end + 1} = pb2_nmax;
      end
      if (all((sz_min <= sz3) & (sz3 <= sz_next)))
         pb_arr{end + 1} = pb3_nmax;
      end
      % shrink image
      sz_im = round(1./sigma.*sz1);
      im = imresize(im, sz_im, 'bilinear');
      % set next active scale
      sz_next = round(1./sigma.*sz3);
   end
end
