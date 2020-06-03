#include "matrix.h"

void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
 int number_of_dims, c; 
 const int  *dim_array;

    number_of_dims = mxGetNumberOfDimensions(prhs[0]);
    dim_array = mxGetDimensions(prhs[0]);
    for (c=0; c<number_of_dims; c++)
       mexPrintf("%d\n", *dim_array++); 
}
