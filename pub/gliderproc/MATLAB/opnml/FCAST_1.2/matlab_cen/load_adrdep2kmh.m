%
% load in nod, ele, and bat files
%
[in,x,y,z,bnd]=loadgrid('adrdep2kmh');
size(in);
ne=ans(1);
size(x);
nn=ans(1);
%
% plot boundary and contours
%
figure
whitebg('w')
hold on
bndo=plotbnd(x,y,bnd);
set(bndo,'Color','k')
% cval=[50 100 200];
% hc=lcontour2(ele,x,y,z,cval);
% set(hc,'Color','k')
%
%
%
xr=max(x)-min(x);
yr=max(y)-min(y);
axis([min(x)-.1*xr,max(x)+.1*xr,min(y)-.1*yr,max(y)+.1*yr])
axis('square')
set(gca,'Box','on');
set(gca,'XTick',[]);
set(gca,'YTick',[]);
