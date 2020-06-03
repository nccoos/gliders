%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% [nn,ne,x,y,z,in,bnd,meshname]=load_mesh(meshname,variable)
%% load nod, ele, and bat files
%% plot contours of depth (25 to 200 by 25)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nn,ne,x,y,z,in,bnd,meshname]=load_mesh(meshname,variable)
[in,x,y,z,bnd]=loadgrid(meshname);
size(in);
ne=ans(1);
size(x);
nn=ans(1);
%
% convert coordinates to longitude and latitude
%
if variable == 'mesh'
hel=drawelems(in,x,y);
   set(hel,'Color','b');
else
   bndo=plotbnd(x,y,bnd);
   set(bndo,'Color','red')
   cval=[25:25:200];
   lcontour2(in,x,y,z,cval);
end
hold on
title(verbatim(meshname));

