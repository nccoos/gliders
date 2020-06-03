%-----------------------------------------------------------------------
% [smina,smaxa,ibw]=colorband_fe(in,x,y,bnd,scalar,smina,smaxa,ibw)
% This function creates a color banded plot using
% Matlab5.1 commands and the jet color map.
%-----------------------------------------------------------------------
function [smina,smaxa,ibw]=colorband_fe(in,x,y,bnd,scalar,smina,smaxa,ibw)
%
% Echo scalar range to screen
%
fprintf(1,'Scalar Range: %f to %f\n',min(min(scalar)),max(max(scalar)))
%
% Set color banding settings (if 5 arguments are sent to function)
%
if nargin == 5
   smina=input('Enter min contour level desired: ');
   smaxa=input('Enter max contour level desired: ');
   ibw  =input('Enter the contour interval:      ');
end
cvala=smina:ibw:smaxa;
nband=(2*ibw+smaxa-smina)/ibw;
cmapjet=jet;
size(cmapjet);
njet=ans(1);
clear cmap;
for i=1:nband
   cmap(i,:)=cmapjet(1+round((njet-1)*i/(nband+1)),:);
end
for i=1:nband
   cmap1(i,:)=cmap(nband+1-i,:);
end
cmap=cmap1;
%
% Generate plot
%
scalara=max(scalar,smina-ibw);
scalara=min(scalar,smaxa+ibw);
hpb=plotbnd(x,y,bnd);set(hpb,'color','k');
hl=lcontour2(in,x,y,scalara,cvala);
hc=colormeshm(in,x,y,scalara);colormap(cmap);caxis([smina-ibw smaxa+ibw]);
hb=colorbar;set(hb,'ytick',cvala);set(hb,'ticklength',[0.05 0.025]);
% set(hb,'FontSize',1.0);
for l=1:nband-1
   if cvala(l)>=min(scalara) & cvala(l)<=max(scalara)
      set(hl(l),'color','k');
   end
end
