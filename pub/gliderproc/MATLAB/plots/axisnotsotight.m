% script axisnotsotight;
%
% axis tight, with 5% of the data window added back in on all edges
%

xl=get(gca,'xlim'); yl=get(gca,'ylim'); 
dx=diff(xl); dy=diff(yl); 

set(gca,'xlim',[xl(1)-dx/20 xl(2)+dx/20],'ylim',[yl(1)-dy/20 yl(2)+dy/20]);
