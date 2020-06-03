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

/* ---- read_ucd_mex will be called as :
        [et,xt,yt,zt,data]=read_ucd(inpname); 
        
        I/O argument count has already been checked in the calling
        routine, read_ucd.  The input filename will have to be
        checked here, though. 
                                             ------------------------ */

   double *x, *y, *z, *dele, *data;
   int nnd,nne,nnd_data,nne_data,nmodel_data,i,j,**ele;
   int errflag,strlen,itrash,tcomp,ncomp,*ncompcomp;
   char *inpname, *line, *cell_type;
   FILE *fp=NULL, *fopen();
   
/* ---- extract input filename from first pointer to RHS  
                              --------------------------------------- */  
   strlen=mxGetN(prhs[0])+1;
   inpname=mxCalloc(strlen,sizeof(char));
   if (mxGetString(prhs[0],inpname,strlen)==1)
      fprintf(stderr,"Input filename string extraction failed in READ_UCD_MEX.");
      
/* ---- Open UCD filename ------------------------------------------- */
   if (!(fp = fopen(inpname,"r"))){
      fprintf(stderr,"Open of %s failed.\n",inpname);
      /* Allocate the return matricies as empty [] */
      plhs[0]=mxCreateDoubleMatrix(0,0,mxREAL);
      plhs[1]=mxCreateDoubleMatrix(0,0,mxREAL); 
      plhs[2]=mxCreateDoubleMatrix(0,0,mxREAL); 
      plhs[3]=mxCreateDoubleMatrix(0,0,mxREAL); 
      plhs[4]=mxCreateDoubleMatrix(0,0,mxREAL); 
      return;
   }

/* ---- Read until first line without leading character of "#" ------ */
   line=mxCalloc(BUFFER_SIZE,sizeof(char));
   fgets(line,BUFFER_SIZE,fp);   
   while (!strncmp(line,"#",1))
      fgets(line,BUFFER_SIZE,fp);

/* ---- "line" now contains 5 integers embedded in a string
         They are:  nnd, nne, nnd_data, nne_data, nmodel_data ------- */
   sscanf(line,"%d %d %d %d %d",&nnd,&nne,&nnd_data,&nne_data,&nmodel_data);

/* ---- Allocate space for x,y,z ------------------------------------ */
   x= (double *) mxDvector(0,nnd-1);
   y= (double *) mxDvector(0,nnd-1);
   z= (double *) mxDvector(0,nnd-1);
   
   for(i=0;i<nnd;i++)
      fscanf(fp,"%d %lf %lf %lf",&itrash,&x[i],&y[i],&z[i]);
      
/* ---- Allocate space for **ele, the integer element array (nneX3)
        and for the double MATLAB representation *dele
        then  fill in the double* array  ---------------------------- */
   cell_type=mxCalloc(3,sizeof(char));
   dele = (double *)  mxDvector(0,3*nne-1);
   ele= (int **) mxImatrix(0,nne-1,0,2);
   
   fgets(line,BUFFER_SIZE,fp);  /* Read NewLine at end of current line */
   /* ---- Read next line and determine cell_type ------------------ */
   fgets(line,BUFFER_SIZE,fp);  
   get_token(&line,&itrash,"%d");
   get_token(&line,&itrash,"%d");
   get_token(&line,cell_type,"%s");
   if (strncmp(cell_type,"tri",3)!=0){
      fprintf(stderr,"READ_UCD can only interpret cell topologies of type \"TRI\".\n");
      fprintf(stderr,"Did this UCD file come from TRANSECT or QUODTRANS???\n");
      /* Allocate the return matricies as empty [] */
      plhs[0]=mxCreateDoubleMatrix(0,0,mxREAL);
      plhs[1]=mxCreateDoubleMatrix(0,0,mxREAL); 
      plhs[2]=mxCreateDoubleMatrix(0,0,mxREAL); 
      plhs[3]=mxCreateDoubleMatrix(0,0,mxREAL); 
      plhs[4]=mxCreateDoubleMatrix(0,0,mxREAL); 
      return;
   }
   
   /* --- If we're here, break down the remaining data in the current line
          and scan the rest of the cell lines from 1:nne-1
                                        ----------------------------- */   
   get_token(&line,&dele[0],"%lf");
   get_token(&line,&dele[0+nne],"%lf");
   get_token(&line,&dele[0+2*nne],"%lf");
   
   for(i=1;i<nne;i++)
      fscanf(fp,"%d %d %s %lf %lf %lf",
             &itrash,&itrash,cell_type,&dele[i],&dele[i+nne],&dele[i+2*nne]);

   /* ---- The next line is the number of node-data components 
      and their dimensions     -------------------------------------- */ 
   fgets(line,BUFFER_SIZE,fp);  /* Read NewLine at end of current line */
   fgets(line,BUFFER_SIZE,fp);
   get_token(&line,&ncomp,"%d");

/* In AVS-UCD format, the nodedata components can be either scalar or vector.
   We will treat a vector, specified by &ncompcomp[i]=3, as three scalars and
   returned to the MATLAB workspace as such.  Thus, a node data segment that
   has compoments specified as (1 3 1) for (scalar vector scalar) will be
   returned as (1 1 1 1 1) for (scalar scalar scalar scalar scalar).            */
   
   ncompcomp=(int*)mxIvector(0,ncomp);
   tcomp=0;
   for(i=0;i<ncomp;i++){
      get_token(&line,&ncompcomp[i],"%d");
      tcomp=tcomp+ncompcomp[i];
   }
         
   
   for(j=0;j<tcomp;j++)
      fgets(line,BUFFER_SIZE,fp);  /* There are the data label lines, which we ignore */
            
   
   /* ---- Scan in the node data lines as per NCOMP from above ------ */
   data=(double *) mxDvector(0,tcomp*nnd-1);
   for(i=0;i<nnd;i++){
      fscanf(fp,"%d",&itrash);   /* Read the node number as trash */
      for(j=0;j<tcomp;j++)
         fscanf(fp,"%lf",&data[i+j*nnd]);      
   }          
             
   plhs[0]=mxCreateDoubleMatrix(nne,3,mxREAL);
   plhs[1]=mxCreateDoubleMatrix(nnd,1,mxREAL); 
   plhs[2]=mxCreateDoubleMatrix(nnd,1,mxREAL); 
   plhs[3]=mxCreateDoubleMatrix(nnd,1,mxREAL); 
   plhs[4]=mxCreateDoubleMatrix(nnd,tcomp,mxREAL); 

   mxSetPr(plhs[0],dele);
   mxSetPr(plhs[1],x);
   mxSetPr(plhs[2],y);
   mxSetPr(plhs[3],z);
   mxSetPr(plhs[4],data);
   
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
