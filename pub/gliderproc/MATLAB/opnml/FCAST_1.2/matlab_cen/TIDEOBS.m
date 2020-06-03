%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% /usr/yes/naimie/YellowSea/yes/FUNDY5/YES_TIDEOBS_M3D.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matlab figure positioning
%-----------------------------------------------------------------------
clear
bdwidth=5;
topbdwidth=30;
set(0,'Units','pixels');
scnsize=get(0,'ScreenSize');
scnx=scnsize(3);scny=scnsize(4);
pos1=[bdwidth,bdwidth,scny/2-2*bdwidth,scny/2-2*topbdwidth];
pos2=[bdwidth,scny/2+bdwidth,scny/2-2*bdwidth,scny/2-2*topbdwidth];
pos3=[pos2(3)+bdwidth,scny/2+bdwidth,scny/2-2*bdwidth,scny/2-2*topbdwidth];
pos4=[pos2(3)+bdwidth,bdwidth,scny/2-2*bdwidth,scny/2-2*topbdwidth];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read data file containing observed tidal observations
%-----------------------------------------------------------------------
ls *ll;
fprintf(1,'\nLocal observational tidal data files:\n',ans)
fprintf(1,'%c',ans)
fprintf(1,'\n')
obsfile=input('Enter the name of the observational tidal data file: ','s');
fprintf(1,'\nObservational data file name: ')
fprintf(1,'%c',obsfile)
fprintf(1,'\n')
nconst=13;
[pfid,message]=fopen([obsfile]);
header=fgets(pfid);
fprintf(1,'\nObservational data file contents:\n')
fprintf(1,'%c',header)
fprintf(1,'\n')
header=fgets(pfid);
header=fgets(pfid);
ii=0;
for i=1:44
   header=fgets(pfid);
   if header(1) == '*'
      ii=ii+1;
      place(ii,:)=fscanf(pfid,'%c',15)';
      data(ii,:)=fscanf(pfid,'%f',2+nconst*2)';
      header=fgets(pfid);
   else
      header=fgets(pfid);
   end
end
fclose(pfid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove missing observations and shrink data array down for desired
% frequency
%-----------------------------------------------------------------------
size(data(:,1));
nobs=ans(1);
nconst=input('Enter the constituent number: ');
% nconst=1;
if nconst == 1
   const='M2'
   freq=0.140519E-03
elseif nconst == 2
   const='S2'
   freq=0.145444E-03
elseif nconst == 3
   const='N2'
   freq=0.137880E-03
elseif nconst == 5
   const='K1'
   freq=0.729212E-04
elseif nconst == 12
   const='M4'
   freq=2.0*0.140519E-03
elseif nconst == 6
   const='O1'
   freq=0.675977E-04
else
   dummy=input('Error!!!!!!!','s')
end
ii=0;
%
for i=1:nobs
    if data(i,3+2*(nconst-1)) > 0.0
       ii=ii+1;
       place2(ii,:)=place(ii,:);
       data2(ii,1)=data(i,1);
       data2(ii,2)=data(i,2);
       data2(ii,3)=data(i,3+2*(nconst-1));
       data2(ii,4)=data(i,4+2*(nconst-1));
    end
end
nobs=ii;
clear data; data=data2; clear data2; clear place; place=place2; clear place2;
fprintf(1,'\nThere are %4.0f positive amplitude observations\n',nobs);
%
xlobs=data(:,1);
ylobs=data(:,2);
[xobs,yobs]=ll2xy_yes(ylobs,xlobs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load .s2c file and finite element mesh
% Plot observational names and locations
% Load model data arrays at observational locations
%-----------------------------------------------------------------------
ls *.s2c;
fprintf(1,'\nLocal .s2c files:\n',ans)
fprintf(1,'%c',ans)
fprintf(1,'\n')
modfile=input('Enter the name of model generated .s2c file: ','s');
[s2c,freqm,mesh]=read_v2r(modfile);
freq
freqm
amp=s2c(:,2);
pha=s2c(:,3);
mesh=blank(mesh(1:length(mesh)-1));
[in,x,y,z,bnd]=loadgrid(mesh);
[yl,xl]=xy2ll_yes(x,y);
%
figure('Position',pos4);
whitebg('w')
bndo=plotbnd(xl,yl,bnd);
set(bndo,'Color','k')
hold on
plot(xlobs,ylobs,'bo')
size(xlobs);
nobs=ans(1);
for i=1:nobs
   text(xlobs(i)+0.05,ylobs(i),place(i,:))
end
%
for i=1:nobs
   [smin(i),nclosest(i)]=min((x-xobs(i)).^2.0+(y-yobs(i)).^2.0);
   mdata(i,1)=xl(nclosest(i));
   mdata(i,2)=yl(nclosest(i));
   mdata(i,3)=amp(nclosest(i));
   mdata(i,4)=pha(nclosest(i));
   if (mdata(i,4)-data(i,4)) > 180
      mdata(i,4)=pha(nclosest(i))-360.0;
   elseif (mdata(i,4)-data(i,4)) < -180
      mdata(i,4)=pha(nclosest(i))+360.0;
   end
end
plot(mdata(:,1),mdata(:,2),'rx');
axis('tight')
% close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform statistical comparison
% Make histogram plot of statistical comparison
%-----------------------------------------------------------------------
amperr=100*(mdata(:,3)-data(:,3));
phaerr=mdata(:,4)-data(:,4);
amperrmean=mean(abs(amperr));
amperrbias=mean(amperr);
amperrstd=std(amperr);
phaerrmean=mean(abs(phaerr));
phaerrbias=mean(phaerr);
phaerrstd=std(phaerr);
fprintf(1,'\nAmplitude Error Statistics (mean, bias, std): %5.1f %5.1f %5.1f\n',amperrmean,amperrbias,amperrstd)
fprintf(1,'Phase Error Statistics     (mean, bias, std): %5.1f %5.1f %5.1f\n',phaerrmean,phaerrbias,phaerrstd)
%
figure('Position',pos1)
whitebg('w')
subplot(2,1,1)
hist(amperr)
hold on
axis([-round(mean(100.0*data(:,3))) round(mean(100.0*data(:,3))) 0.0 20.0])
title([verbatim(modfile),': Error Histograms; (mean amp = ',num2str(round(mean(100.0*data(:,3)))),' cm)'])
xlabel(['Amplitude Error (cm): [mean,bias,std]=[',num2str(round(amperrmean)),',',num2str(round(amperrbias)),',',num2str(round(amperrstd)),']'])
ylabel('Number of Observations')
zoom on
subplot(2,1,2)
hist(phaerr)
hold on
axis([-180.0 180.0 0.0 20.0])
xlabel(['Phase Error (deg): [mean,bias,std]=[',num2str(round(phaerrmean)),',',num2str(round(phaerrbias)),',',num2str(round(phaerrstd)),']'])
ylabel('Number of Observations')
zoom on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot FEM boundary, model results, and observational data(?)
%-----------------------------------------------------------------------
% moreplots=input('\nProceed with amplitude and phase plots (y/n)? ','s');
moreplots='y';
if moreplots == 'y'
%
figure('Position',pos2)
whitebg('w');
colorcontour_fe(in,xl,yl,bnd,100.0*amp);
hold on
plot(xlobs,ylobs,'bo')
% choice=input('Labels of Obs Amp or Amp Errors (o/e)? ','s');
choice='e';
if choice=='o'
   text(xlobs,ylobs,num2str(round(100*data(:,3))));
   title([verbatim(modfile),': Observed ',const,' Mod Amp and Obs Amp (cm)']);
else
   text(xlobs,ylobs,num2str(round(100*(mdata(:,3)-data(:,3)))))
   title([verbatim(modfile),': Observed ',const,' Mod Amp - Obs Amp (cm):  RMS=',num2str(100*(rms(mdata(:,3)-data(:,3))))])
end
axis('tight')
zoom on
%
figure('Position',pos3);
whitebg('w');
colorcontour_fep(in,xl,yl,bnd,pha);
hold on;
plot(xlobs,ylobs,'bo');
% choice=input('Labels of Obs Phase or Phase Errors (o/e)? ','s');
choice='e';
if choice=='o'
   text(xlobs,ylobs,num2str(round(data(:,4))));
   title([verbatim(modfile),': Observed ',const,' Mod Phase and Obs Phase (deg)']);
else
   text(xlobs,ylobs,num2str(round((mdata(:,4)-data(:,4)))))
   title([verbatim(modfile),': Observed ',const,' Mod Phase - Obs Phase (deg):  RMS=',num2str(rms(mdata(:,4)-data(:,4)))]);
end
axis('tight')
zoom on
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert zeta to time domain (24 samples per tidal period)
%-----------------------------------------------------------------------
for i=1:24
   tday(i)=(i-1)/24.0*2.0*pi/freq/3600.0/24.0;
   for ii=1:nobs
      elev_obs(i,ii)=data(ii,3)*cos((i-1)/24.0*2.0*pi-data(ii,4)*pi/180.);
      elev_mod(i,ii)=amp(nclosest(ii))*cos((i-1)/24.0*2.0*pi-pha(nclosest(ii))*pi/180.);
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot time-domain reconstruction of observations and model results
%  at closest nodes (?)
%-----------------------------------------------------------------------
% moreplots=input('\nProceed with plots of observed and modeled elevation(t) (y/n)? ','s');
moreplots='n';
if moreplots == 'y'
for ifigure=1:ceil(nobs/35)
   figure
   for ii=1+(ifigure-1)*35:min(ifigure*35,nobs)
      ipanel=ii-(ifigure-1)*35
      subplot(7,5,ipanel)
      hold on
      title(place(ii,:))
      plot(tday,elev_obs(:,ii),'b-')
      plot(tday,elev_mod(:,ii),'r-.')
   end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output *m3d files if desired
%-----------------------------------------------------------------------
% ans=input('Output .m3d files? (y/n)  ','s')
ans='y';
if ans == 'y'
fidobs=fopen([const,'_obs.m3d'],'w');
fprintf(fidobs,'XXXX\n');
fprintf(fidobs,'%c',mesh);
fprintf(fidobs,'\nObserved elevations mapped to nearest finite element mesh nodes\n1995\n6\n');
fidmod=fopen([const,'_mod.m3d'],'w');
fprintf(fidmod,'XXXX\n');
fprintf(fidmod,'%c',mesh);
fprintf(fidmod,'\nModel elevations at finite element mesh nodes nearest observational sites\n1995\n6\n');
for i=1:24
   for ii=1:nobs
%      fprintf(fidobs,'%12.4f %12.4f %12.4f %12.4f %12.4f %12.4f\n',tday(i),xobs(ii),yobs(ii),elev_obs(i,ii),elev_obs(i,ii),elev_obs(i,ii));
      fprintf(fidobs,'%12.4f %12.4f %12.4f %12.4f %12.4f %12.4f\n',tday(i),x(nclosest(ii)),y(nclosest(ii)),elev_obs(i,ii),elev_obs(i,ii),elev_obs(i,ii));
      fprintf(fidmod,'%12.4f %12.4f %12.4f %12.4f %12.4f %12.4f\n',tday(i),x(nclosest(ii)),y(nclosest(ii)),elev_mod(i,ii),elev_mod(i,ii),elev_mod(i,ii));
   end
end
fclose(fidobs);
fclose(fidmod);
end
