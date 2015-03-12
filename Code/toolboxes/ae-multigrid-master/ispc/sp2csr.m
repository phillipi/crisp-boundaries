% convert matlab sparse matrix to csr form
function S = sp2csr(sp)
   % get size, index vectors, and values
   [sx sy] = size(sp);
   [i j s] = find(sp);
   % convert (row, column) to linear indices
   inds = i*sy + j;
   % sort by linear index
   [inds ii] = sort(inds);
   i = i(ii);
   sp_cind = j(ii) - 1;
   sp_vals = s(ii);
   % get row starting offsets
   [r r_start] = unique(i,'first');
   [r r_end]   = unique(i,'last');
   r_size = zeros([sx 1]);
   r_size(r) = r_end - r_start + 1;
   sp_roff = [0; cumsum(r_size)];
   % type convert
   %sp_vals = double(sp_vals);
   sp_cind = int32(sp_cind);
   sp_roff = int32(sp_roff);
   % pack into structure
   S = struct( ...
      'sx', sx, ...
      'sy', sy, ...
      'sp_vals', sp_vals, ...
      'sp_cind', sp_cind, ...
      'sp_roff', sp_roff ...
   );
end
