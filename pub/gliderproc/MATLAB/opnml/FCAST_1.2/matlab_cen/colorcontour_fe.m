%-----------------------------------------------------------------------
% [smin,smax,ibw,copt]=colorcontour_fe(in,x,y,bnd,scalar,smin,smax,ibw,copt)
% This function creates a color plot of data using
% Matlab5.1 commands
%-----------------------------------------------------------------------
function [smin,smax,ibw,copt]=colorcontour_fe(in,x,y,bnd,scalar,smin,smax,ibw,copt)
%
% Echo scalar range to screen
%
fprintf(1,'Scalar Range: %f to %f\n',min(min(scalar)),max(max(scalar)))
%
% Set contour levels (if 5 arguments are sent to function)
%
if nargin == 5
   smin=input('Enter min contour level desired: ');
   smax=input('Enter max contour level desired: ');
   ibw  =input('Enter the contour interval:      ');
end
clear cval;
clear cmap;
cval=smin:ibw:smax;
ncon=length(cval);
if nargin < 9
   copt=input('Black, gray scale or color spectrum color map (b/g/c)? ','s');
end
%
% Set colormap
%
if copt=='c'
   cmapjet=jet;
   size(cmapjet);
   njet=ans(1);
   for i=1:ncon
      cmap(i,:)=cmapjet(1+round((njet-1)*(i-1)/(ncon-1)),:);
   end
elseif copt=='g'
   for i=1:ncon
      cmap(i,1)=i/(2.0*ncon);
      cmap(i,2)=cmap(i,1);
      cmap(i,3)=cmap(i,1);
   end
   cmap=max(cmap,0.0);
   cmap=min(cmap,1.0);
else
   for i=1:ncon
      cmap(i,1)=0.0;
      cmap(i,2)=cmap(i,1);
      cmap(i,3)=cmap(i,1);
   end
end
%
% Generate plot
%
bndo=plotbnd(x,y,bnd);
set(bndo,'Color','k')
hc=lcontour2(in,x,y,scalar,cval);
set(hc,'LineWidth',1.0);
for i=1:ncon
   set(hc(i),'color',cmap(i,:));
end
set(hc(1),'LineStyle','-.');
xlabel([num2str(smin),'(-.) to ',num2str(smax),' by ',num2str(ibw)]); 
