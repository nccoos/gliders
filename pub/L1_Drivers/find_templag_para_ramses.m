% For flight and CTD data, this program converts L0 data to L1 data for the specified
% glider(s) by calling gliderCTD_Generate_L1_Data. The new L1 mat file is
% stored in the pwd.
% Update for peach 2017 glider ramses
% by Lu Han, 08/2017

clear all;
close all;
%%
% add paths for required files...
addpath('../gliderproc');
addpath('../gliderproc/MATLAB/util');
addpath('../gliderproc/MATLAB/plots');
%addpath('MATLAB/matutil/');
addpath('../gliderproc/MATLAB/seawater');
addpath('../gliderproc/MATLAB/strfun');
%addpath('MATLAB/opnml/');
%addpath('MATLAB/opnml/FEM/');
% Add this in only if you want to use the NEW correctThermalLag (and make
% sure the old one does not get on the path first e.g. rename it).
addpath('../../glider_toolbox-master/m/processing_tools');
addpath('../../glider_toolbox-master/m/mex_tools');
%%
% Set project label
projectLabel = 'PEACH_2017';

% Use sensor timestamp or science timestamp
timeBase_is_sensor_time = false;

% SET THE GLIDER INDEX (Pelagia = 1, Ramses = 2) ...% Salacia =3 use the
% same parameter as Ramses for now
for gliderIndex=3:3 

    % SET THE DEPLOYMENT NUMBER (1, 2 or 3) ...
    for deploymentNumber=1:1
      
         ebddir = strcat('/Users/luhan/Documents/UNC2017/Data/test/');
         dbddir = strcat('/Users/luhan/Documents/UNC2017/Data/test/');
        
        %% READ IN EBD DATA 
% declare variables for storing data...
x = struct;
temp=[];
cond=[];
pres=[];
ctd_time=[];
%chlor=[];
ptime_ebd=[];
% mtime=[]; scioxy=[]; scibb=[]; scicdom=[]; scichlor=[]; scibbam=[];

% try to load all *.ebdasc files at once...
[files, Dstruct] = wilddir(ebddir, '.ebdasc');
nfile = size(files, 1);

% Loop on science files
display_String = sprintf('%s %s %s %s %s\n','Processing', int2str(nfile-1),'of the',int2str(nfile),'ebdasc files');
disp(display_String);
for i=1:nfile-1
    filename = strcat(ebddir, files(i,:))
    % protect against empty ebd file
    if(Dstruct(i).bytes>0)
        try
            science = read_gliderasc2(filename);

            % if the number of values (in science.data) is less than the number of 
            % vars (in science.vars), this means that the data were not completely read
            % in.  To correct this, pad science.data with NaNs until its length
            % equals that of science.vars...
            if (length(science.data) < length(science.vars))
                science.data = padarray(science.data, [0 length(science.vars)-length(science.data)], NaN, 'post');
            end

            % populate variables with data...
            if(~isempty(science.data))
                 temp = [temp;science.data(:,strmatch('sci_water_temp', science.vars, 'exact'))];             % temperature
                 cond = [cond;science.data(:,strmatch('sci_water_cond', science.vars, 'exact'))];             % conductivity
                 pres = [pres;science.data(:,strmatch('sci_water_pressure', science.vars, 'exact'))];         % pressure (measure of depth) science bay
                 ctd_time = [ctd_time;science.data(:,strmatch('sci_ctd41cp_timestamp', science.vars, 'exact'))];         % ctd timestamp
            %    switch gliderIndex
             %       case 1  % this is Pelagia...
             %           chlor = [chlor;science.data(:,strmatch('sci_bbfl2s_chlor_scaled', science.vars, 'exact'))];  % chlorophyll
             %       case 2  % this is Ramses...
             %           chlor = [chlor;science.data(:,strmatch('sci_flbbcd_chlor_units', science.vars, 'exact'))];  % chlorophyll
             %   end
                ptime_ebd = [ptime_ebd;science.data(:,strmatch('sci_m_present_time', science.vars, 'exact'))];       % present time
            end
        catch err
            science = struct;
            flight = struct;
            error('ERROR reading ',filename);
            return
        end
    else
        science = struct;
    end  
end


%% READ IN DBD DATA
% declare variables for storing data...
ptime_dbd=[];
horizontalVelocity=[];
depth = [];
pitch=[];
avgDepthRate = [];
angleOfAttack = [];
%lat = [];
%lon = [];
gpsLat = [];
gpsLon = [];
%wptLat = [];
%wptLon = [];
m_tot_num_inflections = [];

% try to load all *.dbdasc files at once...
[files, Dstruct] = wilddir(dbddir, '.dbdasc');
nfile = size(files, 1);

% Loop on flight files
display_String = sprintf('%s %s %s %s %s\n','Processing', int2str(nfile),'of the',int2str(nfile),'dbdasc files');
disp(display_String);
for i=1:nfile
    filename = strcat(dbddir, files(i,:))
    % protect against empty dbd file
    if(Dstruct(i).bytes>0)
        try
            flight = read_gliderasc2(filename);

            % if the number of values (in flight.data) is less than the number of 
            % vars (in flight.vars), this means that the data were not completely read
            % in.  To correct this, pad flight.data with NaNs until its length
            % equals that of flight.vars...
            if (length(flight.data) < length(flight.vars))
                flight.data = padarray(flight.data, [0 length(flight.vars)-length(flight.data)], NaN, 'post');
            end

            % populate variables with data...
            if(~isempty(flight.data))
                ptime_dbd = [ptime_dbd; flight.data(:,strmatch('m_present_time', flight.vars, 'exact'))];               % present time
                horizontalVelocity = [horizontalVelocity; flight.data(:,strmatch('m_speed', flight.vars, 'exact'))];    % horizontal glider velocity      
                depth = [depth; flight.data(:,strmatch('m_depth', flight.vars, 'exact'))];                              % depth      
                pitch = [pitch; flight.data(:,strmatch('m_pitch', flight.vars, 'exact'))];                              % pitch (radians)
                avgDepthRate = [avgDepthRate; flight.data(:,strmatch('m_avg_depth_rate', flight.vars, 'exact'))];       % avg depth rate
                angleOfAttack = [angleOfAttack; flight.data(:,strmatch('u_angle_of_attack', flight.vars, 'exact'))];    % angle of attack (radians)
              %  wptLat = [wptLat; flight.data(:,strmatch('c_wpt_lat', flight.vars, 'exact'))];                          % Waypoint latitude
              %  wptLon = [wptLon; flight.data(:,strmatch('c_wpt_lon', flight.vars, 'exact'))];                          % Waypoint longitude
                gpsLat = [gpsLat; flight.data(:,strmatch('m_gps_lat', flight.vars, 'exact'))];                          % GPS latitude
                gpsLon = [gpsLon; flight.data(:,strmatch('m_gps_lon', flight.vars, 'exact'))];                          % GPS longitude
              %  lat = [lat; flight.data(:,strmatch('m_lat', flight.vars, 'exact'))];                                    % latitude
              %  lon = [lon; flight.data(:,strmatch('m_lon', flight.vars, 'exact'))];                                    % longitude
                m_tot_num_inflections = [m_tot_num_inflections; flight.data(:,strmatch('m_tot_num_inflections', flight.vars, 'exact'))];
            end
        catch err
            flight = struct;
            error('ERROR reading ',filename);
            return
        end
    else
        flight = struct;
    end
end
%% SOME QC
% First, apply the sort() function to make sure that values in the time vectors
% (ptime_ebd and ptime_dbd) increase monotonically...
% Do this for science
[Y,I] = sort(ptime_ebd);
ptime_ebd = Y;
temp = temp(I);
cond = cond(I);
pres = pres(I);
ctd_time=ctd_time(I);


% Do same for flight
[Y,I] = sort(ptime_dbd);
ptime_dbd = Y;
horizontalVelocity = horizontalVelocity(I); length(horizontalVelocity)
depth = depth(I);
pitch = pitch(I);
avgDepthRate = avgDepthRate(I);
angleOfAttack = angleOfAttack(I);
%wptLat = wptLat(I);
%wptLon = wptLon(I);
gpsLat = gpsLat(I);
gpsLon = gpsLon(I);
%lat = lat(I);
%lon = lon(I);

% Remove ctd measurements when ptime_ebd and ctd_time are a lot different
iweird=find(ptime_ebd-ctd_time > 10);
ptime_ebd(iweird)=NaN; temp(iweird)=NaN; pres(iweird)=NaN; cond(iweird)=NaN;
ctd_time(iweird)=NaN;

% Remove nans from EBD data...
% HES - need full triplet from CTD
i = find(~isnan(temp) & ~isnan(pres) & ~isnan(cond));
ptime_ebd = ptime_ebd(i); temp = temp(i); cond = cond(i); pres = pres(i); 
ctd_time = ctd_time(i);

% Remove conductivity values less than 1, must be at surface or bad
i = find(cond>=1);
ptime_ebd = ptime_ebd(i);  temp = temp(i);  pres = pres(i);  cond = cond(i); 
ctd_time = ctd_time(i);

% Remove pressure values less than 0
i = find(pres>=0);
ptime_ebd = ptime_ebd(i);  temp = temp(i);  pres = pres(i);  cond = cond(i); 
ctd_time = ctd_time(i);

%% MORE QC: PREP FOR THERMAL LAG CORRECTION
% convert pitch and angle of attack from radians to degrees...
pitch = pitch*180/pi;
angleOfAttack = angleOfAttack*180/pi;

% compute actual glide angle = pitch + angle of attack...
glideAngle = pitch + angleOfAttack;

% make copy of dbd time stamp vector for use in salinity/density correction...
ptime1_dbd = ptime_dbd;

% remove nans from DBD data...HES - re-wrote this to interpolate each
% variable to ebd timebase using all existing values.  Includes threshold
% on horizontal velocity of greater than zero (really important, fair number
% of values <0, not sure where these happen but think at surface) and >0.6
% m/s (less certain of this, could be looked at further)
i = find(~isnan(horizontalVelocity)); 
length(i)
% use hv, interpolated horizontal speed BEFORE thresholding,
% for removing poor salinity after processing - still includes
% crazy speeds
hv = interp1(ptime1_dbd(i), horizontalVelocity(i), ctd_time); 

i = find(~isnan(horizontalVelocity)&(horizontalVelocity>0.1 & horizontalVelocity<0.6));
horizontalVelocity = interp1(ptime1_dbd(i), horizontalVelocity(i), ctd_time);

i = find(~isnan(depth));
depth = interp1(ptime1_dbd(i), depth(i), ctd_time);

i = find(~isnan(pitch));
pitch = interp1(ptime1_dbd(i), pitch(i), ctd_time);

i = find(~isnan(avgDepthRate));
avgDepthRate = interp1(ptime1_dbd(i), avgDepthRate(i), ctd_time);

i = find(~isnan(glideAngle));
glideAngle = interp1(ptime1_dbd(i), glideAngle(i), ctd_time);

% make sure there are no NaNs in the final set of data...HES: important for
% horizontalVelocity - a start-up problem - just zaps opening points??
i = find(~isnan(horizontalVelocity));
horizontalVelocity = horizontalVelocity(i); depth = depth(i); pitch = pitch(i);
avgDepthRate = avgDepthRate(i); glideAngle = glideAngle(i); 
ptime_ebd = ptime_ebd(i); temp = temp(i); cond = cond(i); pres = pres(i); 
ctd_time = ctd_time(i); hv = hv(i);

% scale up the pressure...
pres = pres*10;

% calculate salinity (without correction)...
salin = sw_salt(10*cond/sw_c3515, temp, pres);

% calculate density (without correction)...
dens = sw_pden(salin, temp, pres, 0);

% calculate glider velocity using horizontal velocity (m_speed) and average depth rate (m_avg_depth_rate)...
gliderVelocity = sqrt(hv.^2 + avgDepthRate.^2);
%%
save ('find_params_ramses0917.mat', 'ctd_time','cond','temp','pres','gliderVelocity','pitch','glideAngle');
%%
ptime_datenum = ctd_time/3600/24+datenum(1970, 1, 1, 0, 0, 0);
% t0 = '14-Sep-2017 01::53:00';
% t1 = '14-Sep-2017 01::56:15';
% t2 = '14-Sep-2017 02::00:00';
% t0 = datenum(t0);
% t1 = datenum(t1);
% t2 = datenum(t2);
% subset1=find(  (ptime_datenum >= t0) & (ptime_datenum < t1));
% subset2=find(  (ptime_datenum >= t1) & (ptime_datenum < t2));
subset1=[437:524];
subset2=[525:620];
time1 = ctd_time(subset1);
time2 = ctd_time(subset2);
t1 = ptime_datenum(subset1);
t2 = ptime_datenum(subset2);
cond1 = cond(subset1);
cond2 = cond(subset2);
temp1 = temp(subset1);
temp2 = temp(subset2);
pres1 = pres(subset1);
pres2 = pres(subset2);
flow1 = gliderVelocity(subset1);
flow2 = gliderVelocity(subset2); 
figure;
t1 = ptime_datenum(subset1);
t2 = ptime_datenum(subset2);
subplot(4,1,1);
plot(t1,flow1,t2,flow2)
datetick
subplot(4,1,2);
plot(t1,pitch(subset1),t2,pitch(subset2))
datetick
subplot(4,1,3);
plot(t1,cond1,t2,cond2)
datetick
subplot(4,1,4);
plot(t1,temp1,t2,temp2)
datetick
[params, exitflag, residual] = findThermalLagParams(time1,cond1,temp1,pres1,flow1,time2,cond2,temp2,pres2,flow2,'graphics', 'true');

% c = [0.0135 0.0264 7.1499 2.7858];
% [params, exitflag, residual] = findThermalLagParams(time1,cond1,temp1,pres1,flow1,time2,cond2,temp2,pres2,flow2,'graphics', 'true','lower',0.5*c,'upper',1.5*c);
   end
end
