%-----------------------------------------------------------------------
% [smin,smax,ibw]=contour_fe(in,x,y,bnd,scalar,smin,smax,ibw)
% This function creates a color plot of data using
% Matlab5.1 commands
%-----------------------------------------------------------------------
function [smin,smax,ibw]=contour_fe(in,x,y,bnd,scalar,smin,smax,ibw)
fprintf(1,'Scalar Range: %f to %f\n',min(min(scalar)),max(max(scalar)))
%
% Set contour levels (if 5 arguments are sent to function)
%
if nargin == 5
   smin=input('Enter min contour level desired: ');
   smax=input('Enter max contour level desired: ');
   ibw  =input('Enter the contour interval:      ');
end
%
% Generate Plot
%
clear cval;
cval=smin:ibw:smax;
bndo=plotbnd(x,y,bnd);
set(bndo,'Color','k')
hc=lcontour2(in,x,y,scalar,cval);
xlabel([num2str(smin),' to ',num2str(smax),' by ',num2str(ibw)])    
