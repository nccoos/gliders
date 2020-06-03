%-----------------------------------------------------------------------
% [smina,smaxa,ibw]=grayband_points(x,y,scalar,smina,smaxa,ibw,pointsize)
% This function creates a grayscale color plot of data using
% Matlab5.1 commands
%-----------------------------------------------------------------------
function [smina,smaxa,ibw]=grayband_points(x,y,scalar,smina,smaxa,ibw,pointsize)
%
% Echo scalar range to screen
%
fprintf(1,'Scalar Range: %f to %f\n',min(min(scalar)),max(max(scalar)))
%
% Set color banding settings (if 5 arguments are sent to function)
%
if nargin == 3
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
size(scalar);
nn=ans(1);
for i=1:nn
   hp=plot(x(i),y(i),'ko');
   set(hp,'MarkerSize',pointsize/3);
   hp=plot(x(i),y(i),'k.');
   set(hp,'MarkerSize',pointsize);
   iband=nband;
   for ii=1:nband-1
      if scalara(i) <= cvala(ii);
         iband=ii;
         break;
      end
   end
   set(hp,'Color',cmap(iband,:));
end
