%-----------------------------------------------------------------------
% [smin,smax,ibw]=colorband_fe_cb(in,x,y,bnd,scalar,cb,smin,smax,ibw)
% This function creates a color banded plot using
% Matlab5.1 commands and the jet color map.
%-----------------------------------------------------------------------
function [smin,smax,ibw]=colorband_fe_cb(in,x,y,bnd,scalar,cb,smin,smax,ibw)
%
% Echo scalar range to screen
%
fprintf(1,'Scalar Range: %f to %f\n',min(min(scalar)),max(max(scalar)))
%
% Set color banding settings (if 5 arguments are sent to function)
%
if nargin < 7
   smin=input('Enter min contour level desired: ');
   smax=input('Enter max contour level desired: ');
   ibw  =input('Enter the contour interval:      ');
end
%
% Set color bands
%
cval=smin:ibw:smax;
nband=(2*ibw+smax-smin)/ibw;
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
% Generate plot
%
scalara=max(scalar,smin-ibw);
scalara=min(scalar,smax+ibw);
hpb=plotbnd(x,y,bnd);set(hpb,'color','k');
hl=lcontour2(in,x,y,scalara,cval);
hc=colormeshm(in,x,y,scalara);colormap(cmap);caxis([smin-ibw smax+ibw]);
if cb == 1
hb=colorbar('vert');set(hb,'xtick',cval);set(hb,'ticklength',[0.05 0.025]);
end
for l=1:nband-1
   if cval(l)>=min(scalara) & cval(l)<=max(scalara)
      set(hl(l),'color','k');
   end
end
set(gca,'XTick',[]);
set(gca,'YTick',[]);
drawnow;
clear cmap;
