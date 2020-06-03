gridname=input('Enter the name of grid: ','s');
[in,x,y,z,bnd]=loadgrid(gridname);
newfile='y';
while newfile == 'y',
%
% Load data from .v2c file
%
   ls *.v2c
   filename=input('Enter the name of .v2c file: ','s');
   [v2c,freq]=read_v2c(filename);
%
% Determine tidal ellipse parameters
%
   per=2.0*pi/freq/3600.0;
   [umaj,umin,orien,phase]=tellipse_cen(x,y,v2c(:,2),v2c(:,3),v2c(:,4),v2c(:,5),per);
%
% Scalar plot of major axis
%
   scalar=umaj;
%
% Plot boundary
%
   figure
   whitebg('w')
   hold on
   bndo=plotbnd(x,y,bnd);
   set(bndo,'Color','k')
   axis([min(x) max(x) min(y) max(y)])
   set(gca,'Box','on');
   set(gca,'XTick',[]);
   set(gca,'YTick',[]);
   axis('square')
%   cval=[50 100 200];
%   hc=lcontour2(ele,x,y,z,cval);
%   set(hc,'Color','k')
%
% Make plot color plot of major axis magnitude
%
   cmin=min(scalar)
   cmax=max(scalar)
   cmin=0.0
   cmax=0.25
   markersize=10.0
   plot_color_dots(x,y,scalar,cmin,cmax,markersize)
%   cmin=min(scalar)
%   cmax=max(scalar)
%   cmin=cmax/2.0
%   caxis([cmin cmax])
%   hp=colormesh2d(in,x,y,scalar);
%   mean(scalar);
%   title(filename)
%   colorbar
%   colormap('jet');
%   drawnow
%
% New .v2c file?
%
   newfile=input('New file? (y/n): ','s');
end
