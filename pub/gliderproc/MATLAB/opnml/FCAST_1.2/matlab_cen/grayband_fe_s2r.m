%
% Notify user if this script file cannot be used with their version of matlab
%
thisversion=version;
if thisversion(1) < '5'
   fprintf(1,'\n\nSORRY: This matlab script file fails for earlier releases of matlab than Version 5.1  \n\n')
   fprintf(1,'You are currently using matlab version: %c%c%c%c%c%c%c%c%c%c%c',version)
   fprintf(1,'\n\n')
   break
end
%
% Load data from files and set data arrays
%
ls *.s2r
filename=input('Enter the name of your .s2r file: ','s');
[s2r,gridname]=read_s2r(filename);
scalar=s2r(:,2);
[in,x,y,z,bnd]=loadgrid(gridname(1:length(gridname)-1));
%
% Make plot
%
figure
whitebg('w')
axis([min(x) max(x) min(y) max(y)])
axis('equal')
[smina,smaxa,ibw]=grayband_fe(in,x,y,bnd,scalar)
