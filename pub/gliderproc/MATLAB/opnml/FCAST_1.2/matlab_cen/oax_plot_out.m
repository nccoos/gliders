%
% Identify oax files: .grid, .dat, .out
%
mesh='yessub_cen2';
string='ll_0.250';
fgrid=[mesh,string,'.grid'];
fdat='ys_cen.dat';
fout=[mesh,string,'.out'];
varcol=3;
%
% Load oax and .ele file
%
grid=loadname(fgrid);
dat=loadname(fdat);
out=loadname(fout);
in=get_elems(['/usr/yes/naimie/meshes/',mesh],mesh);
bnd=detbndy(in);
%
% Name variables
%
xi=dat(:,1);yi=dat(:,2);si=dat(:,varcol);
xo=out(:,1);yo=out(:,2);so=out(:,varcol);
eo=out(:,length(out(1,:)));
axislim=[min(xo) max(xo) min(yo) max(yo)];
%
% fid=fopen('yessub_cen2.bat','w')
% for i=1:length(so) 
% fprintf(fid,'%5i %10.3f\n',i,so(i))
% end
% fclose(fid)
%-----------------------------------------------------------------------
% Plot 4 panels of results
%
tallfigure;figoax=gcf;
%
%  oax input data
subplot(2,2,1)
[smin,smax,ibw]=colorband_points(xi,yi,si,10,1)
title(verbatim(['oax input data: ',fdat]));
axis(axislim);
drawnow;
%
%  oax results
subplot(2,2,2)
[smin,smax,ibw]=colorband_points(xo,yo,so,10,1,smin,smax,ibw);
title(verbatim(['oax results: ',fout]));
axis(axislim);
drawnow;
%
%  oax results
subplot(2,2,3)
[smin,smax,ibw]=colorband_fe(in,xo,yo,bnd,so,smin,smax,ibw);
title(verbatim(['oax results: ',fout]));
axis(axislim);
drawnow;
%
%  error field
nband=(smax-smin)/ibw;
smin=max(min(eo),mean(eo)-std(eo));
smax=min(max(eo),mean(eo)+std(eo));
ibw=(smax-smin)/nband;
subplot(2,2,4)
[smin,smax,ibw]=colorband_fe(in,xo,yo,bnd,eo,smin,smax,ibw);
title(verbatim(['oax error field: mean/std=',num2str(mean(eo)),'/',num2str(std(eo))]));
axis(axislim);
drawnow;
eval(['!snatch "Figure No. ',num2str(figoax),' " ',mesh,string,'_4'])
break
%-----------------------------------------------------------------------
% Plot 1 panel of results
%
tallfigure;figoax=gcf;
%
%  oax results
smin=0.0;smax=200.0;ibw=20;
[smin,smax,ibw]=colorband_fe(in,xo,yo,bnd,so,smin,smax,ibw);
title(verbatim(['oax results: ',fout]));
axis(axislim);
drawnow;
eval(['!snatch "Figure No. ',num2str(figoax),' " ',mesh,string])
break
%-----------------------------------------------------------------------
