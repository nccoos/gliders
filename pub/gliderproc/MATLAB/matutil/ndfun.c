/* ndfun.c: MEX (MATLAB) file to implement functions that treat
   multi-dimensional arrays as "pages" of 2D matrices.
   
   This allows you do to, for example, 
     C = ndfun('mult', A, B),
   which is equivalent to
     for i = 1:100
       C(:,:,i) = A(:,:,i) * B(:,:,i);
     end

   except it is more flexible, since it does the same for any number
   of dimensions.

   It also automatically reuses 2D matrices in either position, as in:
     for i = 1:100
       C(:,:,i) = A * B(:,:,i);
     end

   Supported operations are now multiplication, inverses, and square
   matrix backslash.

   Debating including a "fast" option that skips the singularity
   check.  For 100x100 inverse, this would save 15%.  Opinions?

   Author: Peter Boettcher <boettcher@ll.mit.edu>
   Copyright 2002, Peter Boettcher
*/


/* 	$Id: ndfun.c,v 1.6 2002/03/28 21:45:23 pwb Exp $	 */

#ifndef lint
static char vcid[] = "$Id: ndfun.c,v 1.6 2002/03/28 21:45:23 pwb Exp $";
#endif /* lint */

#include "mex.h"
#include <string.h>
#include <math.h>

double compute_norm(double *A, int m, int n);
void compute_lu(double *X, int m, int *ipivot, double *work, int *iwork, int check_singular);
void blas_return_check(int info, const char *blasfcn);

/* Does anyone else NOT mangle underbars onto BLAS function names? 
   Put 'em here. */
#if defined(__OS2__)  || defined(__WINDOWS__) || defined(WIN32)
#define BLASCALL(f) f
#else
#define BLASCALL(f) f ## _
#endif


/* BLAS/LAPACK Function prototypes added 03/28/02 Aj */
void BLASCALL(dgemm)(const char *TRANSA, const char *TRANSB, 
		     const int *M, const int *N, const int *K, const double *ALPHA, 
		     const double A[], const int *LDA, const double *B, const int *LDB, 
		     const double *BETA, double C[], const int *LDC);
void BLASCALL(dgetrs)(const char *TRANS, const int *N, const int *NRHS, 
		      const double A[], const int *LDA, const int IPIV[], double B[],
		      const int *LDB, int *INFO);
void BLASCALL(dgetri)(const int *N, double A[], const int *LDA, const int IPIV[], 
		      double WORK[], const int LWORK[], int *INFO);
void BLASCALL(dgetrf)(const int *M, const int *N, double A[], const int *LDA, 
		      int IPIV[], int *INFO);
void BLASCALL(dgecon)(const char *NORM, const int *N, const double A[],
		      const int *LDA, const double *ANORM, double *RCOND, double WORK[], 
		      int IWORK[], int *INFO);

/* Typedefs */
typedef enum {COMMAND_INVALID=0, COMMAND_MULT, COMMAND_INV, 
	      COMMAND_BACKSLASH, COMMAND_VERSION} commandcode_t;

#define CHECK_SQUARE_A 1
#define CHECK_SQUARE_B 2
#define CHECK_AT_LEAST_2D_A 4
#define CHECK_AT_LEAST_2D_B 8

struct ndcommand_s {
  char *cmdstr;
  commandcode_t commandcode;
  int num_args;
  int check;
} ndcommand_list[] = {{"mult", COMMAND_MULT, 2, 0},
		      {"inv", COMMAND_INV, 1, CHECK_SQUARE_A | CHECK_AT_LEAST_2D_A},
		      {"backslash", COMMAND_BACKSLASH, 2, CHECK_SQUARE_A | CHECK_AT_LEAST_2D_A},
		      {"version", COMMAND_VERSION, 0, 0},
		      {NULL, COMMAND_INVALID, 0}};

double eps;

struct ndcommand_s *get_command(const mxArray *mxCMD)
{
  char *commandstr;
  int i=0;

  if(mxGetClassID(mxCMD) != mxCHAR_CLASS)
    mexErrMsgTxt("First argument must be the command to use");
  commandstr = mxArrayToString(mxCMD);
  
  while(ndcommand_list[i].cmdstr) {
    if (strcmp(commandstr, ndcommand_list[i].cmdstr) == 0) {
      mxFree(commandstr);
      return(&ndcommand_list[i]);
    }
    i++;
  }

  mxFree(commandstr);
  mexErrMsgTxt("Unknown command");

  return(NULL);
}

int page_dim_check(int numDimsA, int numDimsB, const int *dimsA, const int *dimsB, int dimcheck)
{
  int i, numPages=1;
 
  /* OK, valid possibilities are: 
     -Fully matching N-D arrays
     -One 2D (or less) array and one arbitrary N-D array */

  if((numDimsA <= 2) || (numDimsB <= 2)) {
    /* repeated_arg = 1; */
  } else {
    if(numDimsA != numDimsB)
      mexErrMsgTxt("Invalid dimensions");
    for(i=2; i<numDimsA; i++) {
      if(dimsA[i] != dimsB[i])
	mexErrMsgTxt("Dimensions after 2 must match");
      numPages *= dimsA[i];
    }
  }     

  if(dimcheck & CHECK_AT_LEAST_2D_A) {
    if(numDimsA < 2)
      mexErrMsgTxt("A must be at least 2D!");
  }
  if(dimcheck & CHECK_AT_LEAST_2D_B) {
    if(numDimsB < 2)
      mexErrMsgTxt("B must be at least 2D!");
  }
     
  if(dimcheck & CHECK_SQUARE_A) {
    if(dimsA[0] != dimsA[1])
      mexErrMsgTxt("A must be square in first 2 dimensions");
  }
  if(dimcheck & CHECK_SQUARE_B) {
    if(dimsB[0] != dimsB[1])
      mexErrMsgTxt("A must be square in first 2 dimensions");
  }
  
  return(0);
}
    


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  const int *dimsA=NULL, *dimsB=NULL, *dimsptr;
  int *dimsC;
  int numDimsA=0, numDimsB=0, numDimsC=0;
  int m=0, n=0, p=0, i;
  double *A, *B, *C, one = 1.0, zero = 0.0;
  int numPages=1;
  int strideA, strideB, strideC;
  struct ndcommand_s *command;
  const mxArray *mxA=NULL, *mxB=NULL;
  int *ipivot, info, *iwork;
  double *work, *scratchA;
  
  eps = mxGetEps();

  if(nrhs < 1)
    mexErrMsgTxt("Not enough arguments");

  /* Figure which command was chosen */
  command = get_command(prhs[0]);

  /* Set up some variables for the 2 and 1 argument cases */
  if(command->num_args == 2) {
    if(nrhs != 3)
      mexErrMsgTxt("Two arguments required");

    mxA = prhs[1];
    mxB = prhs[2];
    
    numDimsA = mxGetNumberOfDimensions(mxA);
    dimsA = mxGetDimensions(mxA);

    numDimsB = mxGetNumberOfDimensions(mxB);
    dimsB = mxGetDimensions(mxB);
  } else if(command->num_args == 1) {
    if(nrhs != 2)
      mexErrMsgTxt("One argument required");

    mxA = prhs[1];
    numDimsA = mxGetNumberOfDimensions(mxA);
    dimsA = mxGetDimensions(mxA);
  }

  /* Be sure dimensions agree in the necessary ways.  check is a
     bitmask of "necessary" checks to perform, which depends on the
     command chosen */
  page_dim_check(numDimsA, numDimsB, dimsA, dimsB, command->check);

  switch(command->commandcode) {
  case COMMAND_VERSION:
    mexPrintf("NDFUN MEX file\nCopyright 2002 Peter Boettcher\n%s\n", 
	      "$Revision: 1.6 $");
    break;
  case COMMAND_MULT:
    /******************************************
     * MULTIPLY
     ******************************************/

    if(dimsA[1] != dimsB[0])
      mexErrMsgTxt("Inner dimensions (first 2) don't match");
   
    m = dimsA[0];
    n = dimsB[1];
    p = dimsA[1];
    strideC = m*n;

    strideA = m*p;
    strideB = p*n;
    dimsptr = dimsA;
    numDimsC = numDimsA;

    if(numDimsA != numDimsB) {
      if(numDimsA < numDimsB) {
	strideA = 0;
	numDimsC = numDimsB;
	dimsptr = dimsB;
      } else {
	strideB = 0;
      }
    }

    for(i=2; i<numDimsC; i++)
      numPages *= dimsptr[i];

    dimsC = (int *)mxMalloc(numDimsC*sizeof(int));
    dimsC[0] = m;
    dimsC[1] = n;
    for(i=2; i<numDimsC; i++)
      dimsC[i] = dimsptr[i];
    
    plhs[0] = mxCreateNumericArray(numDimsC, dimsC, mxDOUBLE_CLASS, mxREAL);
    C = mxGetPr(plhs[0]);
    A = mxGetPr(mxA);
    B = mxGetPr(mxB);
    
    for(i=0; i<numPages; i++) {
      BLASCALL(dgemm)("N", "N", &m, &n, &p, &one, A + i*strideA, &m, B + i*strideB, 
		      &p, &zero, C + i*strideC, &m);
    }
  
    mxFree(dimsC);
    break;

  case COMMAND_BACKSLASH:
    /******************************************
     * BACKSLASH
     ******************************************/

    if(dimsA[0] != dimsB[0])
      mexErrMsgTxt("First dimensions must match");
    
    m = dimsA[0];
    n = dimsA[1];
    p = dimsB[1];
    
    strideC = n*p;
    strideA = m*n;
    strideB = m*p;
    dimsptr = dimsA;
    numDimsC = numDimsA;

    if(numDimsA != numDimsB) {
      if(numDimsA < numDimsB) {
	strideA = 0;
	numDimsC = numDimsB;
	dimsptr = dimsB;
      } else {
	strideB = 0;
      }
    }
    for(i=2; i<numDimsC; i++)
      numPages *= dimsptr[i];
    dimsC = (int *)mxMalloc(numDimsC*sizeof(int));
    dimsC[0] = n;
    dimsC[1] = p;
    for(i=2; i<numDimsC; i++)
      dimsC[i] = dimsptr[i];
    
    plhs[0] = mxCreateNumericArray(numDimsC, dimsC, mxDOUBLE_CLASS, mxREAL);

    C = mxGetPr(plhs[0]);
    A = mxGetPr(mxA);
    B = mxGetPr(mxB);
  
    ipivot = (int *)mxMalloc(m*sizeof(int));
    iwork = (int *)mxMalloc(m*sizeof(int));
    work = (double *)mxMalloc(m*m*sizeof(double));
    scratchA = (double *)mxMalloc(m*n*sizeof(double));


    if(numDimsA < numDimsB) {
      /* Single A, multiple B.  That means do one LU on A, and multiple solves */
      /* Save memory by doing it this way... that way we need only a m*n temp array */
      memcpy(scratchA, A, mxGetNumberOfElements(mxA)*sizeof(double));
      memcpy(C, B, m*p*numPages*sizeof(double));
      compute_lu(scratchA, m, ipivot, work, iwork, 1);

      /* Loop over pages of B and compute */
      for(i=0; i<numPages; i++) {
	BLASCALL(dgetrs)("N", &m, &p, scratchA, &m, ipivot, C + i*strideC, &m, &info);
	blas_return_check(info, "DGETRS");
      }
    } else {
      /* Multiple A.  Do the LU each step through */
      for(i=0; i<numPages; i++) {
	memcpy(scratchA, A + i*strideA, m*n*sizeof(double));
	compute_lu(scratchA, m, ipivot, work, iwork, 1);

	/* Compute */
	memcpy(C+i*strideC, B+i*strideB, m*p*sizeof(double));
	BLASCALL(dgetrs)("N", &m, &p, scratchA, &m, ipivot, C + i*strideC, &m, &info);
	blas_return_check(info, "DGETRS");	
      }
    }
    
    mxFree(iwork);
    mxFree(scratchA);
    mxFree(dimsC);
    mxFree(ipivot);
    mxFree(work);
    break;
  case COMMAND_INV:
    /******************************************
     * INVERSE
     ******************************************/
    m = dimsA[0];
    n = dimsA[1];
    ipivot = (int *)mxMalloc(m*sizeof(int));
    work = (double *)mxMalloc(m*m*sizeof(double));
    iwork = (int *)mxMalloc(m*sizeof(int));

    plhs[0] = mxDuplicateArray(mxA);
    C = mxGetPr(plhs[0]);
    strideC = n*m;

    for(i=2; i<numDimsA; i++)
      numPages *= dimsA[i];

    for(i=0; i<numPages; i++) {
      compute_lu(C + i*strideC, m, ipivot, work, iwork, 1);
	
      BLASCALL(dgetri)(&n, C + i*strideC, &m, ipivot, work, &n, &info );
      blas_return_check(info, "DGETRI");
      /*      if(info>0) mexWarnMsgTxt("Matrix is singular to working precision"); */
    }
    
    mxFree(ipivot);
    mxFree(work);
    mxFree(iwork);
    break;
    
  default:
    mexErrMsgTxt("Should never get here");
  }

}

/* Wrapper function for LU decomposition.  Optionally checks
   singularity of result.  For efficiency, pass in the scratch
   buffers.  Result appears in-place.  See BLAS docs on DGETRF and
   DGECON for required scratch buffer sizes.  */
void compute_lu(double *X, int m, int *ipivot, double *work, int *iwork, int check_singular)
{
  double anorm, rcond;
  int info;
  char errmsg[255];
  
  anorm = compute_norm(X, m, m);
  BLASCALL(dgetrf)(&m, &m, X, &m, ipivot, &info); /* LU call */
  blas_return_check(info, "DGETRF");
  
  if(check_singular) {
    /* Check singularity */
    if(info>0)
      mexWarnMsgTxt("Matrix is singular to working precision");
    else {
      BLASCALL(dgecon)("1", &m, X, &m, &anorm, &rcond, work, iwork, &info);
      blas_return_check(info, "DGECON");
      
      if(rcond < eps) {
	sprintf(errmsg, "%s\n         %s RCOND = %e.",
		"Matrix is close to singular or badly scaled.",
		"Results may be inaccurate.", rcond);
	mexWarnMsgTxt(errmsg);
      }
    }
  }

} 

/* Check the INFO parameter of a BLAS call and error with a useful message if negative */
void blas_return_check(int info, const char *blasfcn)
{
  char errmsg[255];

  if(info < 0) {
    sprintf(errmsg, "Internal error: Illegal %s call, problem in arg %i", blasfcn, 
	    abs(info));
    mexErrMsgTxt(errmsg);
  }
}

double compute_norm(double *A, int m, int n)
{
  int i, j;
  double sum;
  double curmax = 0.0;

  for(j=0; j<n; j++) {
    sum = 0;
    for(i=0; i<m; i++) {
      sum += fabs(A[m*j + i]);
    }
    if(sum > curmax)
      curmax = sum;
  }
  return(curmax);
}
