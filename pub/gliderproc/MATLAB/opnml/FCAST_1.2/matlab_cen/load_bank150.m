%
% load in nod, ele, and bat files
%
[in,x,y,z,bnd]=loadgrid('bank150');
size(in);
ne=ans(1);
size(x);
nn=ans(1);
bndo=plotbnd(x,y,bnd);
set(bndo,'Color','black')
cval=[60 100 150];
h=lcontour2(in,x,y,z,cval);
set(h,'Color','black')
hold on
%
%
%
% set(gca,'XLim',[ 140000 440000]);
% set(gca,'YLim',[-250000  10000]);
 set(gca,'Box','on');
 axis('equal')
 set(gca,'XTick',[]);
 set(gca,'YTick',[]);
