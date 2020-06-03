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
% Plot Tidal Amplitudes
%
title([filename])
scalar=amp;
scrange(scalar)
cint=input('Enter the contour interval: ');
if cint > 0
cmin=cint*ceil(min(scalar)/cint);
cmax=cint*floor(max(scalar)/cint);
clear cval
i=1;
cval(i)=cmin;
while cval(i) < cmax
   i=i+1;
   cval(i)=cval(i-1)+cint;
end
cval
% [csa,ha]=lcontour3(in,x,y,scalar,cval);
[csa,ha]=lcontour3_holboke(in,x,y,scalar,cval);
hla=clabel(csa,ha,'manual')
% hlabel=extclabel(csa,'fontsize',6);
% delete(ha)
end
%
% Plot Tidal Phases
%
title([filename])
scalar=pha;
scrange(scalar)
cint=input('Enter the contour interval: ');
if cint > 0
cmin=cint*ceil(min(scalar)/cint);
cmax=cint*floor(max(scalar)/cint);
clear cval
i=1;
cval(i)=cmin;
while cval(i) < cmax
   i=i+1;
   cval(i)=cval(i-1)+cint;
end
cval
%[csp,hp]=lcontour3(in,x,y,scalar,cval);
[csp,hp]=lcontour3_holboke(in,x,y,scalar,cval);
set(hp,'Color','g');
hlp=clabel(csp,hp,'manual')
% hlabel=extclabel(cs,'fontsize',6);
% delete(h)
end
%
%
%
