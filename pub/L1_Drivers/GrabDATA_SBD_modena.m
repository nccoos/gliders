%/////////////////////////////////////////////////////////////////////////////////////
%  William Stark
%  Graduate Research Assistant
%  Department of Marine Sciences
%  University of North Carolina - Chapel Hill
%  Chapel Hill NC
%
%  Filename:    GrabDATA_SBD.m
%
%  Description: Reads in data from glider flight persistor ascii files (sbd's) and 
%               uses it to generate matlab files for further processing.
%
%  Created:     18 Dec 2011
%  modified:    27 Jan 2012 - HES - for new config as part of Long Bay
%               project
%               5 Oct 2018 - HES - revising to read Modena files
%/////////////////////////////////////////////////////////////////////////////////////

% trnum='tr15';
% DATA FILES DIRECTORY PATH ===================================
%sbddir='/afs/isis/depts/marine/workspace/hseim/credward/glider/viz/asc/';
%datadir = '/Users/haloboy/Documents/MASC/SEIM_LAB/GLIDERS/GLIDER_DATA_FILES/SBD/';
datadir = ['/Users/heseim/Documents/2018/peach/gliders/modena/sbdasc/'];

% IMAGE FILES DIRECTORY PATH ===================================
%imgdir='/afs/isis/depts/marine/workspace/hseim/credward/glider/viz/images/';
%imgdir='/afs/isis/home/c/r/credward/public_html/ramses/';
%imgdir = '/Users/haloboy/Documents/MASC/SEIM_LAB/GLIDERS/GLIDER_DATA_IMAGES/from_SBD/';
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

% try to load all *.sbdasc files at once...
[files, Dstruct] = wilddir(datadir, '.sbdasc');
nfile = size(files, 1);


% declare variables for storing data...

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
pitch=[];
roll=[];


%*** READ IN TEST DATA ***************************************************
for i=1:nfile
%for i=nfile-9:nfile
%for i=nlast:nfile

  % protect against empty sbd file
  if(Dstruct(i).bytes>0)
    data = read_gliderasc([datadir,files(i,:)]);
  end

                  
  
  % protect against files with incomplete header
  if(isempty(strmatch('m_present_time',data.vars)))
      data.vars = {'m_present_time',
                    'm_present_secs_into_mission',
                    'm_water_vx',
                    'm_water_vy',                  
                    'm_lat',
                    'm_lon',
                    'm_pitch',
                    'm_roll',
                    'c_wpt_lat',
                    'c_wpt_lon',
                    'm_depth',
                    'm_gps_lat',
                    'm_gps_lon'};                    
  end
  
  % populate local variables with data...
  if(~isempty(data.data))
      % purge data of bad values...
      %test = data.data(:,2:14);
      %test(test>69696969) = nan;
      %data.data(:,2:14) = test;

      % assign values...

      mt = [mt;data.data(:,strmatch('m_present_secs_into_mission',data.vars))]; % elapsed mission time
      rt = [rt;data.data(:,strmatch('m_present_time',data.vars))];              % present time
      mlon = [mlon;ddmm2decdeg(data.data(:,strmatch('m_lon',data.vars)))];      % longitude
      mlat = [mlat;ddmm2decdeg(data.data(:,strmatch('m_lat',data.vars)))];      % latitude
      glon = [glon;ddmm2decdeg(data.data(:,strmatch('m_gps_lon',data.vars)))];  % gps longitude
      glat = [glat;ddmm2decdeg(data.data(:,strmatch('m_gps_lat',data.vars)))];  % gps latitude
      wlon = [wlon;ddmm2decdeg(data.data(:,strmatch('c_wpt_lon',data.vars)))];  % waypoint lon
      wlat = [wlat;ddmm2decdeg(data.data(:,strmatch('c_wpt_lat',data.vars)))];  % waypoint lat
      vx = [vx;data.data(:,strmatch('m_water_vx',data.vars))];                  % water velocity (x-directed)
      vy = [vy;data.data(:,strmatch('m_water_vy',data.vars))];                  % water velocity (y-directed)
      z = [z;data.data(:,strmatch('m_depth',data.vars))];                       % depth
%       pitch = [pitch;data.data(:,strmatch('m_pitch',data.vars))];                       % pitch
%       roll = [roll;data.data(:,strmatch('m_roll',data.vars))];                       % roll
  end
end
nlast=i;
%********************************************************************

% convert rt into datenum style...
rt = rt/3600/24+datenum(1970, 1, 1, 0, 0, 0);
rthrly = fix(rt*24)/24;
rtdaily = fix(rt);
rtdaily2 = unique(rtdaily);
rtdaily2 = rtdaily2(1:2:end);

ind = wlon==0 & wlat==0; 
wlon(ind) = nan;
wlat(ind) = nan;

% zap gps fixes that are crazy
ind = glon > 1e5;
glon(ind) = nan;
glat(ind) = nan;

% don't believe vx and vy == 0
ind = vx==0 & vy==0;
vx(ind) = nan;
vy(ind) = nan;

% estimate vertical velocity
dzdt = diff(z(~isnan(z)))./diff(rt(~isnan(z)));
zw=z(~isnan(z));
tw=rt(~isnan(z));
zw=zw(1:end-1);
tw=tw(1:end-1);
% get in m/s units
dzdt = dzdt/86400;


% find upper and lower limits for each variable...


% BEGIN PLOT ********************************************************************
figure; 
%set(gcf, 'visible', 'off', 'renderer', 'painter');

% draw plot...
% subplot(311)
% plot(rt, pitch*180/pi,'.');  % pitch
% %set(gca, 'fontsize', 12, 'xtick', unique(rtdaily2));
% set(gca, 'fontsize', 12);
% datetick('x', 6, 'keeplimits', 'keepticks');
% title('');
% pos = get(get(gca, 'title'), 'position');
% ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), 'Ramses - SBDs']);
% set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
% subplot(312)
% plot(rt, roll*180/pi,'.'); % roll
% set(gca, 'fontsize', 12);
% datetick('x', 6, 'keeplimits', 'keepticks');
subplot(313)
hc = ccplot(tw,zw,dzdt,[-0.3 0.3],'.',10); % dive/climb rate
set(gca, 'fontsize', 12, 'ydir', 'reverse');
datetick('x', 6, 'keeplimits', 'keepticks');
hc = colorbar;
caxis([-0.3 0.3]);
set(hc, 'fontsize', 12);
ylabel('depth (m)');
xlabel('MM/DD GMT');

timestamp('GMT ', 4);

% save figure to a file...
print('-djpeg90', [imgdir,'_mod_prw_sbd.jpg']);
% END PLOT **********************************************************************

% BEGIN PLOT ********************************************************************
% first get valid estimates, their times and locations
ig = find(~isnan(vx));
tg = rt(ig);
vxx = vx(ig);
vyy = vy(ig);
glo = glon(ig);
gla = glat(ig);

% next sort time in case files jumbled
[tsort,ior] = sort(tg);
% figure; 
% hc = cplot(vxx(ior), vyy(ior), tsort);  % bb vs. depth vs. time

% hc2 = colorbar;
% set(hc2, 'fontsize', 12);
% datetick(hc2, 'y', 6, 'keeplimits', 'keepticks');
% ylabel('vy (m/s)');
% xlabel('vx (m/s)');
% title([datestr(min(rt)), ' - ', datestr(max(rt)), ' Ramses vels - SBDs']);
%pos = get(get(gca, 'title'), 'position');
%set(get(gca, 'title'), 'position', pos-[0 -0.5 0]);
%ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), 'Ramses vels - SBDs']);
%set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
% timestamp('GMT ', 4);

% save figure to a file...
% print('-djpeg90', [imgdir, '_mod_vels_sbd.jpg']);
% END PLOT **********************************************************************




% BEGIN PLOT ********************************************************************
figure; 
%set(gcf, 'visible', 'off', 'renderer', 'painter');

% draw plot...
hc = cplot(glo(ior), gla(ior), tsort);  % measured lat and lon
hc2 = colorbar;
set(hc2, 'fontsize', 12, 'ytick', unique(rtdaily2));
% datetick(hc2, 'y', 6, 'keeplimits', 'keepticks');
hold on
quiver(glo(ior),gla(ior),vxx(ior),vyy(ior))
axis equal

% scale the x-axis..

ylabel('Latitude');
xlabel('Longitude');
title([datestr(min(rt)), ' - ', datestr(max(rt)), ' - Positions - Ramses SBDs']);
%pos = get(get(gca, 'title'), 'position');
%ht = text(pos(1), pos(2)-2.35, [datestr(min(rt)), ' - ', datestr(max(rt)), ' - Positions - Ramses SBDs']);
%set(ht, 'horizontalalignment', 'center', 'fontsize', 11);
timestamp('GMT ', 4);

% save figure to a file...
print('-djpeg90', [imgdir, '_mod_positions_sbd.jpg']);
% END PLOT **********************************************************************


delt=tsort(end)-tsort(1);
ii=1;
vxavg=[];
vyavg=[];
tavg=[];
for i = 0:0.25:delt-1
    iv=find(tsort>=(tsort(1)+i) & tsort < (tsort(1)+1+i));
    vxavg(ii)=nanmean(vxx(ior(iv)));
    vyavg(ii)=nanmean(vyy(ior(iv)));
    tavg(ii)=tsort(1)+i+0.5;
    ii = ii + 1;
end

figure;
subplot(211)
plot(tsort,vxx(ior),'.')
hold on
plot(tsort,vxx(ior))
plot(tavg,vxavg,'r')
datetick
ylabel('vx')
title('ramses')
subplot(212)
plot(tsort,vyy(ior),'.')
hold on
plot(tsort,vyy(ior))
plot(tavg,vyavg,'r')
datetick
ylabel('vy')
% save figure to a file...
print('-djpeg90', [imgdir,'_mod_velts_sbd.jpg']);


