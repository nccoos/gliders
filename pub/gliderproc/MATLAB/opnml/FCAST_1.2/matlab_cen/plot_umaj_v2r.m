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
% Determine vector field which represents the major axis
%
   u=umaj.*cos(pi/2.0-orien);
   v=umaj.*sin(pi/2.0-orien);
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
   cval=[50 100 200];
   hc=lcontour2(in,x,y,z,cval);
   set(hc,'Color','k')
%
% Plot vector field
%
   newscale='y';
   while newscale == 'y',
      title([verbatim(filename)])
      vmax=max(abs(u+sqrt(-1.0)*v))
      scale=input('Enter the desired vector scale: ');
      hv=vecplot2(x,y,u,v,scale,'m/s',max(x)-0.1*(max(x)-min(x)),min(y)+0.9*(max(y)-min(y)))
      set(hv,'Color','k')
      axis([min(x) max(x) min(y) max(y)])
      zoom on
      newscale=input('New scale? (y/n): ','s');
      if newscale == 'y',
         delete(hv);
      end
   end
%
% New .v2c file?
%
   newfile=input('New file? (y/n): ','s');
end
