% plot_bel(x,y,inbe,style)
%
function plot_bel(x,y,inbe,style)
for i=1:length(inbe)
   i1=inbe(i,2);i2=inbe(i,3);
   plot([x(i1) x(i2)],[y(i1) y(i2)],style);
end
return

