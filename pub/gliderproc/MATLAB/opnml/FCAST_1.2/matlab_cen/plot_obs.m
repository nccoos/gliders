%
% Load data from files
%
   clear all
   !ls *.m3d *.o3d
   filename=input('Enter the name of observational file: ','s');
   [obs,gridname,year,ncol,gmt]=read_obs(filename);
%
% Filter data
%
   size(obs);
   nnv=21;
   nn=ans(1)/21;
   ii=0;
   for i=1:10:nn
      for j=1:nnv
         ij=(i-1)*nnv+j;
         ii=ii+1;
         obs1(ii,:)=obs(ij,:);
      end
   end
   clear obs;
   obs=obs1;
%
% Enter mesh generation info
%
   for i=1:ncol
      fprintf(1,' first col %4.0f entry is %12.4e \n',i,obs(1,i))
   end
   xcol=input('Enter the column number which corresponds to the x axis: ');
   ycol=input('Enter the column number which corresponds to the y axis: ');
   x=obs(:,xcol);
   y=obs(:,ycol);
%
% Create mesh and create boundary
%
   nnv=21;
   size(x);
   nn=ans(1)
   nseg=nn/nnv-1
   femgen
   bnd=detbndy(in);
%
% Begin plotting loop
%
newplot='y';
while newplot == 'y',
%
% Plot boundary
%
   figure
   whitebg('w')
   hold on
   bndo=plotbnd(x,y,bnd);
   set(bndo,'Color','k')
   axis('off')
%
% Set contour levels and make plot
%
   newcont='y';
   while newcont == 'y',
      for i=1:ncol
         fprintf(1,' first col %4.0f entry is %12.4e \n',i,obs(1,i))
      end
      scol=input('Enter the column number which corresponds to the scalar you desire to contour: ');
      scalar=obs(:,scol);
      scrange(scalar)
      cint=input('Enter the contour interval: ');
      cmin=cint*ceil(min(scalar)/cint);
      cmax=cint*floor(max(scalar)/cint);
      clear cval
      i=1;
      cval(i)=cmin;
      while cval(i) < cmax
         i=i+1;
         cval(i)=cval(i-1)+cint;
      end
      cval
      hc=lcontour2(in,x,y,scalar,cval);
      title(filename)    
      zoom on
      newcont=input('New contour interval? (y/n): ','s');
      if newcont == 'y',
         delete(hc);
      end
   end
   newplot=input('New plot? (y/n): ','s');
end
