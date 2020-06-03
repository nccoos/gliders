newplot='y';
while newplot == 'y',
%
% Load data from files
%
   ls *.pth
   filename=input('Enter the name of .pth file: ','s');
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
   gridname=input('Enter the input path for grid files: (e.g. ../MESH/bank150)','s');
   gridstruct=loadgrid(gridname);
%
% Plot boundary
%
   figure
   whitebg('w')
   hold on
   bndo=plotbnd(gridstruct);
   set(bndo,'Color','k')
   axis('equal')
%   cval=[50 100 200];
%   hc=lcontour2(ele,x,y,z,cval);
%   set(hc,'Color','k')
%
% Plot particle tracks
%
   h=plot(xdr(1,:),ydr(1,:),'r*')
   for i=1:ndrog
      h=plot(xdr(:,i),ydr(:,i),'b-')
   end
   title(verbatim(filename))
   zoom on
   newplot=input('New plot? (y/n): ','s');
end
