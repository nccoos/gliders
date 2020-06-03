#include <math.h> 
#include <stdio.h> 
#include "mex.h" 
#include "opnml_mex5_allocs.c" 
#define ELE(i,j,m) ele[i+m*j]



/* PROTOTYPES */
#ifdef __STDC__
void comp_bwidth(int,int *,int *);
void bandmsolve_c(int,
                  double **,
                  double *,
                  int,
                  int);
void grad_assem_lhs(int nn,
          int ne,
	  int nbw,
          double *x,
          double *y,
          int *ele,
	  double **lhs);
void grad_assem_rhs(int nn,
          int ne,
	  int nbw,
          double *x,
          double *y,
          int *ele,
          double *q,
          double *grax,
          double *gray);

#endif

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
   int i,j,nn,ne,nbw,nh,LHSout,NeedLHS;
   double *x,*y,*q,*dele,*dqdx,*dqdy;
   double **lhs;
   int *ele;
   double *temp,*LHS,*lhstemp;
   
/* ---- gradmex5 will be called as :
        [dqdx,dqdy,LHSout]=gradmex5(x,y,ele,q,LHS); 
                                      ------------------------------- */
 /* ---- check I/O arguments ----------------------------------------- */
   if (nrhs != 5) 
      mexErrMsgTxt("gradmex5 requires 5 input arguments.");
   else if (nlhs != 3) 
      mexErrMsgTxt("gradmex5 requires 3 output arguments.");

/* ---- dereference input arrays ------------------------------------ */
   x=mxGetPr(prhs[0]);
   y=mxGetPr(prhs[1]);
   dele=mxGetPr(prhs[2]);
   q=mxGetPr(prhs[3]);
   LHS=mxGetPr(prhs[4]);
   nn=mxGetM(prhs[0]);
   ne=mxGetM(prhs[2]);
   fprintf(stderr,"NN=%d NE=%d\n",nn,ne);   

   if (LHS[0]==1. & LHS[1]==0. & LHS[2]==1. & LHS[3]==1.)
      NeedLHS=1;
   else
      NeedLHS=0;
   
/* ---- allocate space for int representation of dele &
        convert double element representation to int  &
        shift node numbers toward 0 by 1 for proper indexing -------- */
   ele=(int *)mxIvector(0,3*ne);
   for (i=0;i<3*ne;i++){
      ele[i]=(int)dele[i];
      ele[i]=ele[i]-1;
   }
  
/* ---- get bandwidth ----------------------------------------------- */
   comp_bwidth(ne,ele,&nbw);
   nh=(nbw-1)/2;  
   fprintf(stderr,"BW,HBW,NeedLHS = %d %d %d\n",nbw,nh,NeedLHS);

/* ---- allocate space for gradient lists  following 
        NRC allocation style                            ------------- */
   dqdx = (double *)  mxDvector(0,nn-1);
   dqdy = (double *)  mxDvector(0,nn-1);
   
/* ---- Allocate, assemble, and triangularize LHS, if needed */   
   lhs = (double **) mxDmatrix(0,nbw-1,0,nn-1);
   if (NeedLHS){
      grad_assem_lhs(nn,ne,nbw,x,y,ele,lhs);
      bandmsolve_c(0,lhs,dqdx,nn,nh);
      puts("LHS triangularized");
   }
   else{
      for (i=0;i<nn;i++)
         for (j=0;j<nbw;j++)
            lhs[j][i]=LHS[i*nbw+j];       
   }
   
   grad_assem_rhs(nn,ne,nbw,x,y,ele,q,dqdx,dqdy);
   
   puts("Backsolving for gradient");   
   bandmsolve_c(1,lhs,dqdx,nn,nh);
   bandmsolve_c(1,lhs,dqdy,nn,nh);
   
   puts("Done.");

/* ---- Set elements of return matricies, 
        pointed to by plhs[0] & plhs[1] 
                                        ----------------------------- */
   plhs[0]=mxCreateDoubleMatrix(nn,1,mxREAL); 
   mxSetPr(plhs[0],dqdx);
   plhs[1]=mxCreateDoubleMatrix(nn,1,mxREAL); 
   mxSetPr(plhs[1],dqdy);
   plhs[2]=mxCreateDoubleMatrix(nbw,nn,mxREAL); 
   lhstemp=(double *)  mxDvector(0,nbw*nn-1);
   for (i=0;i<nn;i++)
         for (j=0;j<nbw;j++)
            lhstemp[i*nbw+j]=lhs[j][i];
	    
   mxSetPr(plhs[2],lhstemp);

/* --- No need to free memory allocated with "mxCalloc"; MATLAB 
   does this automatically.  The CMEX allocation functions in 
   "opnml_mex5_allocs.c" use mxCalloc. ------------------------------ */    
    
   return;

}


/*----------------------------------------------------------------------

  ####   #####     ##    #####
 #    #  #    #   #  #   #    #
 #       #    #  #    #  #    #
 #  ###  #####   ######  #    #
 #    #  #   #   #    #  #    #
  ####   #    #  #    #  #####
 
----------------------------------------------------------------------*/

void grad_assem_rhs(int nn,int ne,int nbw,
          double *x, 
          double *y,
          int *ele,
          double *q, 
          double *grax,
          double *gray)

{
   double *ar,**av,**dx,**dy;
   double area6,area12;
   int i,j,l,m,n;

/* ---- ALLOCATE space for dx, dy, ar, av and dv -------------------- */
   ar = (double *)  mxDvector(0,ne-1);
   dx = (double **) mxDmatrix(0,2,0,ne-1);
   dy = (double **) mxDmatrix(0,2,0,ne-1);   
            
/* ---- Compute dx,dy and element areas ----------------------------- */
   for(l=0;l<ne;l++){
      dx[0][l]=x[ELE(l,1,ne)]-x[ELE(l,2,ne)];
      dx[1][l]=x[ELE(l,2,ne)]-x[ELE(l,0,ne)];
      dx[2][l]=x[ELE(l,0,ne)]-x[ELE(l,1,ne)];
      dy[0][l]=y[ELE(l,1,ne)]-y[ELE(l,2,ne)];
      dy[1][l]=y[ELE(l,2,ne)]-y[ELE(l,0,ne)];
      dy[2][l]=y[ELE(l,0,ne)]-y[ELE(l,1,ne)];
      ar[l]=.5*(x[ELE(l,0,ne)]*dy[0][l]+
                x[ELE(l,1,ne)]*dy[1][l]+
                x[ELE(l,2,ne)]*dy[2][l]);      
   }
   
/* ---- Assemble RHS (grax,gray) ------------------------------------ */
   for(l=0;l<ne;l++){
      for(j=0;j<3;j++){
         m=ELE(l,j,ne);
         for(i=0;i<3;i++){
            grax[m]+=q[ELE(l,i,ne)]*dy[i][l]/(double)6.;
            gray[m]-=q[ELE(l,i,ne)]*dx[i][l]/(double)6.;
         }
      }
   }
   puts("RHS (dqdx,dqdy) assembled");

}


void grad_assem_lhs(int nn,int ne,int nbw,
          double *x, 
          double *y,
          int *ele,
          double **av)

{
   double *ar,**dx,**dy;
   double area6,area12;
   int i,j,l,m,n,nh;

   nh=(nbw-1)/2;
   
/* ---- ALLOCATE local space for dx, dy, ar  -------------------- */
   ar = (double *)  mxDvector(0,ne-1);
   dx = (double **) mxDmatrix(0,2,0,ne-1);
   dy = (double **) mxDmatrix(0,2,0,ne-1);   
            
/* ---- Compute dx,dy and element areas ----------------------------- */
   for(l=0;l<ne;l++){
      dx[0][l]=x[ELE(l,1,ne)]-x[ELE(l,2,ne)];
      dx[1][l]=x[ELE(l,2,ne)]-x[ELE(l,0,ne)];
      dx[2][l]=x[ELE(l,0,ne)]-x[ELE(l,1,ne)];
      dy[0][l]=y[ELE(l,1,ne)]-y[ELE(l,2,ne)];
      dy[1][l]=y[ELE(l,2,ne)]-y[ELE(l,0,ne)];
      dy[2][l]=y[ELE(l,0,ne)]-y[ELE(l,1,ne)];
      ar[l]=.5*(x[ELE(l,0,ne)]*dy[0][l]+
                x[ELE(l,1,ne)]*dy[1][l]+
                x[ELE(l,2,ne)]*dy[2][l]);      
   }
   
/* ---- Assemble LHS (av) ------------------------------------------- */
   for(l=0;l<ne;l++){
      area6=ar[l]/(double)6.;
      area12=ar[l]/(double)12.;
      for(j=0;j<3;j++){
         m=ELE(l,j,ne);
         for(i=0;i<3;i++){
            n=nh+ELE(l,i,ne)-ELE(l,j,ne);
            if(i==j) av[n][m]+=area6;
            else     av[n][m]+=area12;      
         }
      }
   }
   puts("LHS (av) assembled");
   return;     
}

void comp_bwidth(int ne,int *ele,int *nbw)
{
   int i, l01,l02,l12,nhm,nh;
/* ---- Compute half bandwidth -------------------------------------- */
   for (i=0;i<ne;i++){
      l01=abs(ELE(i,0,ne)-ELE(i,1,ne));
      l02=abs(ELE(i,0,ne)-ELE(i,2,ne));
      l12=abs(ELE(i,1,ne)-ELE(i,2,ne));
      nhm=IMAX(l01,IMAX(l02,l12));  
      nh=IMAX(nh,nhm);    
   }
   *nbw=2*nh+1;
}
