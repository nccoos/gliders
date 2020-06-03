%
% Load data from files
%
   ls *.sq4 *.SQ4
   filename=input('Enter the name of .sq4 file: ','s');
   load(filename);
   vsq4=eval(blank(filename(1:length(filename)-4)));
%
% Set data arrays
%
   x=vsq4(:,1);
   y=vsq4(:,2);
   u=vsq4(:,3);
   v=vsq4(:,4);
   w=vsq4(:,5);
   rho=vsq4(:,6);
   T=vsq4(:,7);
   S=vsq4(:,8);
   q2=vsq4(:,9);
   q2l=vsq4(:,10);
   enzm=vsq4(:,11);
   enzh=vsq4(:,12);
   enzq=vsq4(:,13);
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
   axis('off')
   scalarc=input('Enter variable you desire to contour (u,v,w,rho,T,S,q2,q2l,enzm,enzh,enzq): ','s');
   scalar=eval(scalarc);
   scrange(scalar)
   [smina,smaxa,ibw]=colorband_fe(in,x,y,bnd,scalar)
   newplot=input('New variable plot? (y/n): ','s');
end
