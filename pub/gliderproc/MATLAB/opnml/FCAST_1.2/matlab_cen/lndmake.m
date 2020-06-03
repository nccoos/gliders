%-----------------------------------------------------------------------
% function lndmake
% read boundary element and node files and create land and island 
% polygons
%-----------------------------------------------------------------------
function lndmake
%-----------------------------------------------------------------------
% Read boundary elements
%
!ls *.bel
filebel=input('Enter the name of the boundary element file: ','s');
[x,y,bel,gridname]=read_bel(filebel);
%
% Outer land boundary
%
sea=find(bel(:,5)==2);
polygon=bel(1:sea(1)-1,2);
xp=x(polygon);yp=y(polygon);
%
xrange=max(xp)-min(xp);yrange=max(yp)-min(yp);
ni=length(xp)+1; xp(ni)=xp(1);              yp(ni)=yp(1);
ni=length(xp)+1; xp(ni)=min(xp)-0.1*xrange; yp(ni)=yp(ni-1);
ni=length(xp)+1; xp(ni)=xp(ni-1);           yp(ni)=max(yp)+0.1*yrange;
ni=length(xp)+1; xp(ni)=max(xp)+0.1*xrange; yp(ni)=yp(ni-1);
ni=length(xp)+1; xp(ni)=xp(ni-1);           yp(ni)=min(yp)-0.1*yrange;
ni=length(xp)+1; xp(ni)=xp(1)  -0.1*xrange; yp(ni)=yp(ni-1);
ni=length(xp)+1; xp(ni)=xp(1)  -0.1*xrange; yp(ni)=yp(1);
%
figure;
whitebg('w');
hp=plot(xp,yp,'b-');
hold on
%
fnod=fopen([gridname,'.lnd'],'w');
fbel=fopen([gridname,'.lbe'],'w');
ione=1;
for i=1:length(xp)-1
   fprintf(fnod,'%i %f %f\n',i,xp(i),yp(i));
   fprintf(fbel,'%i %i %i\n',i,i,i+1);
end
i=length(xp);
fprintf(fnod,'%i %f %f\n',i,xp(i),yp(i));
fprintf(fbel,'%i %i %i\n',i,i,ione);
%
% first island
%
clear polygon;
i1=sea(1);
i2=find(bel(:,3)==bel(i1,2));
polygon=bel(i1:i2,2);
xp=x(polygon);yp=y(polygon);
hp=plot(xp,yp,'r-');
%
ione=i+1;
for ii=1:length(xp)-1
   i=i+1;
   fprintf(fnod,'%i %f %f\n',i,xp(ii),yp(ii));
   fprintf(fbel,'%i %i %i\n',i,i,i+1);
end
i=i+1;
fprintf(fnod,'%i %f %f\n',i,xp(length(xp)),yp(length(xp)));
fprintf(fbel,'%i %i %i\n',i,i,ione);
%
% remaining islands
%
while i2 < length(bel)
%
   i1=i2+1;
   i2=find(bel(:,3)==bel(i1,2));
   polygon=bel(i1:i2,2);
   xp=x(polygon);yp=y(polygon);
   hp=plot(xp,yp,'r-');
%
   ione=i+1;
   for ii=1:length(xp)-1
      i=i+1;
      fprintf(fnod,'%i %f %f\n',i,xp(ii),yp(ii));
      fprintf(fbel,'%i %i %i\n',i,i,i+1);
   end
   i=i+1;
   fprintf(fnod,'%i %f %f\n',i,xp(length(xp)),yp(length(xp)));
   fprintf(fbel,'%i %i %i\n',i,i,ione);
end
fclose(fnod);
fclose(fbel);
%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
