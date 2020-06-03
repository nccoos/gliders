%
% Load data from files
%
%   filename=input('Enter the name of .sq4 file: ','s');
scalarc=input('Enter variable you desire to contour (u,v,w,rho,T,S,q2,q2l,enzm,enzh,enzq): ','s');
for i=1:216
   filename=['SF_iter_',num2str(i),'_v.sq4']
   load(filename);
   vsq4=eval(blank(filename(1:length(filename)-4)));
%
% Set data arrays
%
   x=vsq4(:,1);
   y=vsq4(:,2);
   u=vsq4(:,3);
   v=vsq4(:,4);
   w=vsq4(:,5);
   rho=vsq4(:,6);
   T=vsq4(:,7);
   S=vsq4(:,8);
   q2=vsq4(:,9);
   q2l=vsq4(:,10);
   enzm=vsq4(:,11);
   enzh=vsq4(:,12);
   enzq=vsq4(:,13);
%
   nnv=21
   size(x);
   nn=ans(1);
   ny=nnv;
   nx=nn/nnv;
   xx=flipud(reshape(x,nnv,nx));
   yy=flipud(reshape(y,nnv,nx));
   scalar=flipud(reshape(eval(scalarc),nnv,nx));;
   if i==1
      [smin,smax,ibw]=colorband_fd_xy_cb(xx,yy,scalar,1);
   else
      [smin,smax,ibw]=colorband_fd_xy_cb(xx,yy,scalar,1,smin,smax,ibw);
   end
   title(['Hour ',num2str(i)]);
   drawnow;
end
