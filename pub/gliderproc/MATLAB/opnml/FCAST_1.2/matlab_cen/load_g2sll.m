%
% load in nod, ele, and bat files
%
[in,x,y,z,bnd]=loadgrid('g2s');
size(in);
ne=ans(1);
size(x);
nn=ans(1);
nodes=get_nodes('/usr4/people/naimie/meshes/g2s','g2sll');
x=nodes(:,1);
y=nodes(:,2);
bndo=plotbnd(x,y,bnd);
set(bndo,'Color','red')
cval=[60 100 150 200];
lcontour2(in,x,y,z,cval);
hold on
%
%
%
% axis('equal');
