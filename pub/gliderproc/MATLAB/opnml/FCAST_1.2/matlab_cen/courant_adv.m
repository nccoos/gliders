%
% Load data from files
%
   iter1=2880;
   iter2=8640;
   itperhr=60;
   for iter=iter1:itperhr:iter2
   filename=['vbar_iter_',num2str(iter),'.v2r']
%   filename=input('Enter the name of .v2r file: ','s')
   [v2r,freq,gridname]=read_v2r(filename);
   u=v2r(:,2);
   v=v2r(:,3);
   if iter == iter1
      spd=sqrt(u.*u+v.*v);
   else
      spd=max(spd,sqrt(u.*u+v.*v));
   end
   end
%
% Calculate nodal and elemental areas and deltax's
%
   gridname=blank(gridname(1:length(gridname)-1));
   [in,x,y,z,bnd]=loadgrid(gridname);
   area
%
% Calculate minimum time-step required to ensure courant number <=.1
%
   deltcour=0.1.*dxnod./spd;
   deltmin=min(deltcour)
%
% Make plots
%
   tallfigure
   whitebg('w')
   hel=drawelems(in,x,y)
   set(hel,'color','k')
   hold on
   axis('tight')
   [smina,smaxa,ibw]=colorband_fe(in,x,y,bnd,spd,0.1,1.0,0.1)
   title(['maximum speed (m/s)'])
%
   tallfigure
   whitebg('w')
   hel=drawelems(in,x,y)
   set(hel,'color','k')
   hold on
   axis('tight')
   [smina,smaxa,ibw]=colorband_fe(in,x,y,bnd,dxnod,5000.0,40000.0,5000.0)
   title([gridname,': node based deltax (m)'])
%
   tallfigure
   whitebg('w')
   hel=drawelems(in,x,y)
   set(hel,'color','k')
   hold on
   axis('tight')
   [smina,smaxa,ibw]=colorband_fe(in,x,y,bnd,deltcour,600.0,2000.0,100.0)
   title(['time-step to ensure cour#<0.1: ',num2str(deltmin),' sec'])
%
% Make plots
%
   tallfigure
   whitebg('w')
   subplot(2,2,1)
   hel=drawelems(in,x,y)
   set(hel,'color','k')
   hold on
   axis('tight')
   title(gridname)
   subplot(2,2,2)
   [smina,smaxa,ibw]=colorband_fe(in,x,y,bnd,spd,0.1,1.0,0.1)
   hold on
   axis('tight')
   title(['maximum speed (m/s)'])
   subplot(2,2,3)
   [smina,smaxa,ibw]=colorband_fe(in,x,y,bnd,dxnod,5000.0,40000.0,5000.0)
   hold on
   axis('tight')
   title([gridname,': node based deltax (m)'])
   subplot(2,2,4)
   [smina,smaxa,ibw]=colorband_fe(in,x,y,bnd,deltcour,600.0,2000.0,100.0)
   hold on
   axis('tight')
   title(['time-step to ensure cour#<0.1: ',num2str(deltmin),' sec'])
   newplot=input('New plot? (y/n): ','s');
end
