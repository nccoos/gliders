function fem_grid_struct=grd_to_opnml(fort14name)
%GRD_TO_OPNML Convert an ADCIRC grd file to an OPNML fem_grid_struct.
% Convert an ADCIRC grd file to an OPNML fem_grid_struct.
% ADCIRC grid information assumed in "fort.14" format.
% The boundary/island information at the tail of the fort.14
% file is ignored.
%
% Input:  fort14name - path/name of fort.14 file;  if not passed,
%                      assumes fort.14 in the currect working dir.
% Output: fem_grid_struct - OPNML grid structure
%
% Call:   fem_grid_struct=grd_to_opnml(fort14name);
%         fem_grid_struct=grd_to_opnml;

if ~exist('fort14name')
   % assume fort.14 filename in the current wd.
   fort14name='fort.14';
end

% Open fort.14 file
[f14,message]=fopen(fort14name,'r');
if (f14<0)
   error(message)
end

% Get grid info
gridname=fgetl(f14);

temp=fscanf(f14,'%d %d',2);
nn=temp(2);
ne=temp(1);

% Get node locations
temp=fscanf(f14,'%d %f %f %f',[4 nn])';
x=temp(:,2);
y=temp(:,3);
z=temp(:,4);

% Get elements
temp=fscanf(f14,'%d %d %d %d',[5 ne])';
e=temp(:,3:5);

fem_grid_struct.name=gridname;
fem_grid_struct.x=x;
fem_grid_struct.y=y;
fem_grid_struct.z=z;
fem_grid_struct.e=e;
fem_grid_struct.bnd=detbndy(e);

fclose(f14);
