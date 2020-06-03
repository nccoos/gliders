%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purpose: Output an OAX5 .grid file from input mesh data.
% Format:  The .grid file contains columns of the independent variables
%          followed by the correlation scales in the directions of the
%          independent variables.  It allows for the horizontal
%          correlation scales to have a variable major axis through the
%          assignment of a rotation angle.  This version sets constant
%          correlation scales in the x and y directions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Load grid files ... in case any are needed
%
meshname='yessub_cen2'
[in,x,y,z,bnd]=loadgrid(meshname);
size(in);
ne=ans(1);
size(x);
nn=ans(1);
%
% Set independent variables (x and y should be first and second)
%
nodes=get_nodes(['/usr/yes/naimie/meshes/',meshname],[meshname,'ll']);
x=nodes(:,1);
y=nodes(:,2);
vid(:,1)=x;vid(:,2)=y;
%
% Set correlation scales for independent variables
%  (rot is the angle of rotation ccw from the x axis to the x' axis)
% 
%
rot(1:nn,1)=0.0;
cor(1:nn,1:2)=0.50;
%
% Output grid file (x,y,id,rot,Sx',Sy',Sid)
%  id=columns of independent variables (likely z and t)
%  Sx',Sy' are the correlation scales in the x' and y' directions
%  Sid are the correlation scales in the id directions
%
fid=fopen([meshname,'ll.grid'],'w');
for i=1:nn
  fprintf(fid,' %7.3f',vid(i,:));
  fprintf(fid,' %5.1f',rot(i,1));
  fprintf(fid,' %6.2f',cor(i,:));
  fprintf(fid,'\n');
end
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
