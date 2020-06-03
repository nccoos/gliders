function [cval,nband,cmap]=jetmap_band(smin,smax,ibw,cbflag)
cval=smin:ibw:smax;
ncolors=(smax-smin)/ibw;
nband=ncolors+2;
colormap(zeros(ncolors,3));jetmap=jet;
cmap(1,:)=[0 0 0];
for i=1:ncolors
   cmap(i+1,:)=jetmap(i,:);
end
cmap(nband,:)=[1 1 1];
colormap(cmap);caxis([smin-ibw smax+ibw]);
cmap
if cbflag == 1
   in=[1 2 3 3];x=[0;1;1];y=[0;0;1];z=[0;0;0];
   hc=colormeshm(in,x,y,z);
   hb=colorbar;
   set(hb,'ytick',cval);
   set(hb,'YAxisLocation','right');
   set(hb,'ticklength',[0.05 0.025]);
   set(hb,'FontSize',1.0);
   colormap(cmap);caxis([smin-ibw smax+ibw]);
   delete(hc)
   set(gca,'Visible','off');
   drawnow;
end
