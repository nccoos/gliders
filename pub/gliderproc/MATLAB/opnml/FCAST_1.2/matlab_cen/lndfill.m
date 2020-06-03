% function lndfill(landname,color)
function lndfill(landname,color)
%
% Set color (if not sent)
if nargin == 1;color=[0.8 0.8 0.8];end
%
% Load data from .lnd and .lbe files
load([landname,'.lnd']);x=eval([landname,'(:,2)']);y=eval([landname,'(:,3)']);
load([landname,'.lbe']);bel=eval([landname]);
%
% colorfill land and islands
hold on
i2=0;
while i2 < length(bel)
%
   i1=i2+1;
   i2=find(bel(:,3)==bel(i1,2));
   polygon=bel(i1:i2,2);
   xp=x(polygon);yp=y(polygon);
   hf=fill(xp,yp,color);
%   set(hf,'EdgeColor',color')
end
break
%-----------------------------------------------------------------------
% Below here are the commands used to make the .lnd and .lbe files for
% the adrdep2kmg grid (i.e. input from the adrionA grid)
%-----------------------------------------------------------------------
load adrionA.nod; 
x=adrionA(:,2);
y=adrionA(:,3);
load adrionA_tides.bel;
bel=adrionA_tides;
clear polygon;
%
% Outer land boundary
%
sea=find(bel(:,5)==5);
polygon=bel(1:sea(1),2);
xp=x(polygon);yp=y(polygon);
%
ni=length(xp)+1; xp(ni)=min(xp)-200000.0; yp(ni)=yp(ni-1);
ni=length(xp)+1; xp(ni)=xp(ni-1);         yp(ni)=max(yp)+200000.0;
ni=length(xp)+1; xp(ni)=max(xp)+200000.0; yp(ni)=yp(ni-1);
ni=length(xp)+1; xp(ni)=xp(ni-1);         yp(ni)=yp(1);
%
figure
hp=plot(xp,yp,'b-');
hold on
%
fnod=fopen('adrdep2kmg.lnd','w');
fbel=fopen('adrdep2kmg.lbe','w');
ione=1
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
i1=sea(length(sea))+1
i2=find(bel(:,3)==bel(i1,2))
polygon=bel(i1:i2,2);
xp=x(polygon);yp=y(polygon);
hp=plot(xp,yp,'r-');
%
ione=i+1
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
   ione=i+1
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
% Below here are the commands used to make the .lnd and .lbe files for
% the yessub grid (i.e. input from the yessoj grid)
%-----------------------------------------------------------------------
load yessoj.bdry.nod; 
x=yessoj(:,2);
y=yessoj(:,3);
load yessoj.bdry.bel;
bel=yessoj;
clear polygon;
%
% Outer land boundary
%
sea=find(bel(:,5)==2);
polygon=bel(1:sea(1)-1,2);
xp=x(polygon);yp=y(polygon);
%
ni=length(xp)+1; xp(ni)=min(xp)-200000.0; yp(ni)=yp(ni-1);
ni=length(xp)+1; xp(ni)=xp(ni-1);         yp(ni)=max(yp)+200000.0;
ni=length(xp)+1; xp(ni)=max(xp)+200000.0; yp(ni)=yp(ni-1);
ni=length(xp)+1; xp(ni)=xp(ni-1);         yp(ni)=min(yp)-200000.0;
ni=length(xp)+1; xp(ni)=xp(1)-200000.0; yp(ni)=yp(ni-1);
ni=length(xp)+1; xp(ni)=xp(1)-200000.0;   yp(ni)=yp(1);
%
figure
hp=plot(xp,yp,'b-');
hold on
%
fnod=fopen('yessoj.lnd','w');
fbel=fopen('yessoj.lbe','w');
ione=1
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
i1=sea(1)
i2=find(bel(:,3)==bel(i1,2))
polygon=bel(i1:i2,2);
xp=x(polygon);yp=y(polygon);
hp=plot(xp,yp,'r-');
%
ione=i+1
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
   ione=i+1
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
