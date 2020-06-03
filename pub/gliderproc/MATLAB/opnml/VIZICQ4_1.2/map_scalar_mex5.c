#include <math.h>
#include <stdio.h>
#include "mex.h"
#include "matrix.h"
#include "opnml_mex5_allocs.c" 
/* Array Access Definitions */
#define MN m*n
#define MNP m*n*p
#define ELE(i,j,m)             ele[i+m*j]
#define PHI(i,j,m)             phi[i+m*j]
#define JXY(i,j,m)             jxy[i+m*j]
#define SFEM(i,j,m)           sfem[i+m*j]        /*  SFEM(i,j,nn) */
#define FDZgrid(i,j,k,m,n) fdzgrid[i+m*j+m*n*k]  /*  FDZgrid(i,j,k,m,n) */
#define N1(i,j,k,m,n)           n1[i+m*j+m*n*k]  /*  N1(i,j,k,m,n) */
#define N2(i,j,k,m,n)           n2[i+m*j+m*n*k]  /*  N2(i,j,k,m,n) */
#define B1(i,j,k,m,n)           b1[i+m*j+m*n*k]  /*  B1(i,j,k,m,n) */
#define B2(i,j,k,m,n)           b2[i+m*j+m*n*k]  /*  B2(i,j,k,m,n) */
#define SFD(i,j,k,m,n)         sfd[i+m*j+m*n*k]  /*  SFD(i,j,k,m,n) */

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
   /*                    0   1  2  3  4    5     6      7    8  9
   /* S=map_scalar_mex5(phi,N1,N2,B1,B2,FDZgrid,zprof,scalar,e,jXY); */

   int m,n,p,i,j,k,ne,nn,nnv, *ele, *n1,*n2,*jxy;
   int node1,node2,node3,elem,lup,llow;
   double s_upper,s_lower;
   const int *dims;
   double *phi,*b1,*b2,*temp,*temp1,*temp2,*temp3,*dele,*djxy,*dN1,*dN2;
   double *sfem, *fdzgrid,*zprof,*sfd;
   double phi1,phi2,phi3;
   mxArray *S;
   double NaN=mxGetNaN();
   unsigned char *start_of_array;
   size_t bytes_to_copy;
   int number_of_dims; 

   /* get m,n,p from RHS arg #1 */
   dims = mxGetDimensions(prhs[1]);
   m=dims[0];n=dims[1];p=dims[2];

   /* phi is (m*n)X3 */
   temp=mxGetPr(prhs[0]);
   phi=(double *)mxDvector(0,3*m*n);
   for (i=0;i<3*MN;i++)
      phi[i]=temp[i];

   /* The scalar to be mapped is in prhs[10].  get nn,nnv,ne */
   nn=mxGetM(prhs[7]);   
   nnv=mxGetN(prhs[7]);   
   ne=mxGetM(prhs[8]); 

   /* Get the FEM-based scalar field */
   sfem=mxGetPr(prhs[7]);
   
/* ---- allocate space for int representation of dele &
        convert double element representation to int  &
        shift node numbers toward 0 by 1 for proper indexing -------- */
   dele=mxGetPr(prhs[8]);
   ele=(int *)mxIvector(0,3*ne);
   for (i=0;i<3*ne;i++){
      ele[i]=(int)dele[i];
      ele[i]=ele[i]-1;
   }

   djxy=mxGetPr(prhs[9]);
   jxy=(int *)mxIvector(0,MN*3);
   for (i=0;i<3*MN;i++){
      jxy[i]=(int)djxy[i];
      jxy[i]=jxy[i]-1;
   }

   /* N1,etc  is mXnXp */
   dN1=mxGetPr(prhs[1]);
   dN2=mxGetPr(prhs[2]);
   b1=mxGetPr(prhs[3]);  /* B1 */
   b2=mxGetPr(prhs[4]);  /* B2 */
   fdzgrid=mxGetPr(prhs[5]);  /* FDZgrid */
   n1=(int *)mxIvector(0,MNP);
   n2=(int *)mxIvector(0,MNP);
   for (i=0;i<MNP;i++){
      n1[i]=(int)dN1[i]-1;
      n2[i]=(int)dN2[i]-1;
   }

   
   /* Get the FD depth profile */
   zprof=mxGetPr(prhs[6]);

   S=mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL); 
   sfd=(double *)mxDvector(0,MNP);

   /* time to map the scalar fem-based field to the FD array */
   for (i=0;i<m;i++){
      for (j=0;j<n;j++){
         phi1=PHI(i+j*n,0,MN);
         phi2=PHI(i+j*n,1,MN);
         phi3=PHI(i+j*n,2,MN);
         elem=JXY(i,j,m);
         node1=ELE(elem,0,ne);
         node2=ELE(elem,1,ne);
         node3=ELE(elem,2,ne);
         if (mxIsNaN(FDZgrid(i,j,0,m,n))){
            for (k=0;k<p;k++)
               SFD(i,j,k,m,n)=NaN;  /* This is an "outside the domain" check!!*/
         }
         else {
            for (k=0;k<p;k++){
               if(zprof[k]<FDZgrid(i,j,0,m,n))
                  SFD(i,j,k,m,n)=NaN;
               else{
                  llow=N1(i,j,k,m,n);
                  if (llow==nnv-1)
                     SFD(i,j,k,m,n)=SFEM(node1,llow,nn)*phi1+ 
                                    SFEM(node2,llow,nn)*phi2+
                                    SFEM(node3,llow,nn)*phi3;
                  
		  else{
                     lup=N2(i,j,k,m,n);
                     s_upper=SFEM(node1,lup,nn)*phi1+ 
                             SFEM(node2,lup,nn)*phi2+
                             SFEM(node3,lup,nn)*phi3;
                     s_lower=SFEM(node1,llow,nn)*phi1+ 
                             SFEM(node2,llow,nn)*phi2+
                             SFEM(node3,llow,nn)*phi3;
                     SFD(i,j,k,m,n)=s_upper*B1(i,j,k,m,n) + s_lower*B2(i,j,k,m,n);
                  }
               }
            }
         } 
      }
   }

	 
   /* Set pointer to lhs */
   start_of_array=(unsigned char *)mxGetPr(S);
   bytes_to_copy=MNP*mxGetElementSize(S);
   memcpy(start_of_array,sfd,bytes_to_copy);
   plhs[0]=S;
   return;
}
