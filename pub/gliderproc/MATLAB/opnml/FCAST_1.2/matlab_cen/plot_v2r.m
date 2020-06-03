newplot='y';
while newplot == 'y',
%
% Load data from files
%
   ls *.v2r
   filename=input('Enter the name of .v2r file: ','s');
   [v2r,freq,gridname]=read_v2r(filename);
   u=v2r(:,2);
   v=v2r(:,3);
   gridname=blank(gridname(1:length(gridname)-1));
   [in,x,y,z,bnd]=loadgrid(gridname);
%
% Plot boundary
%
   figure
   whitebg('w')
   hold on
   bndo=plotbnd(x,y,bnd);
   set(bndo,'Color','k')
   axis('equal')
   cval=[25 50 75];
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
   newplot=input('New plot? (y/n): ','s');
end
