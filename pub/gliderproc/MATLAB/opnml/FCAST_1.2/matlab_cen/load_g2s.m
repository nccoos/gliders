%
% load in nod, ele, and bat files
%
[in,x,y,z,bnd]=loadgrid('g2s');
size(in);
ne=ans(1);
size(x);
nn=ans(1);
bndo=plotbnd(x,y,bnd);
set(bndo,'Color','black')
cval=[60 100 200];
h=lcontour2(in,x,y,z,cval);
set(h,'Color','black')
hold on
