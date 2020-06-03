%
% Load data from files
%
   !ls *.sq4 *.SQ4
   filename=input('Enter the name of .sq4 file: ','s');
   load(filename);
   vsq4=eval(blank(filename(1:length(filename)-4)));
%
% Set data arrays
%
variable=['U   ';'V   ';'W   ';'RHO ';'T   ';'S   ';'Q2  ';'Q2L ';'ENZM';'ENZH';'ENZQ']
ip=[1 2 3 4 5 6 7 8 9 10 11]
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
% Create Plot
%
tallfigure
for i=1:11
   subplot(4,3,ip(i))
   bndo=plotbnd(x,y,bnd);
   set(bndo,'Color','k')
   axis([xmin xmax ymin ymax])
   axis('off')
   title(variable(i,:))
   hold on
   colormeshm(in,x,y,vsq4(:,i+2))
   colorbar
end
%
%
%
break
   !ls *iter_0_*.sq4
   filename=input('Enter the name of reference .sq4 file: ','s');
   load(filename);
   vsq4r=eval(blank(filename(1:length(filename)-4)));
   vsq4(:,5)=vsq4r(:,7);
   vsq4(:,6)=vsq4r(:,8);
%
% Create Plot
%
massvar=['initial T';'initial S';'detided T';'detided S'];
tallfigure
for i=1:4
   subplot(2,2,i)
   bndo=plotbnd(x,y,bnd);
   set(bndo,'Color','k')
   axis([xmin xmax ymin ymax])
   axis('off')
   title(massvar(i,:))
   hold on
   colormeshm(in,x,y,vsq4(:,i+4))
   colorbar
end
