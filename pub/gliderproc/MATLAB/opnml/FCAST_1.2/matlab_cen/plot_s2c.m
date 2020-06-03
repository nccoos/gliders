ls *.s2c
filename=input('Enter the name of .s2c file: ','s');
[s2c,freq,gridname]=read_v2r(filename);
amp=s2c(:,2);
pha=s2c(:,3);
gridname=blank(gridname(1:length(gridname)-1));
[in,x,y,z,bnd]=loadgrid(gridname);
%
% Plot boundary
%
% figure('Position',[500 500 300 300])
figure
whitebg('w')
hold on
bndo=plotbnd(x,y,bnd);
set(bndo,'Color','k')
axis('equal')
% cval=[50 100 200];
% hc=lcontour2(ele,x,y,z,cval);
% set(hc,'Color','k')
%
% Amplitude contours
%
title([filename])
scalar=amp;
scrange(scalar)
cint=input('Enter the contour interval: ');
if cint > 0
cmin=cint*floor(min(scalar)/cint)
cmax=cint*ceil(max(scalar)/cint)
clear cval
i=1
cval(i)=cmin;
while cval(i) < cmax
   i=i+1;
   cval(i)=cval(i-1)+cint;
end
cval
h=lcontour2(in,x,y,scalar,cval);
end
%
% Phase contours
%
scalar=pha;
scrange(scalar)
cint=input('Enter the contour interval: ');
if cint > 0
cmin=cint*floor(min(scalar)/cint)
cmax=cint*floor(max(scalar)/cint)
clear cval
i=1
cval(i)=cmin;
while cval(i) < cmax
   i=i+1;
   cval(i)=cval(i-1)+cint;
end
cval
h=isophase(in,x,y,scalar,cval);
end
zoom on
