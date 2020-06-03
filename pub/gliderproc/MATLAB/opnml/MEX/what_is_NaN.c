#include <math.h>
#include <stdio.h>
#include "mex.h"

/************************************************************

  ####     ##     #####  ######  #    #    ##     #   #
 #    #   #  #      #    #       #    #   #  #     # #
 #       #    #     #    #####   #    #  #    #     #
 #  ###  ######     #    #       # ## #  ######     #
 #    #  #    #     #    #       ##  ##  #    #     #
  ####   #    #     #    ######  #    #  #    #     #

************************************************************/


void mexFunction(int            nlhs,
                 mxArray       *plhs[],
		 int            nrhs,
		 const mxArray *prhs[])
{

   double NaN=mxGetNaN();
   fprintf(stdout,"%lf\n",NaN);
   return;   
}
