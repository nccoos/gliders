function plot_pth_only(filename,cl)
%
% Read .pth file
%
   filename=blank(filename(1:length(filename)-4));
   [gridname,ndrog,ndts,tsec,pth]=read_pth(filename,4);
   size(pth);
   ndts=ans(1)/ndrog;
   xdr=pth(:,1);
   xdr=reshape(xdr,ndrog,ndts);
   xdr=xdr';
   ydr=pth(:,2);
   ydr=reshape(ydr,ndrog,ndts);
   ydr=ydr';
%
% Plot particle tracks
%
   h=plot(xdr(1,:),ydr(1,:),[cl(1:1),'o'])
   for i=1:ndrog
      h=plot(xdr(:,i),ydr(:,i),cl)
   end
