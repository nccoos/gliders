clear
for i=1:23,
   [s2c2,freq,gridname]=read_v2r(['m2zeta',num2str(i+1),'.s2c']);
   [s2c1,freq,gridname]=read_v2r(['m2zeta',num2str(i),'.s2c']);
   i
   diff(i,:)=mean(s2c2-s2c1)
end
figure
whitebg('w')
orient tall
wysiwyg
subplot(4,4,9)
plot(diff(:,2),'k-')
title('amp.s2c')
set(gca,'XLim',[0 25]);
grid('on')
subplot(4,4,10)
plot(diff(:,3),'k-')
title('pha.s2c')
set(gca,'XLim',[0 25]);
grid('on')
drawnow
%
%
%
clear
for i=1:23,
   [s2c2,freq,gridname]=read_v2r(['resvbar',num2str(i+1),'.v2r']);
   [s2c1,freq,gridname]=read_v2r(['resvbar',num2str(i),'.v2r']);
   i
   diff(i,:)=mean(s2c2-s2c1)
end
subplot(4,4,5)
plot(diff(:,2),'k-')
title('u.v2r')
set(gca,'XLim',[0 25]);
grid('on')
subplot(4,4,6)
plot(diff(:,3),'k-')
title('v.v2r')
set(gca,'XLim',[0 25]);
grid('on')
drawnow
%
%
%
clear
for i=1:23,
   [s2c2,gridname]=read_s2r(['reszeta',num2str(i+1),'.s2r']);
   [s2c1,gridname]=read_s2r(['reszeta',num2str(i),'.s2r']);
   i
   diff(i,:)=mean(s2c2-s2c1)
end
subplot(4,4,1)
plot(diff(:,2),'k-')
title('.s2r')
set(gca,'XLim',[0 25]);
grid('on')
drawnow
%
%
%
clear
for i=1:23,
   [s2c2,freq]=read_v2c(['m2vbar',num2str(i+1),'.v2c']);
   [s2c1,freq]=read_v2c(['m2vbar',num2str(i),'.v2c']);
   i
   diff(i,:)=mean(s2c2-s2c1)
end
subplot(4,4,13)
plot(diff(:,2),'k-')
title('uamp.v2c')
set(gca,'XLim',[0 25]);
grid('on')
subplot(4,4,14)
plot(diff(:,3),'k-')
title('upha.v2c')
set(gca,'XLim',[0 25]);
grid('on')
subplot(4,4,15)
plot(diff(:,4),'k-')
title('vamp.v2c')
set(gca,'XLim',[0 25]);
grid('on')
subplot(4,4,16)
plot(diff(:,5),'k-')
title('vpha.v2c')
set(gca,'XLim',[0 25]);
grid('on')
drawnow
