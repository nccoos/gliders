%-----------------------------------------------------------------------
% [smin,smax,ibw]=colorband_points(x,y,scalar,pointsize,wantbar,smin,smax,ibw)
% This function creates a color plot of data using
% Matlab5.1 commands
%-----------------------------------------------------------------------
function [smin,smax,ibw]=colorband_points(x,y,scalar,pointsize,wantbar,smin,smax,ibw)
%
% Echo scalar range to screen
%
fprintf(1,'Scalar Range: %f to %f\n',min(min(scalar)),max(max(scalar)))
%
% Set color banding settings (if 4 arguments are sent to function)
%
if nargin == 5
   smin=input('Enter min contour level desired: ');
   smax=input('Enter max contour level desired: ');
   ibw  =input('Enter the contour interval:      ');
end
%
% Set color map for bands
%
clear cmap;
cval=smin:ibw:smax;
nband=(2*ibw+smax-smin)/ibw;
cmapjet=jet;
size(cmapjet);
njet=ans(1);
cmap(1,:)=[0 0 0];
for i=2:nband-1
   cmap(i,:)=cmapjet(1+round((njet-1)*(i-2)/(nband-3)),:);
end
cmap(nband,:)=[1 1 1];
colormap(cmap);caxis([smin-ibw smax+ibw]);
%
% Create fem colorfill plot of a random triangle to set color map 
% (then remove fem colorfill plot)
%
if wantbar == 1
   in=[1 2 3 3];hc=colormeshm(in,x,y,scalar);
   colormap(cmap);caxis([smin-ibw smax+ibw]);
   hbar=colorbar;
   set(hbar,'ytick',cval);
   set(hbar,'ticklength',[0.05 0.025]);
   delete(hc);
end
%
% Sort scalar and reindex (x,y) accordingly
%
[scalars,is]=sort(scalar);
for i=1:length(scalars)
   xs(i,1)=x(is(i));
   ys(i,1)=y(is(i));
end
%
% Identify scalar index values which define range of each band
%
ibandi=zeros(nband,2);
for iband=1:length(cval)
   if scalars(1) < cval(iband)
      ibandi(iband,1)=1;
      break;
   end
end
for i=1:length(scalars)
   if scalars(i) > cval(iband)
      ibandi(iband,2)=i-1;
      iband=iband+1;
      ibandi(iband,1)=i;
      if iband == nband; break; end;
   end
end
ibandi(iband,2)=length(scalars);
if iband <= nband
   for i=iband+1:nband
      ibandi(i,1)=0;
      ibandi(i,2)=0;
   end
end
%
% Make color plot
%
hold on;
for iband=1:nband-1
   if ibandi(iband,1) ~= 0
   hp=plot(xs(ibandi(iband,1):ibandi(iband,2),1),ys(ibandi(iband,1):ibandi(iband,2),1),'k.');
   set(hp,'MarkerSize',pointsize);
   set(hp,'Color',cmap(iband,:));
   end
end
if ibandi(nband,1) ~= 0;
   hp=plot(xs(ibandi(nband,1):ibandi(nband,2),1),ys(ibandi(nband,1):ibandi(nband,2),1),'ks');
   set(hp,'MarkerSize',pointsize/3.0);
end
xlabel(['Data Range: ',num2str(min(scalar)),' to ',num2str(max(scalar))])
drawnow;
clear cmap;
%-----------------------------------------------------------------------
