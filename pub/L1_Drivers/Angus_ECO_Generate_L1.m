%  Lu Han
%  Graduate Research Assistant
%  Department of Marine Sciences
%  University of North Carolina - Chapel Hill
%  Chapel Hill NC
%  Generate level1 data from Angus
%  Different time bases are used in ctd, eco and flight data respectively
%  and maybe oxygen when it gets processed...
clear all
% close all
addpath('../gliderproc');
addpath('../gliderproc/MATLAB/util');
addpath('../gliderproc/MATLAB/plots');
addpath('../gliderproc/MATLAB/seawater');
addpath('../gliderproc/MATLAB/strfun');
addpath('../../glider_toolbox-master/m/processing_tools');
trnum='tr15';

strStart = {'Oct-31-2018'};
strEnd   = {'Nov-20-2018'};

% SET THE DEPLOYMENT NUMBER (1, 2 or 3) ...
for deploymentNumber=1:1
    strGliderName = 'Angus';
    
    disp(['Generating Level 1 CTD data for ', strGliderName, ' Deployment ', num2str(deploymentNumber)]);
    % deployment number string...
    strDeploymentNumber = num2str(deploymentNumber);
    
    % deployment start date string...
    strStartDate = strStart(deploymentNumber);
    
    % deployment end date string...
    strEndDate = strEnd(deploymentNumber);
    %         tbddir = '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/modena/2018_03/tbdasc/';
    %         sbddir = '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/modena/2018_03/sbdasc/';
    dbddir = ['/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/angus/2018_11/store/ascii/dbdasc/'];
    ebddir = ['/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/angus/2018_11/store/ascii/ebdasc/'];
    
    
    %% READ IN TBD DATA
    % declare variables for storing data...
    
    pres=[];
    chlor=[];
    cdom=[];
    scatter=[];
    chlor_sig=[];
    cdom_sig=[];
    scatter_sig=[];
    chlor_ref=[];
    cdom_ref=[];
    scatter_ref=[];
    eco_time=[];
    ptime_ebd=[];
    
    % try to load all *.ebdasc files at once...
    [files, Dstruct] = wilddir(ebddir(deploymentNumber,:), '.ebdasc');
    nfile = size(files, 1);
    
    for i=1:nfile-1
        filename = strcat(ebddir(deploymentNumber,:), files(i,:));
        % protect against empty ebd file
        science = struct;
        if(Dstruct(i).bytes>0)
            try
                science = read_gliderasc2(filename);
                
                % if the number of values (in science.data) is less than the number of
                % vars (in science.vars), this means that the data were not completely read
                % in.  To correct this, pad science.data with NaNs until its length
                % equals that of science.vars...
                if (length(science.data) < length(science.vars))
                    disp_String = sprintf('%s %s %s %s','length(science.data)=',int2str(length(science.data)),'length(science.vars)=',int2str(length(science.vars)));
                    disp(disp_String);
                    science.data = padarray(science.data, [0 length(science.vars)-length(science.data)], NaN, 'post');
                end
                
                % populate variables with data...
                if(~isempty(science.data))
                    pres = [pres;science.data(:,strmatch('sci_water_pressure', science.vars, 'exact'))];         % pressure (measure of depth) science bay
                    chlor =   [chlor;science.data(:,strmatch('sci_flbbcd_chlor_units', science.vars, 'exact'))];  % chlorophyll
                    cdom =    [cdom;science.data(:,strmatch('sci_flbbcd_cdom_units', science.vars, 'exact'))];  % cdom
                    scatter = [scatter;science.data(:,strmatch('sci_flbbcd_bb_units', science.vars, 'exact'))];  % scatter
                    chlor_sig =   [chlor_sig;science.data(:,strmatch('sci_flbbcd_chlor_sig', science.vars, 'exact'))];  % chlorophyll
                    cdom_sig =    [cdom_sig;science.data(:,strmatch('sci_flbbcd_cdom_sig', science.vars, 'exact'))];  % cdom
                    scatter_sig = [scatter_sig;science.data(:,strmatch('sci_flbbcd_bb_sig', science.vars, 'exact'))];  % scatter
                    chlor_ref =   [chlor_ref;science.data(:,strmatch('sci_flbbcd_chlor_ref', science.vars, 'exact'))];  % chlorophyll
                    cdom_ref =    [cdom_ref;science.data(:,strmatch('sci_flbbcd_cdom_ref', science.vars, 'exact'))];  % cdom
                    scatter_ref = [scatter_ref;science.data(:,strmatch('sci_flbbcd_bb_ref', science.vars, 'exact'))];  % scatter 
                    eco_time = [eco_time;science.data(:,strmatch('sci_flbbcd_timestamp', science.vars, 'exact'))];  % flbbcd timestamp          
                    ptime_ebd = [ptime_ebd;science.data(:,strmatch('sci_m_present_time', science.vars, 'exact'))];       % present time
                end
            catch err

            end
        end
    end

    [Y,I] = sort(ptime_ebd);
    ptime_ebd = Y;
    pres = pres(I);
    chlor=chlor(I);
    cdom=cdom(I);
    scatter=scatter(I);
    chlor_sig=chlor_sig(I);
    cdom_sig=cdom_sig(I);
    scatter_sig=scatter_sig(I);
    chlor_ref=chlor_ref(I);
    cdom_ref=cdom_ref(I);
    scatter_ref=scatter_ref(I);
    eco_time=eco_time(I);
    
    % Remove eco measurements when ptime_ebd and eco_time are a lot different
    % eco_time is full of nans, so here use ptime_ebd as timebase
%     iweird=find(ptime_ebd-eco_time > 10);
%     ptime_ebd(iweird)=NaN;
%     pres(iweird)=NaN;
%     chlor(iweird)=NaN; cdom(iweird)=NaN; scatter(iweird)=NaN;
%     chlor_sig(iweird)=NaN; cdom_sig(iweird)=NaN; scatter_sig(iweird)=NaN;
%     chlor_ref(iweird)=NaN; cdom_ref(iweird)=NaN; scatter_ref(iweird)=NaN;
%     eco_time(iweird)=NaN;
%     ptime = eco_time;
    ptime = ptime_ebd;
    
    I = find(ptime>0&pres>0&chlor>0);
    ptime = ptime(I);
    pres = pres(I);
    chlor=chlor(I);
    cdom=cdom(I);
    scatter=scatter(I);
    chlor_sig=chlor_sig(I);
    cdom_sig=cdom_sig(I);
    scatter_sig=scatter_sig(I);
    chlor_ref=chlor_ref(I);
    cdom_ref=cdom_ref(I);
    scatter_ref=scatter_ref(I);
    
    % convert ptime into datenum style...for plotting I think, commenting out
    ptime_datenum = ptime/3600/24+datenum(1970, 1, 1, 0, 0, 0);
%%
    ptime_dbd=[];
    depth = [];
    gpsLat = [];
    gpsLon = [];
    % try to load all *.dbdasc files at once...
    [files, Dstruct] = wilddir(dbddir(deploymentNumber,:), '.dbdasc');
    nfile = size(files, 1);
    for i=1:nfile
        filename = strcat(dbddir(deploymentNumber,:), files(i,:));
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
    gpsLat = ddmm2decdeg(gpsLat);
    gpsLon = ddmm2decdeg(gpsLon);
    
    %%
    i = find(abs(gpsLat) <= 90.0);
    gpsLat = gpsLat(i);  gpsLon = gpsLon(i);  ptime_dbd = ptime_dbd(i);
    i = find(abs(gpsLon) <= 180.0);
    gpsLat = gpsLat(i);  gpsLon = gpsLon(i);  ptime_dbd = ptime_dbd(i);
    
    % interpolate DBD lat/lon data to align with EBD data...
    gpsLat = interp1(ptime_dbd, gpsLat, ptime);
    gpsLon = interp1(ptime_dbd, gpsLon, ptime);
    
    depth = sw_dpth(pres*10, gpsLat);
    
    %% OUTPUT
    % create configuration struct...
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
        'chlor_Clean','chlorophyll after QCed', ...
        'cdom', 'chromophoric dissolved organic matter',...
        'scatter', 'backscatter',...
        'chlor_sig','chlorophyll raw count',...
        'cdom_sig', 'chromophoric dissolved organic matter raw count',...
        'scatter_sig', 'backscatter raw count',...
        'chlor_ref','chlorophyll reference count',...
        'cdom_ref', 'chromophoric dissolved organic matter reference count',...
        'scatter_ref', 'backscatter reference count');
    
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
        'chlor_sig',...
        'cdom_sig',...
        'scatter_sig',...
        'chlor_ref',...
        'cdom_ref',...
        'scatter_ref');
    
end








