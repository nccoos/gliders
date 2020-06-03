function [flight, science, x] = gliderCTD_Generate_L1_Data(deploymentInfo, myBounds, correction_parameters,ctd_Pumped,timeBase_is_ctd_time)

%
%  gliderCTD_Generate_L1_Data.m
%
%  Purpose: Apply thermal lag correction to glider CTD salinity and density. 
%           Apply basic QC and generate Level 1 data mat files.
%
%
%  Requires:
%  correctThermalLag.m - Code from authors that implements Garau et al. 2011, Thermal
%  lag correction on Slocum CTD glider data, JAOT, 28,
%  1065-1071,doi:10.1175/JTECH-D-10-05030.1.
%  (This file is now in the glider_toolbox-master folder, two levels up.)
%
%  MATLAB folder - contains util, seawater 
%
%
%  Author:  William Stark
%           Marine Sciences Department
%           UNC-Chapel Hill
%
%  Created: 21 May 2012
%   reviewed, modified by HES December 2012, March 2013, called v1
%   June 2013, implemented some QC procedures for ramses, HES
%   20130703 - Iterate throuth gliders and deployments. - CBC
%   20130725 - Implemented some QC procedures for pelagia. - HES
%   20161011 - Made this a function, putting most (but not all) glider-specific and/or deployment-specific stuff in the caller.
%              Search on "switch strGliderName" to find glider-specific settings.
%              Also, use the new correctThermalLag function by setting newCorrectThermalLag (below). 
%              Added an option to use ctd_time as the time base (in the output file) instead of ptime_ebd. (See Notes below.) 
%              Added a struct x, to be used to help getting rid of the salinity spiking, which is an iterative process -SBL
%   20190205 - Made level1 only about thermal lag correction, get rid of
%                      correction base on flow and time base figures. -LH
%INPUTS:
%{
-deploymentInfo: struct for custom strings including the following atrributes:
                        -projectLabel
                        -strDeploymentNumber
                        -strStartDate
                        -strEndDate
                        -strGliderName
                        -ebddir
                        -dbddir
myBounds: struct for bounds per variable, including the following attributes:
                        -tempBounds
                        -salinBounds
                        -densBounds
                        -chlorBounds
-correction_parameters: struct for thermal lag correction with the following attributes 
                        a) if ctd_Pumped: 
                            -alpha
                            -tau
                        a) if ~ctd_Pumped: 
                            -alpha_offset
                            -alpha_slope
                            -tau_offset
                            -tau_slope
-ctd_Pumped: boolean indicating whether the CTD is pumped

-timeBase_is_ctd_time: Boolean indicates whether to use ctd_time or "science" time
%}

% OUTPUTS
%{
The main output is a mat file (writtent to cwd, storing CTD (and related) data for the
glider/deployment specified in deploymentInfo. It also returns the last
processed flight and science structs (which was useful for debugging at one
point). It also returns a struct x, which is useful when tweaking salinity
spiking.

%}
% NOTES
%{
% Removed chlorophyll from processing, do separately.

% Compare sci_m_present_time and sci_ctdxx_timestamp - looks like ptime_ebd-ctd_time is
% 0.6 +-0.6 second, never goes negative but can be very big positive
% number.  Appears to happen at surfacing, and that the CTD throws several
% measurements with the same time stamp, maybe a flushed buffer?  Have
% badflagged the values, identified as times when the two timestamps are very
% different.

% Resolve best determination of lat and lon - HES: looked at this some;
% lat/lon are most common measure but appear to reflect dead reckoning.
% waypoints are just that, intended targets, so chose gps in the end for
% determining position of each CTD point.  Commented out code to process
% other position measures for now.

-Currently not processing the last science file.

-Currently not using bounds--just putting in output mat file because that's
what was done in the past (for plots only).

-Should we use ctd_time or ptime_ebd as the time base? 
    In the Long Bay version of this code, 
    flight data (using ptime_dbd) was interpolated to ctd_time in prep for the despiking of salinity (i.e. applying 
    correctThermalLag.m). Then, the gps data (also from flight) is interpolated to ptime_ebd (science timestamp).
    The ptime_ebd is then stored with the output mat file, as ptime. 

    In THIS version (for SECOORA and PEACH), an option has been introduced so that we can keep
    ctd_time as the base--consistently--i.e. in all interpolations from flight and also storing it in the output
    mat file (instead of science time ptime_ebd).

-Reordering is required because the individual ebdasc, dbdasc files are not processed in the correct order.
 Perhaps a better renaming (i.e. file name convention) would eliminate the need for reordering. For now, not 
 renaming at all (for SECOORA_2016), so this preserves the order. The advantage of doing this is that you are able
 to see this issue for OTHER reason(s) e.g. resynch of clocks.
%}


%% USER INPUT
% For the purpose of testing, there is a switch to control which
% correctThermalLag to use--new vs. old. The new one supports pumped CTD
% and has a different interface. When switching, make sure to take care of
% path issues so that the correct version of correctThermalLag is used.
newCorrectThermalLag = true;


%% UNPACK
% myBounds
tempBounds = myBounds.tempBounds;
salinBounds = myBounds.salinBounds;
densBounds = myBounds.densBounds;
chlorBounds = myBounds.chlorBounds;
% deploymentInfo
projectLabel = deploymentInfo.projectLabel;
strDeploymentNumber = deploymentInfo.strDeploymentNumber;
strStartDate = deploymentInfo.strStartDate;
strEndDate = deploymentInfo.strEndDate;
strGliderName = deploymentInfo.strGliderName;
ebddir = deploymentInfo.ebddir;
dbddir = deploymentInfo.dbddir;
% correction_parameters
% correctThermalLag requires just a 4-element array
if ctd_Pumped
    thermalLagParams_Array = [correction_parameters.alpha correction_parameters.tau];
else
    thermalLagParams_Array = [correction_parameters.alpha_offset correction_parameters.alpha_slope correction_parameters.tau_offset correction_parameters.tau_slope];
end


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
altitude=[]; % added from the flight generating function
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
                altitude = [altitude; flight.data(:,strmatch('m_altitude', flight.vars, 'exact'))];
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


%% EVAL WHICH TIME BASE TO USE
% This section displays plots which can help us decide whether to use
% the science timestamp (ptime_ebd) or ctd time (ctd_time) as the time base.
% The time bases are saved to a mat file so that additional plots can be
% run without re-running the entire program.
% save('timeBases.mat','ptime_ebd','ctd_time');
% % science time or ctd time
% display_String = sprintf('%s %s %s %s\n','len(ptime_ebd)=',int2str(length(ptime_ebd)),'; len(ctd_time)=',int2str(length(ctd_time)));
% disp(display_String)
% display_String = sprintf('%s %s %s %s\n','len(~isnan(ptime_ebd))=',int2str(length(~isnan(ptime_ebd))),'; len(~isnan(ctd_time))=',int2str(length(~isnan(ctd_time))));
% disp(display_String)
% display_String = sprintf('%s %s %s %s\n','len(ptime_ebd(ptime_ebd==0))=',int2str(length(~isnan(ptime_ebd(ptime_ebd==0)))),'; len(ctd_time(ctd_time==0))=',int2str(length(ctd_time(ctd_time==0))));
% disp(display_String)
% sampleInterval_Centers = [-1 0 0.1 1 2 3 4 5 10];

%% GET STATS ON L0 DATA
%bin_Centers_temp = [10:33];
% [N1_temp,X1_temp] = hist(temp);
% %bin_Centers_cond = [10:10:150];
% [N1_cond,X1_cond] = hist(cond);


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
horizontalVelocity = horizontalVelocity(I); 
depth = depth(I);
pitch = pitch(I);
avgDepthRate = avgDepthRate(I);
angleOfAttack = angleOfAttack(I);
altitude = altitude(I);
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

% Use diff to ID spikes in temperature and conductivity and remove them.
% These values chosen from looking at ramses, may need different set for 
% pelagia
switch projectLabel
    case 'PEACH_2017' %'LongBay_2012'
        switch strGliderName
            case 'Ramses'
                ib=find(abs(diff(temp))>1.);
                ib2=find(abs(diff(cond))>0.15);
                ibb=union(ib,ib2);
                temp(ibb+1)=NaN;
                cond(ibb+1)=NaN;
                i=find(~isnan(temp));
                ptime_ebd = ptime_ebd(i);  temp = temp(i);  pres = pres(i);  cond = cond(i); 
                ctd_time = ctd_time(i);
            case 'Pelagia'
                ib=find(abs(diff(temp))>1.5);
                ib2=find(abs(diff(cond))>0.1);
                ibb=union(ib,ib2);
                temp(ibb+1)=NaN;
                cond(ibb+1)=NaN;
                i=find(~isnan(temp));
                ptime_ebd = ptime_ebd(i);  temp = temp(i);  pres = pres(i);  cond = cond(i); 
                ctd_time = ctd_time(i);
            case 'Salacia'
                ib=find(abs(diff(temp))>1.);
                ib2=find(abs(diff(cond))>0.15);
                ibb=union(ib,ib2);
                temp(ibb+1)=NaN;
                cond(ibb+1)=NaN;
                i=find(~isnan(temp));
                ptime_ebd = ptime_ebd(i);  temp = temp(i);  pres = pres(i);  cond = cond(i); 
                ctd_time = ctd_time(i);
            otherwise
                error('Unknown glider name');
        end
    case 'SECOORA_2016'
        % Do nothing for now
    otherwise
        error('Unknown project label');
end

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

i = find(~isnan(altitude));
altitude = interp1(ptime1_dbd(i), altitude(i), ctd_time);

i = find(~isnan(angleOfAttack));
angleOfAttack = interp1(ptime1_dbd(i), angleOfAttack(i), ctd_time);

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
altitude = altitude(i); angleOfAttack = angleOfAttack(i);
% scale up the pressure...
pres = pres*10;

% calculate salinity (without correction)...
salin = sw_salt(10*cond/sw_c3515, temp, pres);

% calculate density (without correction)...
dens = sw_pden(salin, temp, pres, 0);

% calculate glider velocity using horizontal velocity (m_speed) and average depth rate (m_avg_depth_rate)...
% gliderVelocity = sqrt(horizontalVelocity.^2 + avgDepthRate.^2);
gliderVelocity = sqrt(hv.^2 + avgDepthRate.^2);
%horizontalVelocity is on dbd time base, hv is on ctd time base, which is
%the one should be used here.

%% APPLY THERMAL LAG CORRECTION
% CORRECTION SCHEME:  Pass in a glider velocity vector, so that correctThermalLag() will return
% profile data that has been corrected using flow speed equal to this glider velocity.
% Correction parameters are calculated using passed-in glider velocity.
if newCorrectThermalLag
    if ctd_Pumped
        % [temp_inside, cond_outside] = correctThermalLag(timestamp, cond_inside, temp_outside, params)
        [temp_inside, cond_outside] = correctThermalLag(ctd_time,cond,temp,thermalLagParams_Array);
        tempCorrected = temp_inside;
    else
        % [temp_inside, cond_outside] = correctThermalLag(timestamp, cond_inside, temp_outside, flow_speed, params)
        [temp_inside, cond_outside] = correctThermalLag(ctd_time,cond,temp,gliderVelocity,thermalLagParams_Array);
        tempCorrected = temp_inside;
    end
else
    % pass the correction parameters into the correctThermalLags function, which
    % returns the corrected profile structure (with corrected temp and cond added)...
    %
    % profileStructure:  ptime: Present time instant at which this row was collected
    %                    depth: Depth (pressure in decibars) measured by the CTD
    %                    temp: Temperature measured by the CTD
    %                    cond: Conductivity measured by the CTD
    %                    pitch: Pitch angle of the glider (optional)
    %
    profileStructure = struct('ptime', ctd_time, 'depth', pres, 'temp', temp, 'cond', cond, 'pitch', glideAngle);
    [correctedProfileData, varargout] = correctThermalLag(profileStructure, thermalLagParams_Array, gliderVelocity);
    % get the corrected temperature...
    tempCorrected = correctedProfileData.tempInCell;
end

% calculate the corrected salinity using the corrected temperature...
salinCorrected = sw_salt(10*cond/sw_c3515, tempCorrected, pres);


%% MORE QC: CLEAN SALINITY WHEN FLOW IS BAD
% implement some clean-up here?  Will eliminate a lot of points. Issue is with salinities when glider is at
% top or bottom of profiles.  Use original velocity measure (hv) and pitch
% to identify points for exclusion
% these values set by look at ramses; may need alternate set for
% pelagia (now set based on deployment 1)

% switch projectLabel
%     case 'PEACH_2017' %'LongBay_2012'
%         switch strGliderName
%             case 'Ramses'
% %                 iv = find(hv<0.1 | hv > 0.7);
% %                 ip = find (abs(pitch) < 10.);
% %                 ib = union(iv,ip);
%                 is = find(salinCorrected < 25);%manually remove that wierd data point
% %                 ip = find (abs(pitch) < 10. & depth>=25);%for Ramses deployment2 
%                 ip = find(abs(pitch)<10. | abs(pitch)>60);
%                 iv = find(hv<0.12 | hv > 0.75);
%                 id = find(abs(avgDepthRate)<0.05&depth>20);
%                 ib = union(union(union(ip,is),iv),id);
% %                 salinCorrected(ib) = NaN;
%             case 'Pelagia'
%                 iv = find(hv<0.1);
%                 ip = find(pitch>5 & pitch < 15);
%                 ib = union(iv,ip);
%                 salinCorrected(ib) = NaN;
%             otherwise
%                 error('Unknown glider name');
%         end
%     case 'SECOORA_2016'
%         % Do nothing for now
%     otherwise
% end
% 
% % the step above likely removes many points, need to make sure that dataset
% % is consistent, so use salinity to ID valid times going forward
% i = find(~isnan(salinCorrected));
% ptime_ebd=ptime_ebd(i);  temp=temp(i);  tempCorrected=tempCorrected(i); salin=salin(i);
% salinCorrected=salinCorrected(i); pres=pres(i); dens=dens(i);
% ctd_time = ctd_time(i); hv=hv(i); pitch= pitch(i); cond=cond(i); 
% gliderVelocity = gliderVelocity(i); avgDepthRate = avgDepthRate(i);
% 
% % calculate density...should this use temp corrected?? HES - no, now have
% % best estimate of salinity to combine with originally measured temp
densCorrected = sw_pden(salinCorrected, temp, pres, 0);


%% DECIDE ON TIME BASE
% Prior to interpolating flight data (e.g. gps) to have the same time base
% as the CTD data (which is ctd_time at this point)
if timeBase_is_ctd_time
    % Define ptime to be ctd_time
    % Essentially, it is saying that ctd_time is the consistent
    % time base for this data set.
    ptime = ctd_time;
    ptime_Descrip = 'ctd time';
else
    % Define ptime to be science time i.e. consistent with approach used in
    % Long Bay.
    ptime = ptime_ebd;
    ptime_Descrip = 'science time';
end


%% SOME PLOTS
% convert ptime into datenum style...for plotting I think, commenting out
ptime_datenum = ptime/3600/24+datenum(1970, 1, 1, 0, 0, 0);
%ptime_datenum_dbd = ptime_dbd/3600/24+datenum(1970, 1, 1, 0, 0, 0);
%ptimehrly = fix(ptime_datenum*24)/24;
%ptimedaily = fix(ptime_datenum);
%ptimedaily2 = unique(ptimedaily);
%ptimedaily2 = ptimedaily2(1:2:end);

try
%     figure; plot(ptime_datenum,hv); title('hv'); datetick('x',6,'keeplimits');
%     figure; plot(ptime_datenum,pitch); title('pitch'); datetick('x',6,'keeplimits');
%     figure; plot(ptime_datenum,cond); title('cond'); datetick('x',6,'keeplimits');
%     figure; plot(ptime_datenum,temp); title('temp'); datetick('x',6,'keeplimits');
%     figure; plot(ptime_datenum,tempCorrected); title('tempCorrected'); datetick('x',6,'keeplimits');
%     figure; plot(ptime_datenum,salin); 
%     hold on;
%     plot(ptime_datenum,salinCorrected);
%     legend('salin','salinCorrected')
%     title('salinCorrected'); datetick('x',6,'keeplimits');
%     figure; plot(salin,temp,'.'); 
%     hold on;
%     plot(salinCorrected,temp,'.');
%     legend('salin','salinCorrected')
%     title('T-S'); 
catch err
    disp('Error generated trying to plot. Check x.');
end
% 2-D histogram to review the data distribution on T-S plot
% figure;
% hist3([salinCorrected,temp],'Nbins',[20,20],'CdataMode','auto')
% colormap jet;
% colorbar;
% xlabel('S');
% ylabel('T');
% title('Histogram of corrected T-S')
% figure
% hist3([salin,temp],'Nbins',[20,20],'CdataMode','auto')
% colormap jet;
% colorbar;
% xlabel('S');
% ylabel('T');
% title('Histogram of uncorrected T-S')
% Return above to help salin spiking effort
% x.ctd_time = ctd_time;
% x.hv = hv;
% x.pitch = pitch;
% x.cond = cond;
% x.temp = temp;
% x.gliderVelocity = gliderVelocity;
% x.avgDepthRate = avgDepthRate;

%% INTERPOLATE FLIGHT DATE (e.g. GPS) TO SCIENCE (OR CTD) TIME
% make copies of dbd time stamp vector for use in lat/lon interpolation...
ptime_dbd_gps = ptime_dbd;
%ptime_dbd_wpt = ptime_dbd;

% convert lats and lons to digital degrees...
gpsLat = ddmm2decdeg(gpsLat);
gpsLon = ddmm2decdeg(gpsLon);
%wptLat = ddmm2decdeg(wptLat);
%wptLon = ddmm2decdeg(wptLon);
%lat = ddmm2decdeg(lat);
%lon = ddmm2decdeg(lon);

% eliminate outliers in gpsLat, gpsLon...
i = find(abs(gpsLat) <= 90.0);
gpsLat = gpsLat(i);  gpsLon = gpsLon(i);  ptime_dbd_gps = ptime_dbd_gps(i);
i = find(abs(gpsLon) <= 180.0);
gpsLat = gpsLat(i);  gpsLon = gpsLon(i);  ptime_dbd_gps = ptime_dbd_gps(i);

% eliminate nans before interpolating...
i = find(~isnan(gpsLat));
gpsLat = gpsLat(i);  gpsLon = gpsLon(i);  ptime_dbd_gps = ptime_dbd_gps(i);
%i = find(~isnan(wptLat));
%wptLat = wptLat(i);  wptLon = wptLon(i);  ptime_dbd_wpt = ptime_dbd_wpt(i);

% interpolate DBD lat/lon data to align with EBD data...
gpsLat = interp1(ptime_dbd_gps, gpsLat, ptime);
gpsLon = interp1(ptime_dbd_gps, gpsLon, ptime);
%wptLat = interp1(ptime_dbd_wpt, wptLat, ptime);
%wptLon = interp1(ptime_dbd_wpt, wptLon, ptime);

% use sw_dpth() to calculate depth from pres...
depth = sw_dpth(pres, gpsLat);


%% OUTPUT
% create configuration struct...
units = struct('gpsLat', 'decimal degrees',...
               'gpsLon', 'decimal degrees',...
               'ptime', 'seconds since 0000-01-01T00:00',...
               'ptime_datenum', 'days since 1970-01-01T00:00',...
               'pres', 'decibars',...
               'depth', 'm',...
               'temp', 'deg C',...
               'salin', 'psu',...
               'salinCorrected', 'psu',...
               'dens', 'kg m-3',...
               'densCorrected', 'kg m-3');

variable_description = struct('gpsLat', 'position latitude measured by glider GPS',...
                              'gpsLon', 'position longitude measured by glider GPS',...
                              'ptime', ptime_Descrip,...
                              'ptime_datenum', 'ptime in datenum format',...
                              'pres', 'pressure measured by glider',...
                              'depth', 'depth calculated as function of pressure and position latitude',...
                              'temp', 'temperature measured by glider',...
                              'salin', 'salinity measured by glider',...
                              'salinCorrected', 'salinity corrected for thermal lag',...
                              'dens', 'density measured by glider',...
                              'densCorrected', 'density corrected for thermal lag');


config = struct('glider_name', strGliderName,...
                'deployment_number', strDeploymentNumber,...
                'start_date', strStartDate,...
                'end_date', strEndDate,...
                'thermal_lag_correction_parameters', correction_parameters,...
                'var_descriptions', variable_description,...
                'var_units', units);

% set Level 1 data mat file name...
% strMatFileName = strcat(strGliderName, '_Deployment', strDeploymentNumber, '_CTD_L1.mat');
strMatFileName = strcat(strGliderName,'_Deployment', strDeploymentNumber, '_CTD_L1.mat');

% save glider/deployment data to mat file...
save(strMatFileName,...
     'config',...
     'gpsLat',...
     'gpsLon',...
     'ptime',...
     'ptime_datenum',...
     'pres',...
     'depth',...
     'temp',...
     'tempBounds',...
     'salin',...
     'salinCorrected',...
     'salinBounds',...
     'dens',...
     'densCorrected',...
     'densBounds');

%  save(strMatFileName,...
%      'config',...
%      'gpsLat',...
%      'gpsLon',...
%      'ptime',...
%      'ptime_datenum',...
%      'pres',...
%      'depth',...
%      'temp',...
%      'salin',...
%      'salinCorrected',...
%      'dens',...
%      'densCorrected',...
%      'x');
%% save the flight data
% create configuration struct...
units = struct('altitude', 'm',...
               'angleOfAttack', 'decimal degrees',...
               'avgDepthRate', 'm/s',...
               'depth', 'm',...
               'horizontalVelocity', 'm/s',...
               'pitch', 'decimal degrees',...
               'ptime', 'seconds since 0000-01-01T00:00',...
               'ptime_datenum', 'days since 1970-01-01T00:00');

variable_description = struct('altitude', 'altimeter measured distance from bottom',...
                              'angleOfAttack', 'difference between pitch and glider angle',...
                              'avgDepthRate', 'average rate of change of depth, >0 is down',...
                              'depth', 'depth calculated as function of pressure and position latitude',...
                              'horizontalVelocity', 'vehicle horizontal speed through water',...
                              'pitch', 'vehicle angle of inclination, >0 is nose up',...
                              'ptime', 'time vector reported by glider',...
                              'ptime_datenum', 'Serial Date Number string');

config = struct('glider_name', strGliderName,...
                'deployment_number', strDeploymentNumber,...
                'start_date', strStartDate,...
                'end_date', strEndDate,...
                'var_descriptions', variable_description,...
                'var_units', units);

% set Level 1 data mat file name...
strMatFileName = strcat(strGliderName, '_Deployment', strDeploymentNumber, '_Flight_L1.mat');

% save flight data to mat file...
save(strMatFileName,...
     'config',...
     'altitude',...
     'angleOfAttack',...
     'avgDepthRate',...
     'depth',...
     'horizontalVelocity',...
     'pitch',...
     'ptime',...
     'ptime_datenum');

x.hv = hv;
x.pitch = pitch;
x.cond = cond;
x.temp = temp;
x.gliderVelocity = gliderVelocity;
x.avgDepthRate = avgDepthRate;
 save('ramsesD4_x.mat','x');

 %% PLOT STATS
% figure; semilogy(X1_temp,N1_temp,'ko-'); hold on;
%         semilogy(X2_temp,N2_temp,'rs--'); 
%         xlabel('temp'); ylabel('Num Occurs'); 
%         legend('L0','L0+Bounds');
% figure; semilogy(X1_cond,N1_cond,'ko-'); hold on;
%         semilogy(X2_cond,N2_cond,'rs--'); 
%         xlabel('cond'); ylabel('Num Occurs');
%         legend('L0','L0+Bounds');
