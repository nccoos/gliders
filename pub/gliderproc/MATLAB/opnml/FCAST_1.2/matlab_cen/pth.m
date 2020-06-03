%
% load in nod, ele, and bat files
%
[ele,x,y,z,bnd]=loadgrid('MESHH/g2ssubgom');
%
% initiate subplot and plot desired bathymetric contours
%
subplot(2,2,1),plotbnd(x,y,bnd);
axis('equal');
set(gca,'XLim',[100000 300000]);
set(gca,'YLim',[-50000 150000]);
set(gca,'Box','on');
set(gca,'XTick',[]);
set(gca,'YTick',[]);
cval=[50 100 200];
lcontour2(ele,x,y,z,cval);
hold
% set(gca,'visible','off');
%
% declare title, load and plot desired drogs
%
title('JA/N95/fixed/22days')
[gridname,ndrog,ndts,tsec,pth]=read_pth('JA.22h',4);
npthm=0
for nd=1:ndrog
   for ndt=1:ndts
      npthm=npthm+1;
      npth=nd+(ndt-1)*ndrog;
      for i=1:4
         pthm(npthm,i)=pth(npth,i);
      end
   end
   npthm=npthm+1;
   for i=1:4
      pthm(npthm,i)=0/0;
   end
end
plot(pthm(:,1),pthm(:,2),'y-')
plot(pth(1:ndrog,1),pth(1:ndrog,2),'b*')
