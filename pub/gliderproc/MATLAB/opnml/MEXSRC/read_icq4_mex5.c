#include <math.h>
#include <stdio.h>
#include "mex.h"
#include "opnml_mex5_allocs.c"
#define BUFFER_SIZE 72

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

/* ---- read_icq4_mex will be called as :
        [HMID, UMID, VMID, HOLD, UOLD, VOLD,...
         ZMID,  ZOLD, UZMID ,VZMID, WZMID, ...
         Q2MID, Q2LMID, TMPMID, SALMID]=read_icq4(icq4name,nn,nnv); 
        
        I/O argument count has already been checked in the calling
        routine, read_ucd.  The input filename will have to be
        checked here, though. 
                                             ------------------------ */

   double *temp;
   double *temp1, *temp2, *temp3, *temp4, *temp5, *temp6;
   double *temp7, *temp8, *temp9;
   double *temp10, *temp11, *temp12,*temp13, *temp14, *temp15;

   int nn,nnv,i,j;
   int errflag,strlen,itrash,tcomp,ncomp,*ncompcomp;
   char *icq4name, *line;
   FILE *fp=NULL, *fopen();
   
/* ---- extract input filename from first pointer to RHS  
                              --------------------------------------- */  
   strlen=mxGetN(prhs[0])+1;
   icq4name=mxCalloc(strlen,sizeof(char));
   if (mxGetString(prhs[0],icq4name,strlen)==1)
      fprintf(stderr,"Input filename string extraction failed in READ_ICQ4_MEX.");

/* get nn,nnv from RHS */
   temp=mxGetPr(prhs[1]);
   nn=(int)temp[0];
   temp=mxGetPr(prhs[2]);
   nnv=(int)temp[0];
      
/* ---- Open UCD filename ------------------------------------------- */
   if (!(fp = fopen(icq4name,"r"))){
      fprintf(stderr,"Open of %s failed.\n",icq4name);
      /* Allocate the return matricies as empty [] */
      plhs[0]=mxCreateDoubleMatrix(0,0,mxREAL);
      plhs[1]=mxCreateDoubleMatrix(0,0,mxREAL); 
      plhs[2]=mxCreateDoubleMatrix(0,0,mxREAL); 
      plhs[3]=mxCreateDoubleMatrix(0,0,mxREAL); 
      plhs[4]=mxCreateDoubleMatrix(0,0,mxREAL); 
      plhs[5]=mxCreateDoubleMatrix(0,0,mxREAL);
      plhs[6]=mxCreateDoubleMatrix(0,0,mxREAL);
      plhs[7]=mxCreateDoubleMatrix(0,0,mxREAL);
      plhs[8]=mxCreateDoubleMatrix(0,0,mxREAL);
      plhs[9]=mxCreateDoubleMatrix(0,0,mxREAL);
      plhs[10]=mxCreateDoubleMatrix(0,0,mxREAL);
      plhs[11]=mxCreateDoubleMatrix(0,0,mxREAL);
      plhs[12]=mxCreateDoubleMatrix(0,0,mxREAL);
      plhs[13]=mxCreateDoubleMatrix(0,0,mxREAL);
      plhs[14]=mxCreateDoubleMatrix(0,0,mxREAL);
      return;
   }

   line=mxCalloc(BUFFER_SIZE,sizeof(char));
   for(i=0;i<6;i++)
      fgets(line,BUFFER_SIZE,fp);  


/* ---- Allocate space for x,y,z ------------------------------------ */
   plhs[0]=mxCreateDoubleMatrix(1,nn,mxREAL);
   plhs[1]=mxCreateDoubleMatrix(1,nn,mxREAL);
   plhs[2]=mxCreateDoubleMatrix(1,nn,mxREAL);
   plhs[3]=mxCreateDoubleMatrix(1,nn,mxREAL);
   plhs[4]=mxCreateDoubleMatrix(1,nn,mxREAL);
   plhs[5]=mxCreateDoubleMatrix(1,nn,mxREAL);
   plhs[6]=mxCreateDoubleMatrix(1,nn*nnv,mxREAL);
   plhs[7]=mxCreateDoubleMatrix(1,nn*nnv,mxREAL);
   plhs[8]=mxCreateDoubleMatrix(1,nn*nnv,mxREAL);
   plhs[9]=mxCreateDoubleMatrix(1,nn*nnv,mxREAL);
   plhs[10]=mxCreateDoubleMatrix(1,nn*nnv,mxREAL);
   plhs[11]=mxCreateDoubleMatrix(1,nn*nnv,mxREAL);
   plhs[12]=mxCreateDoubleMatrix(1,nn*nnv,mxREAL);
   plhs[13]=mxCreateDoubleMatrix(1,nn*nnv,mxREAL);
   plhs[14]=mxCreateDoubleMatrix(1,nn*nnv,mxREAL);

   temp1= (double *) mxDvector(0,nn-1);
   temp2= (double *) mxDvector(0,nn-1);
   temp3= (double *) mxDvector(0,nn-1); 
   temp4= (double *) mxDvector(0,nn-1);
   temp5= (double *) mxDvector(0,nn-1);
   temp6= (double *) mxDvector(0,nn-1); 
   
   for(i=0;i<nn;i++)
      fscanf(fp,"%lf %lf %lf %lf %lf %lf",&temp1[i],&temp2[i],
                                          &temp3[i],&temp4[i],
                                          &temp5[i],&temp6[i]);

   mxSetPr(plhs[0],temp1);
   mxSetPr(plhs[1],temp2);
   mxSetPr(plhs[2],temp3);
   mxSetPr(plhs[3],temp4);
   mxSetPr(plhs[4],temp5);
   mxSetPr(plhs[5],temp6);

   temp7= (double *) mxDvector(0,nn*nnv-1);
   temp8= (double *) mxDvector(0,nn*nnv-1);
   temp9= (double *) mxDvector(0,nn*nnv-1); 
   temp10= (double *) mxDvector(0,nn*nnv-1);
   temp11= (double *) mxDvector(0,nn*nnv-1);
   temp12= (double *) mxDvector(0,nn*nnv-1); 
   temp13= (double *) mxDvector(0,nn*nnv-1);
   temp14= (double *) mxDvector(0,nn*nnv-1);
   temp15= (double *) mxDvector(0,nn*nnv-1); 

   for(i=0;i<nn*nnv;i++)
      fscanf(fp,"%lf %lf %lf %lf %lf %lf %lf %lf %lf",&temp7[i],&temp8[i],
                                          &temp9[i],&temp10[i],
                                          &temp11[i],&temp12[i],
                                          &temp13[i],&temp14[i],&temp15[i]);
   mxSetPr(plhs[6],temp7);
   mxSetPr(plhs[7],temp8);
   mxSetPr(plhs[8],temp9);
   mxSetPr(plhs[9],temp10);
   mxSetPr(plhs[10],temp11);
   mxSetPr(plhs[11],temp12);
   mxSetPr(plhs[12],temp13);
   mxSetPr(plhs[13],temp14);
   mxSetPr(plhs[14],temp15);

   
   fclose(fp);
/* No "frees" needed if arrays allocated with "mx" allocation routines */
   return;
}
/*-----------------------------------------------------*
 *                                                     *
 *               ****  get_token  ****                 *
 *                                                     *
 * returns the next value in tline[] separated by a    *
 * blank.                                              *
 *-----------------------------------------------------*/

int get_token(char **tline, char *data,char  *control)
{

  char *line, token[80], c;

  int ntc;

  c = 0;
  line = *tline;

  for (ntc = 0; c != '\n'; line++) {
    if (((c  = *line) != ' ') && (c != '\n'))
      token[ntc++] = c;
    else if (ntc != 0) {
      token[ntc] = '\0';
      sscanf (token, control, data);
      *tline = line;
      break;
      }
    }

  return (ntc);
}
