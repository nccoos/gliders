%
% load in nod, ele, and bat files
%
[in,x,y,z,bnd]=loadgrid('yessub');
size(in);
ne=ans(1);
size(x);
nn=ans(1);
%
% convert coordinates to longitude and latitude
%
[yl,xl]=xy2ll(x,y,34.7847*pi/180.0,119.207*pi/180.0);
bndo=plotbnd(xl,yl,bnd);
set(bndo,'Color','red')
cval=[20 40 60 80 100];
lcontour2(in,xl,yl,z,cval);
hold on
