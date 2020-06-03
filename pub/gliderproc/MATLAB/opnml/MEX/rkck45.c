/*  THIS MATLAB MEX FUNCTION PROVIDES AN INTERFACE TO THE 5TH-ORDER 
    CASH-KARP RUNGE-KUTTA EMBEDDED INTEGRATION SCHEME AS CODED BY
    NUMERICAL RECIPES IN C, 2ND ED.  SEE CHAPTER 16.
    
    The Numerical Recipes routines contain the following copyright line:
    (C) Copr. 1986-92 Numerical Recipes Software 3+)$!|9. 
     
    The lowest-level routine called is RKCK, which performs one integration
    over the (adjusted) stepsize.  Local error is controlled by RKQS, which 
    is called by RKCK45 (the mexfile) to perform the step [x1...x2] with 
    4/5 order error control.  RKCK45 controls the total integration from 
    starting time to ending time.
    
    RKCK45 -->>
                RKQS  -->>
                            RKCK

   The following ANSI-C prototype describes how the rkqs wrapper RKCK45
   is called, as suggested by NRC2.0.  This is what this MEX is emulating,
   and will look like the MATLAB call to MATLAB's ode45, with some additional
   RHS arguments.  We pass in the name of the m-file that 
   contains the slopes (derivatives), just like in MATLAB's ode23(45) routines.

   void odeint(char *derivs_name      name of m-file containing slopes
               double ystart[],       initial conditions 
               double x1,             starting integration time 
               double x2,             ending integration time 
               double eps,            acceptable tolerance 
               double h1,             trial (hopeful) stepsize 
               double hmin,           minimum accetable stepsize
               int iret)              number of wanted outputs
        
   TEST CALL:
	dname='dydx';
	ic=[0 0 0 .00131];
	t0=0.;
	tf=17.33*3600/2;
	err=1e-7;
	htry=900;
	hmin=1e-8;
	iret=1;
	[a,b,stat]=rkck45(dname,ic,t0,tf,err,htry,hmin,iret);

   dydx.m:
	function dydx = derivs(t,y)
	f=1e-4; 
	dydx(1) =    y(2);
	dydx(2) =  f*y(4);
	dydx(3) =    y(4);
	dydx(4) = -f*y(2);
	return
	
   a:    3.1194e+04
   b:    26.1968    0.0000    0.2907   -0.0013
   stat:  
         1.0e+04 * {0.0032
 		    0.0002
 		    0.0001
 		    3.1194
 			 0
 			 0
 			 0
 			 0
 			 0
 		    0.0004}



    Written by:
    BRIAN BLANTON
    UNIVERSITY OF NORTH CAROLINA AT CHAPEL HILL
    OCEAN PROCESSES NUMERICAL MODELING LABORATORY 
    SPRING 97

*/

#include <math.h>
#include <stdio.h>
#include "mex.h"
#include "opnml_mex5_allocs.c"
#define SIGN(a,b) ((b) >= 0.0 ? fabs(a) : -fabs(a))
static double dmaxarg1,dmaxarg2;
#define DMAX(a,b) (dmaxarg1=(a),dmaxarg2=(b),(dmaxarg1) > (dmaxarg2) ?\
        (dmaxarg1) : (dmaxarg2))
#define MAXSTP 10000
#define TINY 1.0e-30
#define SAFETY 0.9
#define PGROW -0.2
#define PSHRNK -0.25
#define ERRCON 1.89e-4

/************************************************************

                               #        #######
 #####   #    #   ####   #    # #    #  #
 #    #  #   #   #    #  #   #  #    #  #
 #    #  ####    #       ####   #    #  ######
 #####   #  #    #       #  #   #######       #
 #   #   #   #   #    #  #   #       #  #     #
 #    #  #    #   ####   #    #      #   #####
 
  ####     ##     #####  ######  #    #    ##     #   #
 #    #   #  #      #    #       #    #   #  #     # #
 #       #    #     #    #####   #    #  #    #     #
 #  ###  ######     #    #       # ## #  ######     #
 #    #  #    #     #    #       ##  ##  #    #     #
  ####   #    #     #    ######  #    #  #    #     #

************************************************************/

/* PROTOTYPES */
void rkqs(double [], 
          double [], 
          int, 
          double *, 
          double, 
          double, 
          double [],
	  double *, 
	  double *, 
	  char *);
void rkck(double [], 
          double [], 
          int, 
          double, 
          double,
          double [], 
          double [], 
          char *);
void help_fun();
void examp_fun();
void slopes_fun();
void stat_fun();
void disp_derivs(char *);

/* Gateway/Entry */
void mexFunction(int             nlhs,
                 mxArray        *plhs[],
                 int             nrhs,
                 const mxArray  *prhs[])
{


/* Declare RHS pointers; doubles for incoming from MATLAB, */
   double *dx1,*dx2,*deps,*dh1,*dhmin,*dname;          
   double *dkmax,*diret;
   int nok,nbad,nvar,kmax;
   
/* Declare LHS pointers */
   double *xpvec,*ypvec;
   double *stat;

/* Local declarations */
   double *xp,**yp;
   int i,idx,j,kount,m,n,nstp;
   double *ystart,x1,x2,eps,h1,hmin;          
   double xsav,x,hnext,hdid,h,dxsav;
   double *yscal,*y,*dydx;
   char *slopes;
   mxArray *slp_rhs[2],*slp_lhs[1];
   int errflag;

/* ---- check I/O arguments ----------------------------------------- */
   if (nrhs ==8){
      if (nlhs !=2 & nlhs != 3) 
         mexErrMsgTxt("rkck45 requires 2|3 output arguments.");

      /* First Matrix must contain a string */
      if (!mxIsChar(prhs[0]))
	  mexErrMsgTxt("RKCK45 must have string as first argument. HELP RKCK45");

      /* Dereference first incoming (RHS) pointer */
      /* Catch special calling options, like "help", "example", in first Matrix */
      dname=mxGetPr(prhs[0]);    
      m=mxGetN(prhs[0])+1;
      slopes=mxCalloc(m,sizeof(char));
      mxGetString(prhs[0],slopes,m);   
      /* Else, assume a valid mfile containing derivatives */



/* Dereference remaining incoming (RHS) pointers */
      ystart=mxGetPr(prhs[1])-1;   /* notice pointer decrement by 1 */
      /* check dimensions of initial condition vector */ 
      m=mxGetM(prhs[1]);
      n=mxGetN(prhs[1]);
      if(m*n != m & m*n != n )
	 mexErrMsgTxt("rkck45 requires initial conditions in vector form.");
      nvar=m*n;  

      dx1=mxGetPr(prhs[2]);x1=dx1[0];
      dx2=mxGetPr(prhs[3]);x2=dx2[0];
      deps=mxGetPr(prhs[4]);eps=deps[0];
      dh1=mxGetPr(prhs[5]);h1=dh1[0];
      dhmin=mxGetPr(prhs[6]);hmin=dhmin[0];
      diret=mxGetPr(prhs[7]);kmax=(int)diret[0];
      if(kmax)dxsav=(x2-x1)/diret[0];
      else dxsav=1;

      /* Local Allocations */
      yscal =(double *)  mxDvector(1,nvar);
      y     =(double *)  mxDvector(1,nvar);
      dydx  =(double *)  mxDvector(1,nvar);
      xp    =(double *)  mxDvector(1,MAXSTP);
      yp    =(double **) mxDmatrix(1,MAXSTP,1,nvar);
      stat  =(double *)  mxDvector(0,4);

      x=x1;
      h=SIGN(h1,x2-x1);
      nok = nbad = kount = 0;
      for (i=1;i<=nvar;i++) y[i]=ystart[i];
      if (kmax > 0) xsav=x-dxsav*2.0;            /* Assure storage of first step */
      mexSetTrapFlag(1);                         /* Disable exit-on-error behavior */

      for (nstp=1;nstp<=MAXSTP;nstp++) {         /* No more that MAXSTP steps */

/* Allocate Matrix structs for callback to MATLAB for derivatives */
	 slp_rhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);    
	 slp_rhs[1]=mxCreateDoubleMatrix(1,nvar,mxREAL);  
	 slp_lhs[0]=mxCreateDoubleMatrix(1,nvar,mxREAL);
	 mxSetPr(slp_rhs[0],&x);
	 mxSetPr(slp_rhs[1],y+1); 
	 if (mexCallMATLAB(1,slp_lhs,2,slp_rhs,slopes))      /* Get starting slopes */
	     mexErrMsgTxt("call to mexCallMATLAB failed.");
	 dydx=mxGetPr(slp_lhs[0])-1; 

/* Scaling used for accuracy monitoring */      
	 for (i=1;i<=nvar;i++) yscal[i]=fabs(y[i])+fabs(dydx[i]*h)+TINY;
	 if (kmax > 0 && kount < kmax-1 && fabs(x-xsav) > fabs(dxsav)) {
            xp[++kount]=x;
            for (i=1;i<=nvar;i++) yp[kount][i]=y[i];
            xsav=x;
	 }
	 if ((x+h-x2)*(x+h-x1) > 0.0) h=x2-x;
	 (*rkqs)(y,dydx,nvar,&x,h,eps,yscal,&hdid,&hnext,slopes);
	 if (hdid == h) ++(nok); else ++(nbad);
	 if ((x-x2)*(x2-x1) >= 0.0) {
            for (i=1;i<=nvar;i++) ystart[i]=y[i];
	    if (kmax) {
               xp[++kount]=x;
               for (i=1;i<=nvar;i++) yp[kount][i]=y[i];

	     /* This is where we need to store the intermediate
        	results into the outgoing Matrices */
	     /* Create output matrices */
               plhs[0]=mxCreateDoubleMatrix(kount,1,mxREAL);     /* xp -> Matrix* plhs[0] */
               plhs[1]=mxCreateDoubleMatrix(kount,nvar,mxREAL);  /* yp -> Matrix* plhs[1] */
               if(nlhs==3){
        	  plhs[2]=mxCreateDoubleMatrix(5,1,mxREAL);     /* status -> Matrix* plhs[1] */
        	  stat[0]=nok;
        	  stat[1]=nbad;
        	  stat[2]=kount;
        	  stat[3]=dxsav;
        	  stat[4]=nvar;
        	  mxSetPr(plhs[2],stat);           
               }
               xpvec=(double *) mxDvector(0,kount-1);
               ypvec=(double *) mxDvector(0,kount*nvar-1);

               for (i=1;i<=kount;i++)xpvec[i-1]=xp[i];

               for (j=1;j<=nvar;j++){
        	  for (i=1;i<=kount;i++){
        	     idx=(j-1)*kount+i-1;
        	     ypvec[idx]=yp[i][j];
        	  }
               }
               mxSetPr(plhs[0],xpvec);
               mxSetPr(plhs[1],ypvec);
	    }
	    else {
               plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);     /* xp -> Matrix* plhs[0] */
               plhs[1]=mxCreateDoubleMatrix(1,nvar,mxREAL);  /* yp -> Matrix* plhs[1] */
               xpvec=(double *)mxDvector(0,0);
               xpvec[0]=x;
               ypvec=(double *)mxDvector(0,nvar-1);       
               for (j=1;j<=nvar;j++)ypvec[j-1]=y[j];
               mxSetPr(plhs[0],xpvec);
               mxSetPr(plhs[1],ypvec);
               if(nlhs==3){
        	  plhs[2]=mxCreateDoubleMatrix(5,1,mxREAL);     /* status -> Matrix* plhs[1] */
        	  stat[0]=nok;
        	  stat[1]=nbad;
        	  stat[4]=nvar;
        	  mxSetPr(plhs[2],stat);           
               }
	    }
	 return;
	 }
	 if (fabs(hnext) <= hmin) {
            fprintf(stderr,"Next Stepsize (%e) exceeds Minimum (%e)\n",hnext,hmin);
            mexErrMsgTxt("Step size too small in RKCK45");
	 }
	 h=hnext;
      }
      mexErrMsgTxt("Too many steps in routine odeint");
   }
   else if(nrhs==1)
   {
      /* First Matrix must contain a string */
      if (!mxIsChar(prhs[0]))
	  mexErrMsgTxt("RKCK45 must have string as first argument. HELP RKCK45");
      /* Get option from prhs[0] and process */
      dname=mxGetPr(prhs[0]);    
      m=mxGetN(prhs[0])+1;
      slopes=mxCalloc(m,sizeof(char));
      mxGetString(prhs[0],slopes,m);   
      if(strcmp(slopes,"help")==0)help_fun();
      else if(strcmp(slopes,"example")==0)examp_fun();
      else if(strcmp(slopes,"slopes")==0)slopes_fun();
      else if(strcmp(slopes,"stat")==0)stat_fun();
      else 
      {
         /* Try to determine if the value of "slopes" points to a valid mfile */
         mxArray *xrhs[1],*xlhs[1];
         double *derr;
         int err;
         puts(slopes);
	 xrhs[0]=mxCreateString(slopes);    
	 xlhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
	 mexCallMATLAB(1,xlhs,1,xrhs,"exist");         /* Probe Matlab  */
         derr=mxGetPr(xlhs[0]);
         err=(int)derr[0];
         if(err==2)
            disp_derivs(slopes);
         else 
            mexErrMsgTxt("Unrecognized first argument to RKCK45");
      }
      
   }
   else
         mexErrMsgTxt("RKCK45 requires 1|8 input (RHS) arguments");    
}

void rkqs(double y[], double dydx[], int n, 
          double *x, double htry, double eps,
          double yscal[], double *hdid, 
          double *hnext,char *slopes)
{
   int i;
   double errmax,h,xnew,*yerr,*ytemp;
   yerr=mxDvector(1,n);
   ytemp=mxDvector(1,n);
   h=htry;
   for (;;) {
      rkck(y,dydx,n,*x,h,ytemp,yerr,slopes);
      errmax=0.0;
      for (i=1;i<=n;i++) errmax=DMAX(errmax,fabs(yerr[i]/yscal[i]));
      errmax /= eps;
      if (errmax > 1.0) {
         h=SAFETY*h*pow(errmax,PSHRNK);
         if (h < 0.1*h) h *= 0.1;
         xnew=(*x)+h;
         if (xnew == *x) mexErrMsgTxt("stepsize underflow in rkqs");
         continue;
      } else {
         if (errmax > ERRCON) *hnext=SAFETY*h*pow(errmax,PGROW);
         else *hnext=5.0*h;
         *x += (*hdid=h);
         for (i=1;i<=n;i++) y[i]=ytemp[i];
         break;
      }
   }
}

void rkck(double y[], double dydx[], int n, 
          double x, double h, double yout[],
          double yerr[],char *slopes)
{
   int i;
   static double a2=0.2,a3=0.3,a4=0.6,a5=1.0,a6=0.875,b21=0.2,
      b31=3.0/40.0,b32=9.0/40.0,b41=0.3,b42 = -0.9,b43=1.2,
      b51 = -11.0/54.0, b52=2.5,b53 = -70.0/27.0,b54=35.0/27.0,
      b61=1631.0/55296.0,b62=175.0/512.0,b63=575.0/13824.0,
      b64=44275.0/110592.0,b65=253.0/4096.0,c1=37.0/378.0,
      c3=250.0/621.0,c4=125.0/594.0,c6=512.0/1771.0,
      dc5 = -277.0/14336.0;
   double dc1=c1-2825.0/27648.0,dc3=c3-18575.0/48384.0,
      dc4=c4-13525.0/55296.0,dc6=c6-0.25;
   double *ak2,*ak3,*ak4,*ak5,*ak6,*ytemp;
   mxArray *slp_rhs[2],*slp_lhs[1];
   double x2,x3,x4,x5,x6;

   x2=x+a2*h;
   x3=x+a3*h;
   x4=x+a4*h;
   x5=x+a5*h;
   x6=x+a6*h;

   slp_rhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
   slp_rhs[1]=mxCreateDoubleMatrix(1,n,mxREAL);
   slp_lhs[0]=mxCreateDoubleMatrix(1,n,mxREAL);
   ak2=mxDvector(1,n);
   ak3=mxDvector(1,n);
   ak4=mxDvector(1,n);
   ak5=mxDvector(1,n);
   ak6=mxDvector(1,n);
   ytemp=mxDvector(1,n);
   mxSetPr(slp_rhs[1],ytemp+1); 
   
   for (i=1;i<=n;i++)
      ytemp[i]=y[i]+b21*h*dydx[i];  
      
   mxSetPr(slp_rhs[0],&x2);
   if (mexCallMATLAB(1,slp_lhs,2,slp_rhs,slopes))
       mexErrMsgTxt("call to mexCallMATLAB failed.");
   ak2=mxGetPr(slp_lhs[0])-1; 
   for (i=1;i<=n;i++)
      ytemp[i]=y[i]+h*(b31*dydx[i]+b32*ak2[i]);
      
   mxSetPr(slp_rhs[0],&x3);
   if (mexCallMATLAB(1,slp_lhs,2,slp_rhs,slopes))
       mexErrMsgTxt("call to mexCallMATLAB failed.");
   ak3=mxGetPr(slp_lhs[0])-1; 
   for (i=1;i<=n;i++)
      ytemp[i]=y[i]+h*(b41*dydx[i]+b42*ak2[i]+b43*ak3[i]);
      
   mxSetPr(slp_rhs[0],&x4);
   if (mexCallMATLAB(1,slp_lhs,2,slp_rhs,slopes))
       mexErrMsgTxt("call to mexCallMATLAB failed.");
   ak4=mxGetPr(slp_lhs[0])-1; 
   for (i=1;i<=n;i++)
      ytemp[i]=y[i]+h*(b51*dydx[i]+b52*ak2[i]+b53*ak3[i]+b54*ak4[i]);
      
   mxSetPr(slp_rhs[0],&x5);
   if (mexCallMATLAB(1,slp_lhs,2,slp_rhs,slopes))
       mexErrMsgTxt("call to mexCallMATLAB failed.");
   ak5=mxGetPr(slp_lhs[0])-1; 
   for (i=1;i<=n;i++)
      ytemp[i]=y[i]+h*(b61*dydx[i]+b62*ak2[i]+b63*ak3[i]+b64*ak4[i]+b65*ak5[i]);
      
   mxSetPr(slp_rhs[0],&x6);
   if (mexCallMATLAB(1,slp_lhs,2,slp_rhs,slopes))
       mexErrMsgTxt("call to mexCallMATLAB failed.");
   ak6=mxGetPr(slp_lhs[0])-1; 
   for (i=1;i<=n;i++)
      yout[i]=y[i]+h*(c1*dydx[i]+c3*ak3[i]+c4*ak4[i]+c6*ak6[i]);
      
   for (i=1;i<=n;i++)
      yerr[i]=h*(dc1*dydx[i]+dc3*ak3[i]+dc4*ak4[i]+dc5*ak5[i]+dc6*ak6[i]);
}

void help_fun()
{
   fprintf(stderr,"\n");
   fprintf(stderr,"      This is the HELP page for RKCK45\n");
   fprintf(stderr,"      See Numerical Recipes in C, 2nd Ed.\n");
   fprintf(stderr,"      Chapter 16, Sections 1 and 2.\n");
   fprintf(stderr,"\n");
   
}

void stat_fun()
{
   fprintf(stderr,"      This is the STAT page for RKCK45\n");
   fprintf(stderr,"\n");
   fprintf(stderr,"      The 'stat' return variable is optional.\n");   
   fprintf(stderr,"      If returned, it contains the following entries:\n");
   fprintf(stderr,"         stat(1)  ->  Number of successful timesteps (nok)\n");   
   fprintf(stderr,"         stat(2)  ->  Number of unsuccessful timesteps (nbad)\n"); 
   fprintf(stderr,"         stat(3)  ->  Number of intermediate results returned\n"); 
   fprintf(stderr,"         stat(4)  ->  Output interval, not really useful.\n"); 
   fprintf(stderr,"         stat(5)  ->  Number of equations\n"); 
   fprintf(stderr,"\n");
}

void examp_fun()
{
   fprintf(stderr,"      This is the EXAMPLE page for RKCK45\n");
   fprintf(stderr,"\n");
   fprintf(stderr,"      The following example is actually the integration of\n");
   fprintf(stderr,"      the equations of motion describing the translation of\n");
   fprintf(stderr,"      a particle on a rotating, frictionless plane.  How about\n");
   fprintf(stderr,"      a hockey puck struck with sufficient velocity (m/s) to\n");
   fprintf(stderr,"      maintain an inertial circle within a hockey rink 26 m\n");
   fprintf(stderr,"      wide in Savannah, Georgia.\n");
   fprintf(stderr,"\n");
   fprintf(stderr,"      Given the following derivatives mfile dydx.m:\n");
   fprintf(stderr,"\n");
   fprintf(stderr,"          function dydx = derivs(t,y)\n");
   fprintf(stderr,"          f=7.7368e-05;    /* Coriolis */\n");
   fprintf(stderr,"          dydx(1) =    y(2);\n");
   fprintf(stderr,"          dydx(2) =  f*y(4);\n");
   fprintf(stderr,"          dydx(3) =    y(4);\n");
   fprintf(stderr,"          dydx(4) = -f*y(2);\n");
   fprintf(stderr,"          return\n");
   fprintf(stderr,"\n");
   
   fprintf(stderr,"       and the following parameters:\n");        
   fprintf(stderr,"          dname='dydx';	  /* Name of derivatives mfile */\n");
   fprintf(stderr,"          ic=[0 0 0 .00101];   /* Xo,Uo,Yo,Vo */\n");
   fprintf(stderr,"          t0=0.;\n");
   fprintf(stderr,"          tf=22.5587*3600/2;   /* This is .5*T_inertial */\n");
   fprintf(stderr,"          err=1e-7;\n");
   fprintf(stderr,"          htry=90;		  /* Desired stepsize */\n");
   fprintf(stderr,"          hmin=1e-8; 	  /* Minimum acceptable stepsize */\n");
   fprintf(stderr,"          iret=25;		  /* Keep at most 25 intermediate results */\n");
   fprintf(stderr,"\n");
        
   fprintf(stderr,"       the following call:\n");        
   fprintf(stderr,"          [a,b,stat]=rkck45(dname,ic,t0,tf,err,htry,hmin,iret);\n");
   fprintf(stderr,"\n");
   
   fprintf(stderr,"       produces these results:\n");
        
   fprintf(stderr,"          a=    4.0606e+04\n");
   fprintf(stderr,"          b=    26.1090    0.0000    0.0002   -0.0010\n");
   fprintf(stderr,"          stat=  \n");
   fprintf(stderr,"                1.0e+04 * 0.0027\n");
   fprintf(stderr,"                          0.0002\n");
   fprintf(stderr,"                          0.0001\n");
   fprintf(stderr,"                          4.0606\n");
   fprintf(stderr,"                          0.0004\n");
   fprintf(stderr,"\n");
}
void slopes_fun()
{
   fprintf(stderr,"\n");
   fprintf(stderr,"   This is the SLOPES help for RKCK45\n");
   fprintf(stderr,"   Example derivatives mfile called dydx.m:\n");
   fprintf(stderr,"\n");
   fprintf(stderr,"	function dydx = derivs(t,y)\n");
   fprintf(stderr,"	f=1e-4; \n");
   fprintf(stderr,"	dydx(1) =    y(2);\n");
   fprintf(stderr,"	dydx(2) =  f*y(4);\n");
   fprintf(stderr,"	dydx(3) =    y(4);\n");
   fprintf(stderr,"	dydx(4) = -f*y(2);\n");
   fprintf(stderr,"	return\n");
   fprintf(stderr,"\n");
   
}
void disp_derivs(char *slopes)
{
   mxArray *xrhs[1],*xlhs[1];
   double *derr;
   int err;
   xrhs[0]=mxCreateString(slopes);    
   xlhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
   fprintf(stderr,"\n");
   fprintf(stderr,"   Your designated derivatives file looks like:\n");
   
   mexCallMATLAB(0,xlhs,1,xrhs,"type");         /* Probe Matlab  */
   
}
#undef SAFETY
#undef PGROW
#undef PSHRNK
#undef ERRCON
