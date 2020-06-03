% function [smin,smax,ibw]=colorband_fd_xy_cb(x,y,scalar,cb,smin,smax,ibw)
function [smin,smax,ibw]=colorband_fd_xy_cb(x,y,scalar,cb,smin,smax,ibw)
fprintf(1,'Scalar Range: %f to %f\n',min(min(scalar)),max(max(scalar)))
%
if nargin == 4
   smin=input('Enter min contour level desired:  ');
   smax=input('Enter max contour level desired:  ');
   ibw  =input('Enter the contour interval:      ');
end
%
cval=smin:ibw:smax;
nband=round((2*ibw+smax-smin)/ibw);
cmapjet=jet(64);
size(cmapjet);
njet=ans(1);
clear cmap;
cmap(1,:)=[1 1 1];
for i=2:nband-1
   cmap(i,:)=cmapjet(1+round((njet-1)*(i-2)/(nband-3)),:);
end
cmap(nband,:)=[1 1 1];
%
colormap(cmap);
caxis([smin-ibw smax+ibw]);
[c,h]=contourf(x,y,scalar,cval);
colormap(cmap);
caxis([smin-ibw smax+ibw]);
%
if cb == 1
colormap(cmap);
caxis([smin-ibw smax+ibw]);
hb=colorbar;set(hb,'ytick',cval);set(hb,'ticklength',[0.05 0.025]);
colormap(cmap);
caxis([smin-ibw smax+ibw]);
end
%
% axis([min(min(x)) max(max(x)) min(min(y)) max(max(y))]);
% set(gca,'XTick',[]);
% set(gca,'YTick',[]);
drawnow;
clear cmap;
