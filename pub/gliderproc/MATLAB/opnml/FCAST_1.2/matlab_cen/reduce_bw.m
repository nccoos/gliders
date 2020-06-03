%-----------------------------------------------------------------------
% function [in,x,y,z]=reduce_bw(wantplot,in,x,y,z)
% This function reduces the bandwidth of a fem mesh using an extremely
% simple strategy with Matlab5.1 commands
%-----------------------------------------------------------------------
function [in,x,y,z]=reduce_bw(wantplot,in,x,y,z)
%-----------------------------------------------------------------------
% Input phase: load fe data, determine hbw, and plot
%
if nargin == 1
   mesh1=input('Enter the name of the input fem mesh: ','s')
   [in,x,y,z,bnd]=loadgrid(mesh1);
end
%
hbw=(bwidth(in)-1)/2;
fprintf(1,'original halfbandwidth             : %5i\n',hbw)
%-----------------------------------------------------------------------
% Determine whether sorting by x or y results in smallest hbw
%
[xx,isort]=sort(x);yx=y(isort);zx=z(isort);[ii,index]=sort(isort);
inx=index(in);
hbwx=(bwidth(inx)-1)/2;
fprintf(1,'new halfbandwidth when sorting by x: %5i\n',hbwx)
%
[yy,isort]=sort(y);xy=x(isort);zy=z(isort);[ii,index]=sort(isort);
iny=index(in);
hbwy=(bwidth(iny)-1)/2;
fprintf(1,'new halfbandwidth when sorting by y: %5i\n',hbwy)
%-----------------------------------------------------------------------
% Output results
%
mesh2=input('Enter the name of the output fem mesh: ','s');
%
if hbwx <= hbwy
   x=xx;y=yx;z=zx;in=inx;
else
   x=xy;y=yy;z=zy;in=iny;
end
%
hbw=(bwidth(in)-1)/2;
fprintf(1,'new halfbandwidth                  : %5i\n',hbwy)
%
fnod=fopen([mesh2,'.nod'],'w');
fele=fopen([mesh2,'.ele'],'w');
fbat=fopen([mesh2,'.bat'],'w');
for i=1:length(x)
   fprintf(fbat,'%i %f\n',i,z(i));
   fprintf(fnod,'%i %f %f\n',i,x(i),y(i));
end
for i=1:length(in(:,1))
   fprintf(fele,'%i %i %i %i\n',i,in(i,:));
end
fclose(fnod);fclose(fele);fclose(fbat);
%-----------------------------------------------------------------------
% Plot mesh after reading new files?
%
if wantplot == 0;break;end;
tallfigure;
hel=drawelems(in,x,y);
set(hel,'color','b');
axis('tight')
title([mesh2,':hbw = ',num2str(hbw)])
%-----------------------------------------------------------------------
