task void spmm_subrange(
   /* input */
   uniform double sp_vals[],     /* sparse matrix values (sx x sy sparse) */
   uniform int    sp_cind[],     /* sparse matrix column indices */
   uniform int    sp_roff[],     /* sparse matrix row offsets */
   uniform double mx_vals[],     /* dense matrix values (sy x sz) */
   uniform int sx,               /* #rows in sparse matrix */
   uniform int sy,               /* #cols in sparse matrix */
   uniform int sz,               /* #cols in dense matrix */
   /* output */
   uniform double result[])      /* dense matrix output (sx x sz) */
{
   /* get portion of result in which to work */
   uniform int step = sx / taskCount;
   uniform int x_start = step*taskIndex;
   uniform int x_end   = x_start + step;
   if ((taskIndex+1) == taskCount) { x_end = sx; }
   /* loop over rows in result */
   for (uniform int x = x_start; x < x_end; ++x) {
      /* grab sparse row data */
      uniform double* uniform sp_rv = sp_vals + sp_roff[x]; /* row values  */
      uniform int*    uniform sp_rc = sp_cind + sp_roff[x]; /* row columns */
      int ne = sp_roff[x+1] - sp_roff[x]; /* # non-zero elements in row */
      /* grab pointer to result row */
      uniform double* uniform result_row = result + x*sz;
      /* loop over non-zero elements in sparse row */
      for (uniform int e = 0; e < ne; ++e) {
         /* grab element value and column */
         uniform double v = sp_rv[e];
         uniform int    y = sp_rc[e];
         /* grab row of dense matrix */
         uniform double* uniform mx_row = mx_vals + y*sz;
         /* multiply-add entire row of dense matrix to result */
         foreach (z = 0 ... sz) {
            result_row[z] += v * mx_row[z];
         }
      }
   }
}

/* sparse matrix times dense matrix */
export void spmm(
   /* input */
   uniform double sp_vals[],     /* sparse matrix values (sx x sy sparse) */
   uniform int    sp_cind[],     /* sparse matrix column indices */
   uniform int    sp_roff[],     /* sparse matrix row offsets */
   uniform double mx_vals[],     /* dense matrix values (sy x sz) */
   uniform int sx,               /* #rows in sparse matrix */
   uniform int sy,               /* #cols in sparse matrix */
   uniform int sz,               /* #cols in dense matrix */
   /* output */
   uniform double result[],      /* dense matrix output (sx x sz) */
   /* params */
   uniform int nt)               /* #threads */
{
   nt = (sx < nt) ? sx : nt;
   launch [nt] spmm_subrange(
      sp_vals, sp_cind, sp_roff, mx_vals, sx, sy, sz, result
   );
}
