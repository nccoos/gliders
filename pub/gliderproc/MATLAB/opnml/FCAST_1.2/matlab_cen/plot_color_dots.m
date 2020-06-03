%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This matlab script file uses 5 primary colors to plot scalar results
% at x,y locations.
%-----------------------------------------------------------------------
function plot_color_dots(x,y,scalar,smin,smax,markersize)
size(scalar);
nn=ans(1);
%
% Plot dots
%
for i=1:nn
   b2=(scalar(i)-smin)/(smax-smin);
   if b2 <= 0.0
      h=plot(x(i),y(i),'kx');
      set(h,'MarkerSize',markersize/2.0);
   else
      if b2 <= 0.2
         colorval=[0,0,1];
      elseif b2 <= 0.4
         colorval=[0,1,1];
      elseif b2 <= 0.6
         colorval=[0,1,0];
      elseif b2 <= 0.8
         colorval=[1,1,0];
      elseif b2 <= 1.0
         colorval=[1,0,0];
      else
         colorval=[0,0,0];
      end
      h=plot(x(i),y(i),'k.');
      set(h,'MarkerSize',markersize);
      set(h,'Color',colorval);
   end
end
%
%  Plot COLOR KEY
%
xval=min(x)+0.8*(max(x)-min(x));
i=0;
yval=min(y)+(0.70+i*.055)*(max(y)-min(y));
h=plot(xval,yval,'kx');
text(xval+1,yval,['< ',num2str(smin)]);
set(h,'MarkerSize',markersize/2.0);
for i=1:5
   b2=i/5;
   t1=smin+(b2-0.2)*(smax-smin);
   t2=smin+b2*(smax-smin);
   yval=min(y)+(0.70+i*.055)*(max(y)-min(y));
   if b2 <= 0.2
      colorval=[0,0,1];
   elseif b2 <= 0.4
      colorval=[0,1,1];
   elseif b2 <= 0.6
      colorval=[0,1,0];
   elseif b2 <= 0.8
      colorval=[1,1,0];
   else
      colorval=[1,0,0];
   end
   h=plot(xval,yval,'k.');
   text(xval+1,yval,[num2str(t1),'-',num2str(t2)]);
   set(h,'MarkerSize',markersize);
   set(h,'Color',colorval);
end
i=6;
yval=min(y)+(0.70+i*.055)*(max(y)-min(y));
h=plot(xval,yval,'k.');
text(xval+1,yval,['> ',num2str(smax)]);
set(h,'MarkerSize',markersize);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
