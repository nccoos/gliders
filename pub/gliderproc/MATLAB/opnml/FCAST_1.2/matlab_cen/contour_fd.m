function [smin,smax,ibw]=contour_fd(scalar,smin,smax,ibw)
fprintf(1,'Scalar Range: %f to %f\n',min(min(scalar)),max(max(scalar)))
if nargin == 1
   smin=input('Enter min contour level desired:  ');
   smax=input('Enter max contour level desired:  ');
   ibw  =input('Enter the contour interval:      ');
end
cval=smin:ibw:smax;
colormap(jet)
caxis([min(cval) max(cval)]);
[c,h]=contour(scalar,cval);
clabel(c,h);
size(scalar);
axis([1 ans(2) 1 ans(1)]);
set(gca,'XTick',[]);
set(gca,'YTick',[]);
drawnow;
