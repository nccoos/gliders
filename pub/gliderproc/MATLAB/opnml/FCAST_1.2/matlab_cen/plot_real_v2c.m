gridname=input('Enter the name of grid: ','s');
[in,x,y,z,bnd]=loadgrid(gridname);
%
newplot='y';
while newplot == 'y',
%
% Load data from files
%
   !ls *Z0*.v2c */*Z0*.v2c
   filename=input('Enter the name of .v2c file: ','s');
   [v2c,freq]=read_v2c(filename);
%
% Calculate real u and v
%
   u=v2c(:,2).*cos(v2c(:,3)*pi/180.0);
   v=v2c(:,4).*cos(v2c(:,5)*pi/180.0);
%
% Plot boundary
%
   tallfigure;
   bndo=plotbnd(x,y,bnd);
   set(bndo,'Color','k')
   xmin=min(x)-0.1*(max(x)-min(x));
   xmax=max(x)+0.1*(max(x)-min(x));
   ymin=min(y)-0.1*(max(y)-min(y));
   ymax=max(y)+0.1*(max(y)-min(y));
   axis([xmin xmax ymin ymax])
   axis('equal')
   axis('tight')
   drawnow
   cval=[50 100 200];
   hc=lcontour2(in,x,y,z,cval);
   set(hc,'Color','k')
%
% Plot vector field
%
   newscale='y';
   while newscale == 'y',
      title(verbatim(filename))
      vmax=max(abs(u+sqrt(-1.0)*v))
      scale=input('Enter the desired vector scale: ');
      hv=vecplot2(x,y,u,v,scale,'cm/s',max(x)-0.225*(max(x)-min(x)),min(y)+0.95*(max(y)-min(y)))
      set(hv,'Color','k')
      zoom on
      newscale='n';
      newscale=input('New scale? (y/n): ','s');
      if newscale == 'y',
         delete(hv);
      end
   end
   newplot=input('New plot? (y/n): ','s');
end
