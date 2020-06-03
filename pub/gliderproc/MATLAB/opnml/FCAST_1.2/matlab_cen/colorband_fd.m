function [smin,smax,ibw]=colorband_fd(scalar,smin,smax,ibw)
fprintf(1,'Scalar Range: %f to %f\n',min(min(scalar)),max(max(scalar)))
%
if nargin == 1
   smin=input('Enter min contour level desired:  ');
   smax=input('Enter max contour level desired:  ');
   ibw  =input('Enter the contour interval:      ');
end
%
cval=smin:ibw:smax;
nband=(2*ibw+smax-smin)/ibw;
cmapjet=jet;
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
[c,h]=contourf(scalar,cval);
%
colormap(cmap);
caxis([smin-ibw smax+ibw]);
hb=colorbar;set(hb,'ytick',cval);set(hb,'ticklength',[0.05 0.025]);
set(hb,'FontSize',1.0);
hl=clabel(c,h);
%
size(scalar);
axis([1 ans(2) 1 ans(1)]);
set(gca,'XTick',[]);
set(gca,'YTick',[]);
drawnow;
clear cmap;
