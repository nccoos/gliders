%/////////////////////////////////////////////////////////////////////////////////////
%  William Stark
%  Graduate Research Assistant
%  Department of Marine Sciences
%  University of North Carolina - Chapel Hill
%  Chapel Hill NC
%
%  Filename:    GrabDATA_TBD.m
%
%  Description: Reads in data from glider science persistor ascii files (tbd's) and 
%               uses it to generate a series of plots and matlab files.
%
%  Created:     18 Dec 2011
%   revisions:  26 Jan 2012  - HS to configure for ramses output on LB
%   missions
%               5 Oct 2018 - HES - configure for Modena deployment during
%               PEACH
%/////////////////////////////////////////////////////////////////////////////////////
trnum='tr15';

% DATA FILES DIRECTORY PATH ===================================
%sbddir='/afs/isis/depts/marine/workspace/hseim/credward/glider/viz/asc/';
%datadir = '/Users/haloboy/Documents/MASC/SEIM_LAB/GLIDERS/GLIDER_DATA_FILES/TBD_1/';
datadir = ['/Users/heseim/Documents/2018/peach/gliders/modena/tbdasc/'];

% IMAGE FILES DIRECTORY PATH ===================================
%imgdir='/afs/isis/depts/marine/workspace/hseim/credward/glider/viz/images/';
%imgdir = '/Users/haloboy/Documents/MASC/SEIM_LAB/GLIDERS/GLIDER_DATA_IMAGES/from_TBD_1/';
imgdir = '/Users/heseim/Documents/2018/peach/gliders/modena/images/';

% set paths for required files...
%addpath('/Users/haloboy/Documents/MASC/SEIM_LAB/GLIDERS/util/');
%addpath('/Users/haloboy/Documents/MASC/SEIM_LAB/GLIDERS/matutil/');
%addpath('/Users/haloboy/Documents/MASC/SEIM_LAB/GLIDERS/seawater/');
%addpath('/Users/haloboy/Documents/MASC/SEIM_LAB/GLIDERS/plots/');
%addpath('/Users/haloboy/Documents/MASC/SEIM_LAB/GLIDERS/strfun/');
%addpath('/Users/haloboy/Documents/MASC/SEIM_LAB/GLIDERS/opnml/');
%addpath('/Users/haloboy/Documents/MASC/SEIM_LAB/GLIDERS/opnml/FEM/');
addpath('/Users/heseim/Documents/MATLAB/seawater/');
addpath('/Users/heseim/Documents/MATLAB/cre_matlab/glider/');

% try to load all *.tbdasc files at once...
[files, Dstruct] = wilddir(datadir, '.tbdasc');
%files = wilddir(sbddir, '.asc');
nfile = size(files, 1);


% declare variables for storing data...
temp=[];
cond=[];
pres=[];
mlon=[];
mlat=[];
glon=[];
glat=[];
wlon=[];
wlat=[];
mt=[];
vx=[];
vy=[];
rt=[];
z=[];
scioxy=[];
scioxysat=[];
scibb=[];
scicdom=[];
scichlor=[];




%*** READ IN TEST DATA ***************************************************
for i=1:nfile

  % protect against empty sbd file
  if(Dstruct(i).bytes>0)
    data = read_gliderasc([datadir,files(i,:)]);
  end
  
  % protect against files with incomplete header
  if(isempty(strmatch('sci_m_present_time',data.vars)))
      data.vars = {'sci_m_present_time',
                    'm_present_secs_into_mission',                    
                    'sci_water_cond',
                    'sci_water_temp',
                    'sci_water_pressure'
                    'sci_oxy4_saturation',
                    'sci_oxy4_oxygen',
                    'sci_flbbcd_bb_units',
                    'sci_flbbcd_cdom_units',
                    'sci_flbbcd_chlor_units'};   
  end
  
  % populate local variables with data...
  if(~isempty(data.data))
      % purge data of bad values...
      %test = data.data(:,2:14);
      %test(test>69696969) = nan;
      %data.data(:,2:14) = test;

      % assign values...
      temp = [temp;data.data(:,strmatch('sci_water_temp',data.vars))];               % temperature
      cond = [cond;data.data(:,strmatch('sci_water_cond',data.vars))];               % conductivity
      pres = [pres;data.data(:,strmatch('sci_water_pressure',data.vars))];           % pressure (measure of depth) science bay
 %     mt = [mt;data.data(:,strmatch('sci_m_present_secs_into_mission',data.vars))];  % elapsed mission time
      rt = [rt;data.data(:,strmatch('sci_m_present_time',data.vars))];               % present time  
     scioxysat = [scioxysat;data.data(:,strmatch('sci_oxy4_saturation',data.vars))];     % dissolved oxygen
     scioxy = [scioxy;data.data(:,strmatch('sci_oxy4_oxygen',data.vars))];     % dissolved oxygen
      scibb = [scibb;data.data(:,strmatch('sci_flbbcd_bb_units',data.vars))];          % bb ????
      scicdom = [scicdom;data.data(:,strmatch('sci_flbbcd_cdom_units',data.vars))];    % cdom
      scichlor = [scichlor;data.data(:,strmatch('sci_flbbcd_chlor_units',data.vars))]; % chlorophyll
  end
end
nlast=i;
%********************************************************************

% HES - get time monotonic and sort appropriately

[ts,isort] = sort(rt);
rt = ts;
temp = temp(isort);
cond = cond(isort);
pres = pres(isort);
scioxysat = scioxysat(isort);
scioxy = scioxy(isort);
scibb = scibb(isort);
scicdom = scicdom(isort);
scichlor = scichlor(isort);

% clip out zeros
temp(temp<1) = nan;
cond(cond<1) = nan;

% calculate salinity...
salin = sw_salt(10*cond/sw_c3515, temp, 10*pres);
depth = sw_dpth(pres*10,36);

% eliminate salinity outliers by setting them to NaN...
salin(salin>38) = nan;

% calculate density...
rho = sw_dens(salin, temp, 10*pres);    % in situ density
%rho = sw_dens0(salin,temp);            % potential density

% convert rt into datenum style...
rt = rt/3600/24+datenum(1970, 1, 1, 0, 0, 0);
rthrly = fix(rt*24)/24;
rtdaily = fix(rt);
rtdaily2 = unique(rtdaily);
rtdaily2 = rtdaily2(1:2:end);

ind = wlon==0 & wlat==0; 
wlon(ind) = nan;
wlat(ind) = nan;
%dzdt = diff(z(~isnan(z)))./diff(rt(~isnan(z))); 

% some QC

ib = find(scioxysat < 70);
scioxysat(ib) = nan;
scioxy(ib) = nan;

% find upper and lower limits for each variable...
temp_low = nanmin(temp);
temp_low = floor(temp_low);
temp_high = nanmax(temp);
temp_high = ceil(temp_high);
%temp_low = 11.;
% temp_high = 23.;

rho_low = nanmin(rho);
rho_low = floor(rho_low);
rho_high = nanmax(rho);
rho_high = ceil(rho_high);
% rho_low = 1024.85;
%rho_high = 1026.2;

salin_low = nanmin(salin);
salin_low = floor(salin_low);
salin_high = nanmax(salin);
salin_high = ceil(salin_high);
% salin_low = 34.;
% salin_high = 36.5;

scioxy_low = nanmin(scioxy);
scioxy_low = floor(scioxy_low);
scioxy_high = nanmax(scioxy);
scioxy_high = ceil(scioxy_high);
% scioxy_low = 30;
% %scioxy_high = 95;
% 
% 
scioxysat_low = nanmin(scioxysat);
scioxysat_low = floor(scioxysat_low);
scioxysat_high = nanmax(scioxysat);
scioxysat_high = ceil(scioxysat_high);
scioxysat_low = 50;
% %scioxy_high = 95;

scibb_low = nanmin(scibb);
scibb_low = floor(scibb_low);
scibb_high = nanmax(scibb);
scibb_high = ceil(scibb_high);
%scibb_low = 0;
scibb_high = 0.01;

scicdom_low = nanmin(scicdom);
scicdom_low = floor(scicdom_low);
scicdom_high = nanmax(scicdom);
scicdom_high = ceil(scicdom_high);
%scicdom_low = 1;
scicdom_high = 50;

scichlor_low = nanmin(scichlor);
scichlor_low = floor(scichlor_low);
scichlor_high = nanmax(scichlor);
scichlor_high = ceil(scichlor_high);
scichlor_low = 0;
%scichlor_high = 10;



% BEGIN PLOT ********************************************************************
hf1=figure; 
%set(gcf, 'visible', 'off', 'renderer', 'painter');

% draw plot - density vs depth profiles
subplot(131)
hc = cplot(rho, pres*10, rt);  % density vs. depth

% scale the x-axis...
ax = axis;
axis([rho_low rho_high ax(3) ax(4)]);

set(gca, 'fontsize', 12, 'ydir', 'reverse');
%hc2 = colorbar;
%set(hc2, 'fontsize', 12, 'ytick', unique(rtdaily2));
%datetick(hc2, 'y', 6, 'keeplimits', 'keepticks');
ylabel('depth (m)');
xlabel('density (kg/m^3)');
%title('\rho, MM/DD GMT');
pos = get(get(gca, 'title'), 'position');
%something weird with date, trying something else
ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - TBDs']);
set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'density_vs_depth_tbd.jpg']);
% END PLOT **********************************************************************

% BEGIN PLOT ********************************************************************
hf2=figure; 
subplot(311)
%hc = cplot(rt, pres*10, rho);  % density vs. depth vs. time
hc = ccplot(rt,pres*10,rho,[rho_low rho_high],'.',10);

% scale the x-axis...
%ax = axis;
%axis([87 93 ax(3) ax(4)]);

% scale the color bar...
%caxis([1024 1027]);

%set(gca, 'fontsize', 12, 'ydir', 'reverse', 'xtick', unique(rtdaily2));
set(gca, 'fontsize', 12, 'ydir', 'reverse');
datetick('x', 6, 'keeplimits', 'keepticks');
hc = colorbar;
caxis([rho_low rho_high]);
set(hc, 'fontsize', 12);
ylabel('depth (m)');
%xlabel('MM/DD GMT');
title('');
pos = get(get(gca, 'title'), 'position');
set(get(gca, 'title'), 'position', pos-[0 -0.5 0]);
ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' \rho (kg/m^3) - TBDs']);
set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'density_vs_depth_vs_time_tbd.jpg']);
% END PLOT **********************************************************************





% BEGIN PLOT ********************************************************************
figure(hf1)
subplot(132); 
%set(gcf, 'visible', 'off', 'renderer', 'painter');

% draw plot...salinity profiles
hc = cplot(salin, pres*10, rt);  % salinity vs. depth

% scale the x-axis...
ax = axis;
axis([salin_low salin_high ax(3) ax(4)]);

set(gca, 'fontsize', 12, 'ydir', 'reverse');
%hc2 = colorbar;
%set(hc2, 'fontsize', 12, 'ytick', unique(rtdaily2));
%datetick(hc2, 'y', 6, 'keeplimits', 'keepticks');
%ylabel('depth (m)');
xlabel('salinity (psu)');
%title('\rho, MM/DD GMT');
title('RAMSES')
%pos = get(get(gca, 'title'), 'position');
%ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - TBDs']);
%set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'salinity_vs_depth_tbd.jpg']);
% END PLOT **********************************************************************

% BEGIN PLOT ********************************************************************
figure(hf2)
subplot(312); 
%hc = cplot(rt, pres*10, salin);  % salinity vs. depth vs. time
hc = ccplot(rt,pres*10,salin,[salin_low salin_high],'.',10);

% scale the x-axis...
%ax = axis;
%axis([87 93 ax(3) ax(4)]);

% scale the color bar...
%caxis([35.7 37]);

set(gca, 'fontsize', 12, 'ydir', 'reverse');
datetick('x', 6, 'keeplimits', 'keepticks');
hc = colorbar;
caxis([salin_low salin_high]);
set(hc, 'fontsize', 12);
ylabel('depth (m)');
%xlabel('MM/DD GMT');
title('');
pos = get(get(gca, 'title'), 'position');
set(get(gca, 'title'), 'position', pos-[0 -0.5 0]);
%ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' sal - TBDs']);
ht = text(pos(1), pos(2)-2.35,  [' RAMSES sal - TBDs']);
set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'salinity_vs_depth_vs_time_tbd.jpg']);
% END PLOT **********************************************************************





% BEGIN PLOT ********************************************************************
figure(hf1);
subplot(133)
%set(gcf, 'visible', 'off', 'renderer', 'painter');

% draw plot...temperature profiles
hc = cplot(temp, pres*10, rt);  % depth vs. temperature

% scale the x-axis...
ax = axis;
axis([temp_low temp_high ax(3) ax(4)]);

set(gca, 'fontsize', 12, 'ydir', 'reverse');
hc2 = colorbar;
%set(hc2, 'fontsize', 12, 'ytick', unique(rtdaily2));
set(hc2, 'fontsize', 12);
% datetick(hc2, 'y', 6, 'keeplimits', 'keepticks');
%ylabel('depth (m)');
xlabel('temperature (deg C)');
%title('\rho, MM/DD GMT');
pos = get(get(gca, 'title'), 'position');
%ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - TBDs']);
%set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'temperature_vs_depth_tbd.jpg']);
print('-djpeg90', [imgdir, trnum,'_ram_tsrho_vs_depth_tbd.jpg']);
% END PLOT **********************************************************************

% BEGIN PLOT ********************************************************************
figure(hf2); 
subplot(313)
%hc = cplot(rt, pres*10, temp);  % temperature vs. depth vs. time
hc = ccplot(rt,pres*10,temp,[temp_low temp_high],'.',10);

% scale the x-axis...
%ax = axis;
%axis([87 93 ax(3) ax(4)]);

% scale the color bar...
%caxis([22.5 25]);


set(gca, 'fontsize', 12, 'ydir', 'reverse');
datetick('x', 6, 'keeplimits', 'keepticks');
hc = colorbar;
caxis([temp_low temp_high]);
set(hc, 'fontsize', 12);
ylabel('depth (m)');
xlabel('MM/DD GMT');
title('');
pos = get(get(gca, 'title'), 'position');
set(get(gca, 'title'), 'position', pos-[0 -0.5 0]);
%ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' Temp(deg C) - TBDs']);
ht = text(pos(1), pos(2)-2.35,  [' Temp(deg C) - TBDs']);
set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'temperature_vs_depth_vs_time_tbd.jpg']);
print('-djpeg90', [imgdir, trnum,'_ram_tsrho_vs_depth_vs_time_tbd.jpg']);
% END PLOT **********************************************************************


% BEGIN PLOT ********************************************************************
hf3=figure;
subplot(221)

%set(gcf, 'visible', 'off', 'renderer', 'painter');

% draw plot...scattering from puck profiles
hc = cplot(scibb, pres*10, rt);  % bb vs. depth

% scale the x-axis...
ax = axis;
axis([scibb_low scibb_high ax(3) ax(4)]);

set(gca, 'fontsize', 12, 'ydir', 'reverse');
%hc2 = colorbar;
%set(hc2, 'fontsize', 12, 'ytick', unique(rtdaily2));
%datetick(hc2, 'y', 6, 'keeplimits', 'keepticks');
ylabel('depth (m)');
xlabel('scattering (1/m)');
%title('\rho, MM/DD GMT');
pos = get(get(gca, 'title'), 'position');
ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - TBDs']);
set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'bb_vs_depth_sbd.jpg']);
% END PLOT **********************************************************************

% BEGIN PLOT ********************************************************************
hf4=figure; 
subplot(411)
%hc = cplot(rt, pres*10, scibb);  % bb vs. depth vs. time
hc = ccplot(rt,pres*10,scibb,[scibb_low scibb_high],'.',10);

set(gca, 'fontsize', 12, 'ydir', 'reverse');
datetick('x', 6, 'keeplimits', 'keepticks');
hc = colorbar;
caxis([scibb_low scibb_high]);
set(hc, 'fontsize', 12);
ylabel('depth (m)');
%xlabel('MM/DD GMT');
title('');
pos = get(get(gca, 'title'), 'position');
set(get(gca, 'title'), 'position', pos-[0 -0.5 0]);
ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - scat (1/m) TBDs']);
set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'bb_vs_depth_vs_time_sbd.jpg']);
% END PLOT **********************************************************************




% BEGIN PLOT ********************************************************************
figure(hf3); 
subplot(222)
% %set(gcf, 'visible', 'off', 'renderer', 'painter');
% 
% % draw plot...DO sat profiles
hc = cplot(scioxysat, pres*10, rt);  % DO vs. depth
% 
% % scale the x-axis...
ax = axis;
axis([scioxysat_low scioxysat_high ax(3) ax(4)]);
% 
set(gca, 'fontsize', 12, 'ydir', 'reverse');
hc2 = colorbar;
%set(hc2, 'fontsize', 12, 'ytick', unique(rtdaily2));
set(hc2, 'fontsize', 12);
% datetick(hc2, 'y', 6, 'keeplimits', 'keepticks');
%ylabel('depth (m)');
xlabel('dissolved oxygen (% saturation)');
% %title('\rho, MM/DD GMT');
% title('RAMSES')
pos = get(get(gca, 'title'), 'position');
ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - TBDs']);
set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
%timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'DO_vs_depth_sbd.jpg']);
% END PLOT **********************************************************************

% BEGIN PLOT ********************************************************************
figure(hf4);
subplot(412)
% 
% %hc = cplot(rt, pres*10, scioxy);  % DO vs. depth vs. time
hc = ccplot(rt,pres*10,scioxysat,[scioxysat_low scioxysat_high],'.',10);
% 
set(gca, 'fontsize', 12, 'ydir', 'reverse');
datetick('x', 6, 'keeplimits', 'keepticks');
hc = colorbar;
caxis([scioxysat_low scioxysat_high]);
set(hc, 'fontsize', 12);
% %ylabel('depth (m)');
% %xlabel('MM/DD GMT');
% title('');
pos = get(get(gca, 'title'), 'position');
set(get(gca, 'title'), 'position', pos-[0 -0.5 0]);
%ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - DO (%sat) TBDs']);
ht = text(pos(1), pos(2)-2.35, ['RAMSES DO (%sat) TBDs']);
set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
%timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'DO_vs_depth_vs_time_sbd.jpg']);
% END PLOT **********************************************************************




% BEGIN PLOT ********************************************************************
figure(hf3); 
subplot(223)
%set(gcf, 'visible', 'off', 'renderer', 'painter');

% draw plot...CDOM profiles
hc = cplot(scicdom, pres*10, rt);  % cdom vs. depth

% scale the x-axis...
ax = axis;
axis([scicdom_low scicdom_high ax(3) ax(4)]);

set(gca, 'fontsize', 12, 'ydir', 'reverse');
%hc2 = colorbar;
%set(hc2, 'fontsize', 12, 'ytick', unique(rtdaily2));
%datetick(hc2, 'y', 6, 'keeplimits', 'keepticks');
ylabel('depth (m)');
xlabel('cdom (ppb)');
%title('\rho, MM/DD GMT');
%pos = get(get(gca, 'title'), 'position');
%ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - TBDs']);
%set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
%timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'cdom_vs_depth_sbd.jpg']);
% END PLOT **********************************************************************

% BEGIN PLOT ********************************************************************
figure(hf4); 
subplot(413)
%hc = cplot(rt, pres*10, scicdom);  % cdom vs. depth vs. time
hc = ccplot(rt,pres*10,scicdom,[scicdom_low scicdom_high],'.',10);

set(gca, 'fontsize', 12, 'ydir', 'reverse');
datetick('x', 6, 'keeplimits', 'keepticks');
hc = colorbar;
caxis([scicdom_low scicdom_high]);
set(hc, 'fontsize', 12);
ylabel('depth (m)');
xlabel('MM/DD GMT');
title('');
pos = get(get(gca, 'title'), 'position');
set(get(gca, 'title'), 'position', pos-[0 -0.5 0]);
%ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - CDOM (ppb) TBDs']);
ht = text(pos(1), pos(2)-2.35, [' - CDOM (ppb) TBDs']);
set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'cdom_vs_depth_vs_time_sbd.jpg']);
% END PLOT **********************************************************************





% BEGIN PLOT ********************************************************************
figure(hf3); 
subplot(224)
%set(gcf, 'visible', 'off', 'renderer', 'painter');

% draw plot...Chl profiles
hc = cplot(scichlor, pres*10, rt);  % chlorophyll vs. depth

% scale the x-axis...
ax = axis;
axis([scichlor_low scichlor_high ax(3) ax(4)]);

set(gca, 'fontsize', 12, 'ydir', 'reverse');
hc2 = colorbar;
set(hc2, 'fontsize', 12);
% datetick(hc2, 'y', 6, 'keeplimits', 'keepticks');
%ylabel('depth (m)');
xlabel('chlorophyll (ug/l)');
%title('\rho, MM/DD GMT');
%pos = get(get(gca, 'title'), 'position');
%ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - TBDs']);
%set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
%timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'chlor_vs_depth_sbd.jpg']);
print('-djpeg90', [imgdir,trnum, '_ram_optDO_vs_depth_tbd.jpg']);
% END PLOT **********************************************************************

% BEGIN PLOT ********************************************************************
figure(hf4); 
subplot(414)
%hc = cplot(rt, pres*10, scichlor);  % chlor vs. depth vs. time
hc = ccplot(rt,pres*10,scichlor,[scichlor_low scichlor_high],'.',10);

set(gca, 'fontsize', 12, 'ydir', 'reverse');
datetick('x', 6, 'keeplimits', 'keepticks');
hc = colorbar;
caxis([scichlor_low scichlor_high]);
set(hc, 'fontsize', 12);
%ylabel('depth (m)');
xlabel('MM/DD GMT');
title('');
pos = get(get(gca, 'title'), 'position');
set(get(gca, 'title'), 'position', pos-[0 -0.5 0]);
%ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - Chl (ug/l) TBDs']);
ht = text(pos(1), pos(2)-2.35, [' - Chl (ug/l) TBDs']);
set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'chlor_vs_depth_vs_time_sbd.jpg']);
print('-djpeg90', [imgdir, trnum,'_ram_optDO_vs_depth_vs_time_tbd.jpg']);
% END PLOT **********************************************************************

% get position information from sbd files - already saved
sbd=load('modena_dep1_position');
[tsort,isort]=unique(sbd.rt,'last');
lotemp = sbd.glon(isort);
latemp = sbd.glat(isort);
ig=find(~isnan(lotemp));
lon=interp1(tsort(ig),lotemp(ig),rt);
lat=interp1(tsort(ig),latemp(ig),rt);

% write out working data file

save modena_allfields_dep1 rt depth temp salin rho scioxy scioxysat scibb...
    scicdom scichlor lon lat


% 3rd set of plots -

% BEGIN PLOT ********************************************************************
% hf5=figure; 
% subplot(121)
% %set(gcf, 'visible', 'off', 'renderer', 'painter');
% 
% % draw plot...DO profiles
% hc = cplot(scioxy, pres*10, rt);  % DO vs. depth
% 
% % scale the x-axis...
% ax = axis;
% axis([scioxy_low scioxy_high ax(3) ax(4)]);
% 
% set(gca, 'fontsize', 12, 'ydir', 'reverse');
% hc2 = colorbar;
% set(hc2, 'fontsize', 12);
% datetick(hc2, 'y', 6, 'keeplimits', 'keepticks');
% %ylabel('depth (m)');
% xlabel('dissolved oxygen (\mu M)');
% %title('\rho, MM/DD GMT');
% title('RAMSES')
% %pos = get(get(gca, 'title'), 'position');
% %ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - TBDs']);
% %set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
% %timestamp('GMT ', 4);
% 
% % save figure to a file...
% %print('-djpeg90', [imgdir, 'DO_vs_depth_sbd.jpg']);
% % END PLOT **********************************************************************
% 
% % BEGIN PLOT ********************************************************************
% hf6=figure;
% subplot(211)
% 
% %hc = cplot(rt, pres*10, scioxy);  % DO vs. depth vs. time
% hc = ccplot(rt,pres*10,scioxy,[scioxy_low scioxy_high],'.',10);
% 
% set(gca, 'fontsize', 12, 'ydir', 'reverse');
% datetick('x', 6, 'keeplimits', 'keepticks');
% hc = colorbar;
% set(hc, 'fontsize', 12);
% %ylabel('depth (m)');
% %xlabel('MM/DD GMT');
% title('');
% pos = get(get(gca, 'title'), 'position');
% set(get(gca, 'title'), 'position', pos-[0 -0.5 0]);
% %ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - DO (%sat) TBDs']);
% ht = text(pos(1), pos(2)-2.35, ['RAMSES DO (\mu M) TBDs']);
% set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
% %timestamp('GMT ', 4);

% save figure to a file...
%print('-djpeg90', [imgdir, 'DO_vs_depth_vs_time_sbd.jpg']);
% END PLOT **********************************************************************



