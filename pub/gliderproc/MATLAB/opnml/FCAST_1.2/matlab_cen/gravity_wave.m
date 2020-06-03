%
% Load data from files
%
   gridname=input('Enter the name of the grid: ','s');
   gridname=blank(gridname);
   [in,x,y,z,bnd]=loadgrid(gridname);
%
% Calculate nodal and elemental areas and deltax's
%
   area
%
% Compute node-based time for gravity waves cross elements
%
   scrange(z)
   zmin=input('Enter the minimum depth (in m): ');
   z=max(z,zmin);
   tgwave=dxnod./sqrt(9.81*z);
   scalar=tgwave;
   fid=fopen([gridname,'_tgwave.s2r'],'w');
   fprintf(fid,'%c',gridname);
   fprintf(fid,'\nnode-based time for gravity wave to cross elements\n');
   for i=1:nn
      fprintf(fid,'%6.0f  %10.2f\n',i,tgwave(i));
   end
%
% Plot results
%
   newplot='y';
   while newplot == 'y',
      tallfigure
      whitebg('w')
      hold on
      bndo=plotbnd(x,y,bnd);
      set(bndo,'Color','k')
      [smin,smax,ibw]=colorband_fe_cb(in,x,y,bnd,scalar,1);
      newplot=input('New plot? (y/n): ','s');
   end
