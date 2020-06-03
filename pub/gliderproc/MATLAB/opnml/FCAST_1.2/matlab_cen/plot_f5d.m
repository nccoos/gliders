%
% Load data from files
%
   ls *.f5d
   filename=input('Enter the name of .f5d file: ','s');
   load(filename);
   vf5d=eval(blank(filename(1:length(filename)-4)));
%
% Set data arrays
%
   x=vf5d(:,1)/1000.0;
   y=vf5d(:,2);
   u=vf5d(:,3);
   v=vf5d(:,4);
   w=vf5d(:,5);
   sigt=vf5d(:,6);
   T=vf5d(:,7);
   S=vf5d(:,8);
%
% Create mesh and create boundary
%
%   nnv=input('Enter nnv: ');
   nnv=21
   size(x);
   nn=ans(1);
   nseg=nn/nnv-1;
   femgen
   bnd=detbndy(in);
   xmin=min(x(:,1));
   xmax=max(x(:,1));
   ymin=min(y(:,1));
   ymax=max(y(:,1));
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
   axis([xmin xmax ymin ymax])
%   axis('off')
   scalarc=input('Enter variable you desire to contour (u,v,w,sigt,T,S): ','s');
   scalar=eval(scalarc);
   scrange(scalar)
   [smin,smax,ibw]=colorband_fe(in,x,y,bnd,scalar)
   newplot=input('New variable plot? (y/n): ','s');
end
