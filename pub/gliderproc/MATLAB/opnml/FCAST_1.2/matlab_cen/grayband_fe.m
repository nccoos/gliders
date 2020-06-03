%-----------------------------------------------------------------------
% [smina,smaxa,ibw]=grayband_fe(in,x,y,bnd,scalar,smina,smaxa,ibw)
% This function creates a grayscale color banded plot using
% Matlab5.1 commands
%-----------------------------------------------------------------------
function [smina,smaxa,ibw]=grayband_fe(in,x,y,bnd,scalar,smina,smaxa,ibw)
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
clear cmap;
for i=1:nband
   cmap(i,1)=(i-1)/(nband-1);
   cmap(i,2)=cmap(i,1);
   cmap(i,3)=cmap(i,1);
end
cmap=max(cmap,0.0);
cmap=min(cmap,1.0);
invert='y';
if invert == 'y'
   cmap=1-cmap;
end
%
% Generate plot
%
scalara=max(scalar,smina-ibw);
scalara=min(scalar,smaxa+ibw);
hpb=plotbnd(x,y,bnd);set(hpb,'color','k');
hl=lcontour2(in,x,y,scalara,cvala);
hc=colormeshm(in,x,y,scalara);colormap(cmap);caxis([smina-ibw smaxa+ibw]);
hb=colorbar;set(hb,'ytick',cvala);set(hb,'ticklength',[0.05 0.025]);
set(hb,'FontSize',1.0)
for l=1:nband-1
   if cvala(l)>=min(scalara) & cvala(l)<=max(scalara)
      set(hl(l),'color','k');
   end
end
%
% Label x-axis with range of input data 
%
xlabel(['Scalar Range: ',num2str(min(min(scalar))),' to ',num2str(max(max(scalar)))])
