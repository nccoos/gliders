%
% load in nod, ele, and bat files
%
[in,x,y,z,bnd]=loadgrid('adrdep2kmg');
size(in);
ne=ans(1);
size(x);
nn=ans(1);
nodes=get_nodes('adrdep2kmgll');
x=nodes(:,1);
y=nodes(:,2);
%
% plot boundary and contours
%
% figure
% whitebg('w')
hold on
bndo=plotbnd(x,y,bnd);
set(bndo,'Color','k')
% cval=[50 100 200];
% hc=lcontour2(ele,x,y,z,cval);
% set(hc,'Color','k')
%
%
%
set(gca,'Box','on');
set(gca,'XTick',[]);
set(gca,'YTick',[]);
