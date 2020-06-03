%
% Notify user if this script file cannot be used with their version of matlab
%
thisversion=version;
if thisversion(1) == '5'
   fprintf(1,'\n\nSORRY: This matlab script file fails for more recent releases of matlab than Version 4.2c  \n\n')
   fprintf(1,'You are currently using matlab version: %c%c%c%c%c%c%c%c%c%c%c',version)
   fprintf(1,'\n\n')
   break
end
%
% Load data from files
%
newplot='y';
while newplot == 'y',
   ls *.v2c
   filename=input('Enter the name of .v2c file: ','s');
   [v2c,freq]=read_v2c(filename);
   gridname=input('Enter the name of grid: ','s');
   [in,x,y,z,bnd]=loadgrid(gridname);
%
% Plot boundary
%
   figure
   whitebg('k')
   hold on
   bndo=plotbnd(x,y,bnd);
   set(bndo,'Color','k')
   axis('equal')
%   cval=[50 100 200];
%   hc=lcontour2(ele,x,y,z,cval);
%   set(hc,'Color','k')
%
% Plot tidal ellipses
%
%   newscale='y'
%   while newscale == 'y',
      scale=input('Enter the desired tidal ellipse scale: ');
      per=2.0*pi/freq/3600.0;
      htel=tellipse(x,y,scale*v2c(:,2),v2c(:,3),scale*v2c(:,4),v2c(:,5),per);
      title([filename])
      zoom on
%      newscale=input('New scale? (y/n): ','s');
%      if newscale == 'y',
%         delete(htel)
%      end
%   end
   newplot=input('New plot? (y/n): ','s');
end
