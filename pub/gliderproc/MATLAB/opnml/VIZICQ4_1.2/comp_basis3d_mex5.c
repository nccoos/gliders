#include <math.h>
#include <stdio.h>
#include "mex.h"
#include "matrix.h"
#include "opnml_mex5_allocs.c" 
/* Array Access Definitions */
#define MN m*n
#define MNP m*n*p
#define JXY(i,j,m)             jxy[i+m*j]
#define FDZGRID(i,j,k,m,n)     fdzgrid[i+m*j+m*n*k]  /*  FDZgrid(i,j,k,m,n) */
#define NN1(i,j,k,m,n)         N1[i+m*j+m*n*k]  /*  N1(i,j,k,m,n) */
#define NN2(i,j,k,m,n)         N2[i+m*j+m*n*k]  /*  N2(i,j,k,m,n) */
#define BB1(i,j,k,m,n)         B1[i+m*j+m*n*k]  /*  B1(i,j,k,m,n) */
#define BB2(i,j,k,m,n)         B2[i+m*j+m*n*k]  /*  B2(i,j,k,m,n) */
#define Z3D(i,j,k,m,n)         z3d[i+m*j+m*n*k] /*  Z3D(i,j,k,m,n) */

/* PROTOTYPES */
void basis1d2(double *,int,double,int,int,double,double);

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
   /*   0  1  2  3                       0     1   2    */
   /* [N1,B1,N2,B2]=comp_basis3d_mex5(FDZgrid,jXY,Z3D); */

   int i,j,k,l,nx,ny,nnv,*jxy,m,n,p,n1,n2;
   const int *dims;
   double *B1,*B2,b1,b2,*djxy,*N1,*N2;
   double *zref, *fdzgrid, *z3d;
   mxArray *NNN1,*NNN2,*BBB1,*BBB2;
   double NaN=mxGetNaN();
   unsigned char *start_of_array;
   size_t bytes_to_copy;
   int number_of_dims; 

   /* get nx,ny,nz from RHS arg #0 FDZgrid (nx X ny X nnv) */
   dims = mxGetDimensions(prhs[0]);
   nx=dims[0];ny=dims[1];nnv=dims[2];

   /* Deref the 3d vertical array Z3D */
   z3d=mxGetPr(prhs[2]);

   /* get m,n,p from RHS arg #2 (m X n X p) */
   dims = mxGetDimensions(prhs[2]);
   m=dims[0];n=dims[1];p=dims[2];

   djxy=mxGetPr(prhs[1]);
   jxy=(int *)mxIvector(0,MN*3);
   for (i=0;i<3*MN;i++){
      jxy[i]=(int)djxy[i];
      jxy[i]=jxy[i]-1;
   }

   N1=(double *)mxDvector(0,MNP-1);
   N2=(double *)mxDvector(0,MNP-1);
   B1=(double *)mxDvector(0,MNP-1);
   B2=(double *)mxDvector(0,MNP-1);

   fdzgrid=mxGetPr(prhs[0]);  /* FDZgrid */
   for (i=0;i<nx+1;i++){/*         waitbar((i-1)/nx) */
      for (j=0;j<ny+1;j++){
	 if (!mxIsNaN(JXY(i,j,nx))){
            zref=(double *)mxDvector(0,nnv-1);
	    for (l=0;l<nnv;l++)zref[l]=FDZGRID(i,j,l,m,n);
            for (k=0;k<p+1;k++){
               basis1d2(zref,nnv,Z3D(i,j,k,m,n),n1,n2,b1,b2);
               NN1(i,j,k,m,n)=(double)n1;
               BB1(i,j,k,m,n)=b1;
               NN2(i,j,k,m,n)=(double)n2;
               BB2(i,j,k,m,n)=b2;
	   }
	}
      }
   }

   /* Load the return arrays */
   
   /* Set pointer to lhs */
   start_of_array=(unsigned char *)mxGetPr(NNN1);
   bytes_to_copy=MNP*mxGetElementSize(NNN1);
   memcpy(start_of_array,N1,bytes_to_copy);
   plhs[0]=NNN1;
   start_of_array=(unsigned char *)mxGetPr(BBB1);
   bytes_to_copy=MNP*mxGetElementSize(BBB1);
   memcpy(start_of_array,B1,bytes_to_copy);
   plhs[1]=BBB1;
   start_of_array=(unsigned char *)mxGetPr(NNN2);
   bytes_to_copy=MNP*mxGetElementSize(NNN2);
   memcpy(start_of_array,N2,bytes_to_copy);
   plhs[2]=NNN2;
   start_of_array=(unsigned char *)mxGetPr(BBB2);
   bytes_to_copy=MNP*mxGetElementSize(BBB2);
   memcpy(start_of_array,B2,bytes_to_copy);
   plhs[3]=BBB2;
   
   return;
}


void basis1d2(double *zref,int nz,double zdes,int n1,int n2,double b1,double b2)
{

   double NaN=mxGetNaN();
   int k;
   double zdiff;

   for (k=0;k<nz;k++){
      if (zdes<zref[k]){
         n2=k;
         n1=k-1;
         if (n2==1){
            n1=nz;b1=0.;
            b2=1.0;n2=NaN;
            return;
         }
         zdiff=zref[n2]-zref[n1];
         b1=(zref[n2]-zdes)/zdiff;
         b2=(zdes-zref[n1])/zdiff;
         return;
      }
   }
   b1=1.0;n1=nz;b2=0.;n2=NaN;
   return;
}


/*
%***********************************************************************
%***********************************************************************
% function [b2,n2,b1,n1]=basis1d2(zref,zdes)
%-----------------------------------------------------------------------
% purpose: This subroutine evaluates the value of the basis functions 
%            alive on a 1-D linear element at a point
%
% restrictions: Applicable only for  1-D linear elements
%
% inputs:  nn is the number of entries in the reference z array
%          zref(nn) is the 1-D array containing the reference z array
%               NOTE: zref must increase from zref(1) to zref(nn)
%          zdes is the z value at which the basis functions are desired
%
% outputs: n1 is the reference node immediately below zdes
%          b1 is the value of the n1's basis function at zdes
%          n2 is the reference node immediately above zdes
%          b2 is the value of the n2's basis function at zdes
%
% notes:   zdes<zref(1)  => n1=NaN,b1=0.0,n2=1,b2=1.0 
%          zdes>zref(nn) => n1=nn,b1=1.0,n2=NaN,b2=0.0 
%
% history:  Written by Christopher E. Naimie
%           Dartmouth College
%           26 AUGUST 1992
%-----------------------------------------------------------------------
function [b2,n2,b1,n1]=basis1d1(zref,zdes)
%
zdiff=zref-zdes;nn=length(zref);
if zdiff(1) >= 0;
   n1=NaN;b1=0.0;n2=1;b2=1.0; 
elseif zdiff(length(zdiff)) <= 0;
   n1=nn;b1=1.0;n2=NaN;b2=0.0;
else
   zpast=find(zdiff<=0);
   n1=zpast(length(zpast));
   n2=n1+1;
   dz=zref(n2)-zref(n1);
   b1=(zref(n2)-zdes)/dz;
   b2=(zdes-zref(n1))/dz;
end   
%***********************************************************************
%***********************************************************************
*/
