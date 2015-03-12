#include <iostream>
#include <math.h>
#include "mex.h"
#include "spmm.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   /* retreive input */
   double* sp_vals = static_cast<double*>(mxGetData(prhs[0]));
   int*    sp_cind = static_cast<int*>(mxGetData(prhs[1]));
   int*    sp_roff = static_cast<int*>(mxGetData(prhs[2]));
   double* mx_vals = static_cast<double*>(mxGetData(prhs[3]));
   int sx  = static_cast<int>((mxGetPr(prhs[4]))[0]);
   int sy  = static_cast<int>((mxGetPr(prhs[5]))[0]);
   int sz  = static_cast<int>((mxGetPr(prhs[6]))[0]);
   /* retreive output */
   double* result = static_cast<double*>(mxGetData(prhs[7]));
   int nt  = static_cast<int>((mxGetPr(prhs[8]))[0]);
   /* multiply */
   ispc::spmm(sp_vals, sp_cind, sp_roff, mx_vals, sx, sy, sz, result, nt);
}
