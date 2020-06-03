%  To draw multiple vector plots
%
% Load in nod and ele files, find boundary if one does not exist locally
%     if one does not exist locally it will wait until you tell it to save the bnd file or not.
[ele,x,y,z,bnd]=loadgrid('MODB');
%
for i=1:3
% read in v2r file
file=['resv',int2str(i),'.v2r'];
[data]=read_v2r(file);
%
%plot boundary
subplot(2,2,i),plotbnd(x,y,bnd);
%
%set window size
axis('equal');
set(gca,'XLim',[-300000 300000]);
set(gca,'YLim',[-200000 400000]);
%
%set axis style - box around figure and no tick marks
set(gca,'Box','on');
set(gca,'XTick',[]);
set(gca,'YTick',[]);
% plot bathymetry lines of 60 100 200
 cval=[100 200 500];
 lcontour2(ele,x,y,z,cval);
%
%Draw vectors as arrows - the 1 is the scale, so the vector scale that you
%     put in with a mouse click will be 100cm/s.  If you want to increase the
%     size of your vectors then put in a smaller scale size( so 0.5 scale will give 
%     a representative scale length of 50 cm/s.  
hv=vecplot2(x,y,data(:,2),data(:,3),0.10,'cm/s');
end
%
% Print to file
orient tall
print -deps winter.eps
