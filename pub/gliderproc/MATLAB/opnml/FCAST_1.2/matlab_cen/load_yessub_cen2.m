%
% load in nod, ele, and bat files
%
[in,x,y,z,bnd]=loadgrid('yessub_cen2');
size(in);
ne=ans(1);
size(x);
nn=ans(1);
% nodes=get_nodes('/usr4/people/naimie/meshes/yes200','yes200ll');
% x=nodes(:,1);
% y=nodes(:,2);
bndo=plotbnd(x,y,bnd);
set(bndo,'Color','red')
cval=[50 100 150 200];
lcontour2(in,x,y,z,cval);
hold on
%
%
%
% axis('equal');
