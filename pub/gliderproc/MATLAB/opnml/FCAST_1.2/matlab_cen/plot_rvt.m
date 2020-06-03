%
% Load data from files
%
   ls *.rvt
   filename=input('Enter the name of .rvt file: ','s');
   nnv=input('Enter nnv: ');
   load(filename);
   rvt=eval(blank(filename(1:length(filename)-4)));
%
% Set data arrays
%
   x=rvt(:,2);
   y=rvt(:,3);
   rho=rvt(:,4);
   u=rvt(:,5);
   v=rvt(:,6);
   w=rvt(:,7);
   enz=rvt(:,8);
   T=rvt(:,9);
   S=rvt(:,10);
%
% Create mesh and create boundary
%
   size(x);
   nn=ans(1);
   nseg=nn/nnv-1;
   femgen
   bnd=detbndy(in);
%
% Plot boundary
%
newplot='y';
while newplot == 'y',
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
      scalarc=input('Enter variable you desire to contour (rho,u,v,w,enz,T,S): ','s');
      scalar=eval(scalarc);
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
