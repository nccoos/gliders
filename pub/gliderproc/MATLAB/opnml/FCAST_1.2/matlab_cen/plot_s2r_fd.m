%
% Load data from files
%
   ls *.s2r
   filename=input('Enter the name of .s2r file: ','s');
   [s2r,gridname]=read_s2r(filename);
   scalar=s2r(:,2);
   gridname=blank(gridname(1:length(gridname)-1));
   [in,x,y,z,bnd]=loadgrid(gridname);
   [y,x]=xy2ll_adr(x,y);
   load(['/usr/people/naimie/meshes/',gridname,'/',gridname,'ll.bfd']);
   bfd=eval([gridname,'ll']);xfd=bfd(:,1);yfd=bfd(:,2);
%
% Reshape fd grid and bathymetric depth arrays
%
   nx=2;while xfd(nx+1)~=xfd(1);nx=nx+1;end;
   ny=length(xfd)/nx;
   xfd=reshape(xfd,nx,ny);
   yfd=reshape(yfd,nx,ny);
   batfd=reshape(bfd(:,10),nx,ny);
%
% Interpolate scalars to fd grid
% (i.e. fd gridpoints outside of domain have nearest node values written to them)
%
   scalar=z;
   scalara=(scalar(bfd(:,4)).*bfd(:,7)+scalar(bfd(:,5)).*bfd(:,8)+scalar(bfd(:,6)).*bfd(:,9))./(bfd(:,7)+bfd(:,8)+bfd(:,9));
   scalara=reshape(scalara,nx,ny);
%
% Interpolate scalars to fd grid for only those fd nodes within domain
% (i.e. fd gridpoints outside of domain have NaN values written to them)
%
   bfdi(:,1:3)=bfd(:,7:9);zz=find(bfd(:,3)==0);bfdi(zz,1:3)=NaN*ones(length(zz),3);
   scalar=z;
   scalari=(scalar(bfd(:,4)).*bfdi(:,1)+scalar(bfd(:,5)).*bfdi(:,2)+scalar(bfd(:,6)).*bfdi(:,3));
   scalari=reshape(scalari,nx,ny);
%
% Plot boundary
%
   figure
   whitebg('w')
   hold on
   bndo=plotbnd(x,y,bnd);
   set(bndo,'Color','k')
   axis('equal')
   [smin,smax,ibw]=colorband_fd_xy_cb(xfd,yfd,scalara,1,-100,1000,100)
   hold on
   lndfill('adrdep2kmgll');
