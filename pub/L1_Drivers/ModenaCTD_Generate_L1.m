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
%               9 Mar 2019 - LH - reformat data output as the other deployments 
clear all
close all
addpath('../gliderproc');
addpath('../gliderproc/MATLAB/util');
addpath('../gliderproc/MATLAB/plots');
addpath('../gliderproc/MATLAB/seawater');
addpath('../gliderproc/MATLAB/strfun');
addpath('../../glider_toolbox-master/m/processing_tools');
trnum='tr15';
for gliderIndex=2:2

    % SET THE DEPLOYMENT NUMBER (1, 2 or 3) ...
    for deploymentNumber=7:7
         if (gliderIndex==1)
            strGliderName = 'Modena';
            ctd_Pumped = true;
         else 
            strGliderName = 'Ramses';
            ctd_Pumped = false;
         end

        disp(['Generating Level 1 CTD data for ', strGliderName, ' Deployment ', num2str(deploymentNumber)]);
        % deployment number string...
        strDeploymentNumber = num2str(deploymentNumber);

        % deployment start date string...
        strStartDate = 'Nov-19-2018';

        % deployment end date string...
        strEndDate = 'Dec-11-2018';
%         tbddir = '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/modena/2018_03/tbdasc/';
%         sbddir = '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/modena/2018_03/sbdasc/';
        tbddir = '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_11/comm/tbdasc/';
        sbddir = '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_11/comm/sbdasc/';
        
        switch gliderIndex
            case 1  % Modena
                switch deploymentNumber
                    case 1  % Deployment 1
                        tempBounds =  [6 22.0];
                        salinBounds = [27 36.6];
                        densBounds =  [1020.0 1028];
                        chlorBounds = [0.0 4.0];
                end

            case 2  % Ramses
                switch deploymentNumber
                    case 7  % Deployment 1 (Only one deployment, using this for now)
                        tempBounds =  [9.0, 26];
                        salinBounds = [29.5, 36.7];
                        densBounds =  [1021, 1026.6];
                        chlorBounds = [0.0 4.0];
                end
        end
           
     
        %% READ IN TBD DATA 
        % declare variables for storing data...

        x = struct;
        temp=[];
        cond=[];
        pres=[];
        ctd_time=[];

        ptime_ebd=[];
        scioxysat=[];
        scioxy=[]; 
        scatter=[]; 
        cdom=[]; 
        chlor=[]; 
        scibbam=[];

        % try to load all *.ebdasc files at once...
        [files, Dstruct] = wilddir(tbddir, '.tbdasc');
        nfile = size(files, 1);

        for i=1:nfile-1
            filename = strcat(tbddir, files(i,:));
            % protect against empty ebd file
            if(Dstruct(i).bytes>0)
                    science = read_gliderasc2(filename);

                    % if the number of values (in science.data) is less than the number of 
                    % vars (in science.vars), this means that the data were not completely read
                    % in.  To correct this, pad science.data with NaNs until its length
                    % equals that of science.vars...
                    if (length(science.data) < length(science.vars))
                        science.data = padarray(science.data, [0 length(science.vars)-length(science.data)], NaN, 'post');
                    end
                    if(isempty(strmatch('sci_m_present_time',science.vars)))
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
                    % populate variables with data...
                    if(~isempty(science.data))
                         temp = [temp;science.data(:,strmatch('sci_water_temp', science.vars, 'exact'))];             % temperature
                         cond = [cond;science.data(:,strmatch('sci_water_cond', science.vars, 'exact'))];             % conductivity
                         pres = [pres;science.data(:,strmatch('sci_water_pressure', science.vars, 'exact'))];         % pressure (measure of depth) science bay
%                          ctd_time = [ctd_time;science.data(:,strmatch('sci_ctd41cp_timestamp', science.vars, 'exact'))];         % ctd timestamp
                         scioxysat = [scioxysat;science.data(:,strmatch('sci_oxy4_saturation',science.vars, 'exact'))];     % dissolved oxygen
                         scioxy = [scioxy;science.data(:,strmatch('sci_oxy4_oxygen',science.vars, 'exact'))];     % dissolved oxygen
                  
                         chlor =   [chlor;science.data(:,strmatch('sci_flbbcd_chlor_units', science.vars, 'exact'))];  % chlorophyll
                         cdom =    [cdom;science.data(:,strmatch('sci_flbbcd_cdom_units', science.vars, 'exact'))];  % cdom
                         scatter = [scatter;science.data(:,strmatch('sci_flbbcd_bb_units', science.vars, 'exact'))];  % scatter                       
                         ptime_ebd = [ptime_ebd;science.data(:,strmatch('sci_m_present_time', science.vars, 'exact'))];       % present time
                    end
                
            else
                science = struct;
            end  
        end

        nlast=i;
        %********************************************************************

        % HES - get time monotonic and sort appropriately
%%
        [ts,isort] = sort(ptime_ebd);
        ptime_ebd = ts;
%         ctd_time = ctd_time(isort);
        temp = temp(isort);
        cond = cond(isort);
        pres = pres(isort);
        scioxysat = scioxysat(isort);
        scioxy = scioxy(isort);
        scatter = scatter(isort);
        cdom = cdom(isort);
        chlor = chlor(isort);

        % clip out zeros
        temp(temp<1) = nan;
        cond(cond<1) = nan;


%         iweird=find(ptime_ebd-ctd_time > 10);
%         ptime_ebd(iweird)=NaN; temp(iweird)=NaN; pres(iweird)=NaN; cond(iweird)=NaN;
%         ctd_time(iweird)=NaN;

        % calculate salinity...
        salin = sw_salt(10*cond/sw_c3515, temp, 10*pres);


        % eliminate salinity outliers by setting them to NaN...
        salin(salin>38) = nan;

        % calculate density...
        dens = sw_dens(salin, temp, 10*pres);    % in situ density
        %rho = sw_dens0(salin,temp);            % potential density

        % convert rt into datenum style...
        ptime_datenum = ptime_ebd/3600/24+datenum(1970, 1, 1, 0, 0, 0);
        rthrly = fix(ptime_ebd*24)/24;
        rtdaily = fix(ptime_ebd);
        rtdaily2 = unique(rtdaily);
        rtdaily2 = rtdaily2(1:2:end);

        % some QC

        ib = find(scioxysat < 70);
        scioxysat(ib) = nan;
        scioxy(ib) = nan;



        %% READ IN DBD DATA
        % declare variables for storing data...

        ptime_dbd=[];
        depth = [];
        gpsLat = [];
        gpsLon = [];
        altitude = [];
        % try to load all *.dbdasc files at once...
        [files, Dstruct] = wilddir(sbddir, '.sbdasc');
        nfile = size(files, 1);
        for i=1:nfile
            filename = strcat(sbddir, files(i,:))
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
                        depth = [depth; flight.data(:,strmatch('m_depth', flight.vars, 'exact'))];                              % depth      
                        gpsLat = [gpsLat; flight.data(:,strmatch('m_gps_lat', flight.vars, 'exact'))];                          % GPS latitude
                        gpsLon = [gpsLon; flight.data(:,strmatch('m_gps_lon', flight.vars, 'exact'))];                          % GPS longitude
                        altitude = [altitude; flight.data(:,strmatch('m_altitude', flight.vars, 'exact'))];
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

        [ts,isort] = sort(ptime_dbd);
        ptime_dbd = ts;
        depth = depth(isort);
        gpsLat = gpsLat(isort);
        gpsLon = gpsLon(isort);
        ptime = ptime_ebd;
        ptime_datenum = ptime/3600/24+datenum(1970, 1, 1, 0, 0, 0);
        gpsLat = ddmm2decdeg(gpsLat);
        gpsLon = ddmm2decdeg(gpsLon);
        altitude = altitude(isort);
%% 
        i = find(abs(gpsLat) <= 90.0);
        gpsLat = gpsLat(i);  gpsLon = gpsLon(i);  ptime_dbd = ptime_dbd(i); altitude = altitude(i);
        i = find(abs(gpsLon) <= 180.0);
        gpsLat = gpsLat(i);  gpsLon = gpsLon(i);  ptime_dbd = ptime_dbd(i); altitude = altitude(i);
        i = find(~isnan(altitude));
        gpsLat = gpsLat(i);  gpsLon = gpsLon(i);  ptime_dbd = ptime_dbd(i);
        altitude = altitude(i);
        al = nan(size(ptime));
        al(~isnan(ptime)) = interp1(ptime_dbd, altitude, ptime(~isnan(ptime)));
        altitude = al;
        % eliminate nans before interpolating...
        i = find(~isnan(gpsLat));
        gpsLat = gpsLat(i);  gpsLon = gpsLon(i);  ptime_dbd = ptime_dbd(i);
        lat = nan(size(ptime));
        lon = nan(size(ptime));
        
        % interpolate DBD lat/lon data to align with EBD data...
        lat(~isnan(ptime)) = interp1(ptime_dbd, gpsLat, ptime(~isnan(ptime)));
        lon(~isnan(ptime)) = interp1(ptime_dbd, gpsLon, ptime(~isnan(ptime)));
        gpsLat = lat;
        gpsLon = lon;
        depth = sw_dpth(pres*10, gpsLat);
        salinCorrected = salin;
        densCorrected = dens;
        chlor_Clean = chlor;
%%
        units = struct('gpsLat', 'decimal degrees',...
               'gpsLon', 'decimal degrees',...
               'ptime', 'seconds since 0000-01-01T00:00',...
               'ptime_datenum', 'days since 1970-01-01T00:00',...
               'pres', 'decibars',...
               'depth', 'm',...
               'temp', 'deg C',...
               'salin', 'psu',...
               'dens', 'kg m-3');

        variable_description = struct('gpsLat', 'position latitude measured by glider GPS',...
                                      'gpsLon', 'position longitude measured by glider GPS',...
                                      'ptime', 'ptime_Descrip',...
                                      'ptime_datenum', 'ptime in datenum format',...
                                      'pres', 'pressure measured by glider',...
                                      'depth', 'depth calculated as function of pressure and position latitude',...
                                      'temp', 'temperature measured by glider',...
                                      'salinCorrected', 'salinity corrected for thermal lag',...
                                      'dens', 'density measured by glider',...
                                      'densCorrected', 'density corrected for thermal lag');


        config = struct('glider_name', strGliderName,...
                        'deployment_number', strDeploymentNumber,...
                        'start_date', strStartDate,...
                        'end_date', strEndDate,...
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
        
         units = struct('gpsLat', 'decimal degrees',...
               'gpsLon', 'decimal degrees',...
               'ptime_ebd', 'seconds since 0000-01-01T00:00',...
               'ptime_ebd_datenum', 'days since 1970-01-01T00:00',...
               'depth', 'm',...
               'chlor', '10e-6 g/l',...
               'chlor_Clean', '10e-6 g/l',...
               'cdom', 'ppb',...
               'scatter', '1/mm',...
               'chlor_sig', 'count',...
               'cdom_sig', 'count',...
               'scatter_sig', 'count',...
               'chlor_ref', 'count',...
               'cdom_ref', 'count',...
               'scatter_ref', 'count');

            variable_description = struct('gpsLat', 'position latitude measured by glider GPS',...
                                          'gpsLon', 'position longitude measured by glider GPS',... 
                                          'ptime', 'ptime_Descrip',...
                                          'ptime_datenum', 'ptime in datenum format',...
                                          'depth', 'depth calculated as function of pressure and position latitude', ...
                                          'chlor', 'chlorophyll',...
                                          'cdom', 'chromophoric dissolved organic matter',...
                                          'scatter', 'backscatter');

            config = struct('glider_name', strGliderName,...
                            'deployment_number', strDeploymentNumber,...
                            'start_date', strStartDate,...
                            'end_date', strEndDate,...
                            'var_descriptions', variable_description,...
                            'var_units', units);

            % set Level 1 data mat file name...
            strMatFileName = strcat(strGliderName, '_Deployment', strDeploymentNumber, '_ECO_L1.mat');


            % save glider/deployment data to mat file...
            save(strMatFileName,...
                 'config',...
                 'gpsLat', ...
                 'gpsLon', ...
                 'ptime',...
                 'ptime_datenum',...
                 'depth', ...
                 'chlor',...
                 'cdom',...
                 'scatter',...
                 'chlor_Clean');
             
             
            units = struct('altitude', 'm',...
               'ptime', 'seconds since 0000-01-01T00:00',...
               'ptime_datenum', 'days since 1970-01-01T00:00');

            variable_description = struct('altitude', 'altimeter measured distance from bottom',...
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
                 'ptime',...
                 'ptime_datenum');

    end
    
end








