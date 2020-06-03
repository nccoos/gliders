function [smin,smax,ibw]=colorband_fd_xy(x,y,scalar,smin,smax,ibw)
fprintf(1,'Scalar Range: %f to %f\n',min(min(scalar)),max(max(scalar)))
%
if nargin == 3
   smin=input('Enter min contour level desired:  ');
   smax=input('Enter max contour level desired:  ');
   ibw  =input('Enter the contour interval:      ');
end
%
cval=smin:ibw:smax;
nband=(2*ibw+smax-smin)/ibw;
cmapjet=jet(64);
size(cmapjet);
njet=ans(1);
clear cmap;
cmap(1,:)=[0 0 0];
for i=2:nband-1
   cmap(i,:)=cmapjet(1+round((njet-1)*(i-2)/(nband-3)),:);
end
cmap(nband,:)=[1 1 1];
%
colormap(cmap);
caxis([smin-ibw smax+ibw]);
[c,h]=contourf(x,y,scalar,cval);
%
colormap(cmap);
caxis([smin-ibw smax+ibw]);
hb=colorbar;set(hb,'ytick',cval);set(hb,'ticklength',[0.05 0.025]);
hl=clabel(c,h);
%
size(scalar);
axis([min(min(x)) max(max(x)) min(min(y)) max(max(y))]);
% set(gca,'XTick',[]);
% set(gca,'YTick',[]);
drawnow;
clear cmap;
