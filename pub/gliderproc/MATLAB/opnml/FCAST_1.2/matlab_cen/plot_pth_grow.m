%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This matlab script file performs the following steps:
%  1. Read DROG3DDT style .pth file and appropriate grid
%  2. Plot colorbanded bathymetry and land
%  3. Plot numerical drifter trajectories by iteratively adding 
%       nout timesteps worth of paths to the end of each path and
%       outputting .jpg file.
%-----------------------------------------------------------------------
% Load data from files
%  => gridname = name of fe grid on which .pth file was computed
%     ndrog    = number of numerical trajectories
%     ndts     = number of timesteps
%     dtsec    = timestep size in seconds
%     xdr,ydr  = matricies of numerical trajectory coordinates 
%                (ndrog rows and ndts columns)
%     in       = finite element incidence list
%     x,y      = nodal coordinates of finite element grid
%     z        = nodal depths for finite element grid
%     bnd      = outer boundary segments for finite element grid
%
   ls *.pth
   filename=input('Enter the name of .pth file: ','s');
   filename=blank(filename(1:length(filename)-4));
   [gridname,ndrog,ndts,dtsec,pth]=read_pth(filename,4);
   size(pth);
   ndts=ans(1)/ndrog;
   xdr=reshape(pth(:,1),ndrog,ndts)';
   ydr=reshape(pth(:,2),ndrog,ndts)';
   [in,x,y,z,bnd]=loadgrid(gridname);
%-----------------------------------------------------------------------
% Plot boundary
%
   figure;
   whitebg('w');
   set(gcf,'menubar','none');
   set(gca,'XLim',[      0. 500000.]);
   set(gca,'YLim',[-200000. 300000.]);
   set(gca,'Box','on');
   set(gca,'XTick',[]);
   set(gca,'YTick',[]);
   [smin,smax,ibw]=colorband_fe(in,x,y,bnd,z,0,350,50); 
   hold on;
%-----------------------------------------------------------------------
% Plot land
%
landgrid='g2s'
load([landgrid,'.lnd'])
xland=eval([landgrid,'(:,2)']);
yland=eval([landgrid,'(:,3)']);
load([landgrid,'.lel'])
inland=eval([landgrid]);
c=[0.0 0.5 0.0];
for i=1:length(inland)
   hf=fill(xland(inland(i,2:4)),yland(inland(i,2:4)),c);
   set(hf,'EdgeColor','none');
end
%-----------------------------------------------------------------------
% Plot particle tracks - outputing .jpg file every nout timesteps
%    nout = the number of timesteps to include for each iteration 
%           => ndts/nout output .jpg files
   nout=5;
   h=plot(xdr(1,:),ydr(1,:),'r*')
   i=0;
   clear pad;pad='00';
   title(verbatim([filename,': Day ',num2str(i*dtsec/3600/24)]));
   drawnow;
   eval(['print -djpeg ',filename,'_',pad,num2str(i)]); 
   for i=nout+1:nout:ndts
      clear pad;if i < 10;pad='00';elseif i < 100;pad='0';else;pad='';end;
      for j=1:ndrog
         h=plot(xdr(i-nout:i,j),ydr(i-nout:i,j),'k-');
         set(h,'LineWidth',2.0);
      end
      title(verbatim([filename,': Day ',num2str(i*dtsec/3600/24)]));
      drawnow;
      eval(['print -djpeg ',filename,'_',pad,num2str(i)]); 
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
