function [flight, science] = gliderECO_Generate_L1_Data(deploymentInfo, myBounds,timeBase_is_eco_time)

%
%  gliderECO_Generate_L1_Data.m
%
%  Purpose: Apply basic QC and generate Level 1 data mat files.
%
%
%  Requires:
%
%  MATLAB folder - contains util, seawater 
%
%
%  Author:  Steve Lockhart
%           Marine Sciences Department
%           UNC-Chapel Hill
%
%  Created: 26 Oct 2016


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
                        -chlorBounds
timeBase_is_eco_time:   If this is true, eco_time will be saved in the
                        output mat file; otherwise, ptime_ebd ("science time").
%}

% OUTPUTS
%{
The main output is a mat file (writtent to cwd, storing ECO (and related) data for the
glider/deployment specified in deploymentInfo. It also returns the last
processed flight, science structs (which was useful for debugging at one point).

%}
% NOTES
%{
-Started with gliderCTD_Generate_L1_Data.m and made changes.

-Currently not processing the last science file.

-Currently not using bounds.

-Reordering is required because the individual ebdasc, dbdasc files are not processed in the correct order.
 Perhaps a better renaming (i.e. file name convention) would eliminate the
 need for reordering. For now, not renaming at all (for SECOORA_2016), so
 this preserves the order. The advantage of doing this is that you are able
 to see this issue for OTHER reason(s) e.g. resynch of clocks.
%}

% TO DO: 
%{
-Some QC
%}


%% UNPACK
% myBounds
chlorBounds = myBounds.chlorBounds;
% deploymentInfo
projectLabel = deploymentInfo.projectLabel;
strDeploymentNumber = deploymentInfo.strDeploymentNumber;
strStartDate = deploymentInfo.strStartDate;
strEndDate = deploymentInfo.strEndDate;
strGliderName = deploymentInfo.strGliderName;
ebddir = deploymentInfo.ebddir;
dbddir = deploymentInfo.dbddir;


%% READ IN EBD DATA 
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
[files, Dstruct] = wilddir(ebddir, '.ebdasc');
nfile = size(files, 1);

% Loop on science files
display_String = sprintf('%s %s %s %s %s\n','Processing', int2str(nfile-1),'of the',int2str(nfile),'ebdasc files');
disp(display_String);
for i=1:nfile-1
    filename = strcat(ebddir, files(i,:))
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
                if timeBase_is_eco_time
                    eco_time = [eco_time;science.data(:,strmatch('sci_flbbcd_timestamp', science.vars, 'exact'))];  % flbbcd timestamp 
                end
                ptime_ebd = [ptime_ebd;science.data(:,strmatch('sci_m_present_time', science.vars, 'exact'))];       % present time
            end
        catch err
            science
            throw(err)
            %error('ERROR reading ',filename);
            return
        end
    else
        % Do nothing
    end  
end


%% READ IN DBD DATA
% declare variables for storing data...
depth = [];
gpsLat = [];
gpsLon = [];
ptime_dbd=[];

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
                depth = [depth; flight.data(:,strmatch('m_depth', flight.vars, 'exact'))];                              % depth      
                gpsLat = [gpsLat; flight.data(:,strmatch('m_gps_lat', flight.vars, 'exact'))];                          % GPS latitude
                gpsLon = [gpsLon; flight.data(:,strmatch('m_gps_lon', flight.vars, 'exact'))];                          % GPS longitude
            end
        catch err
            flight
            error('ERROR reading ',filename);
            return
        end
    else
        flight = struct;
    end
end


%% WHICH TIME BASE TO USE
if timeBase_is_eco_time
    save('timeBases.mat','ptime_ebd','eco_time');
    % science time or eco time
    display_String = sprintf('%s %s %s %s\n','len(ptime_ebd)=',int2str(length(ptime_ebd)),'; len(eco_time)=',int2str(length(eco_time)));
    disp(display_String)
    display_String = sprintf('%s %s %s %s\n','len(~isnan(ptime_ebd))=',int2str(length(~isnan(ptime_ebd))),'; len(~isnan(eco_time))=',int2str(length(~isnan(eco_time))));
    disp(display_String)
end

sampleInterval_Centers = [-1 0 0.1 1 2 3 4 5 10 30 100 300 1000 3000];

% Look at science time
figure; plot(ptime_ebd,'bo-'); title('Sample time for sci-m-present-time, before sorting'); xlabel('Sample Number'); ylabel('Secs since 1/1/1970');
ptime_ebdgt0 = ptime_ebd(ptime_ebd>0);
plot0 = zeros(1,length(ptime_ebdgt0));
figure; plot(ptime_ebdgt0,plot0,'bo-'); title('Sample time for sci-m-present-time>0, before sorting'); xlabel('Secs since 1/1/1970');
figure; plot(diff(ptime_ebdgt0),'bo-'); title('Sample interval for sci-m-present-time>0, before sorting'); xlabel('Sample Number'); ylabel('Secs');
[N,X] = hist(diff(ptime_ebdgt0)); 
figure; plot(X,N,'ko-'); title('Histogram of sample interval for sci-m-present-time>0, before sorting'); xlabel('Secs');

if timeBase_is_eco_time
    % Look at eco time
    figure; plot(eco_time,'bo-'); title('Sample time for eco'); xlabel('Sample Number'); ylabel('Secs since 1/1/1970');
    eco_timegt0 = eco_time(eco_time>0);
    plot0 = zeros(1,length(eco_timegt0));
    figure; plot(eco_timegt0,plot0,'ro-'); title('Sample time>0 for eco, before sorting'); xlabel('Secs since 1/1/1970');
    figure; plot(diff(eco_timegt0),'bo-'); title('Sample interval for eco>0, before sorting'); xlabel('Sample Number'); ylabel('Secs');
    [N,X] = hist(diff(eco_timegt0)); 
    figure; plot(X,N,'ko-'); title('Histogram of sample interval for eco, before sorting'); xlabel('Secs');

    % Compare time bases
    plot0 = zeros(1,length(ptime_ebdgt0));
    figure; plot(ptime_ebdgt0,plot0,'bo-'); hold on;
    plot0 = zeros(1,length(eco_timegt0));
    plot(eco_timegt0,plot0,'ro-'); hold on;
    plot0 = zeros(1,length(ptime_ebdgt0(eco_time<=0)));
    plot(ptime_ebd(eco_time<=0),plot0,'k+-'); 
    legend('sci','eco>0','sci when eco=0'); xlabel('Secs since 1/1/1970');
end


%% GET STATS ON L0 DATA
[N1_chlor,X1_chlor] = hist(chlor);
[N1_scatter,X1_scatter] = hist(scatter);


%% SOME QC
% First, apply the sort() function to make sure that values in the time vectors
% (ptime_ebd and ptime_dbd) increase monotonically...
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
if timeBase_is_eco_time
    eco_time=eco_time(I);
end

% Remove eco measurements when ptime_ebd and eco_time are a lot different
if timeBase_is_eco_time
    iweird=find(ptime_ebd-eco_time > 10);
    ptime_ebd(iweird)=NaN; 
    pres(iweird)=NaN;
    chlor(iweird)=NaN; cdom(iweird)=NaN; scatter(iweird)=NaN;
    chlor_sig(iweird)=NaN; cdom_sig(iweird)=NaN; scatter_sig(iweird)=NaN;
    chlor_ref(iweird)=NaN; cdom_ref(iweird)=NaN; scatter_ref(iweird)=NaN;
    eco_time(iweird)=NaN;
end


%% DECIDE ON TIME BASE
if timeBase_is_eco_time
    % Define ptime to be eco_time
    ptime = eco_time;
    ptime_Descrip = 'sensor time';
else
    % Define ptime to be science time
    ptime = ptime_ebd;
    ptime_Descrip = 'science time';
end

% Remove nans from EBD data...
% HES - need full triplet from CTD
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
%ptime_datenum_dbd = ptime_dbd/3600/24+datenum(1970, 1, 1, 0, 0, 0);
%ptimehrly = fix(ptime_datenum*24)/24;
%ptimedaily = fix(ptime_datenum);
%ptimedaily2 = unique(ptimedaily);
%ptimedaily2 = ptimedaily2(1:2:end);


%% PLOT STATS ON L0 DATA AFTER QC (BOUNDS)
[N2_chlor,X2_chlor] = hist(chlor);
[N2_scatter,X2_scatter] = hist(scatter);
%% More QC
%Clean Chlorophyll by getting rid of the spike at the beginning of some dives.
gap = diff(ptime_datenum);      %Locate the beginning of dives 
gap_loc = find(gap>0.005)+1;
chlor_Clean = chlor;
for i = 1:length(gap_loc)
    if gap_loc(i)+200 <= length(pres)
    [peaks,loc] = findpeaks(pres(gap_loc(i):gap_loc(i)+200));
    % If the value of the first two casts of each dive is larger than the 
    % mean + standard deviation of the next 5 casts, then replace it with nan.
       for j = gap_loc(i):gap_loc(i)+2*loc(1)
           if chlor(j)> ... 
              mean(chlor(gap_loc(i)+2*loc(1)+1:gap_loc(i)+7*loc(1)))...
                  +std(chlor(gap_loc(i)+2*loc(1)+1:gap_loc(i)+7*loc(1)))
              chlor_Clean(j) = nan;
           end
       end
    end
end            
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

% scale up the pressure...
pres = pres*10;

% use sw_dpth() to calculate depth from pres...
depth = sw_dpth(pres, gpsLat);


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
                              'ptime', ptime_Descrip,...
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
     'chlor_Clean',...
     'cdom',...
     'scatter',...
     'chlor_sig',...
     'cdom_sig',...
     'scatter_sig',...
     'chlor_ref',...
     'cdom_ref',...
     'scatter_ref');


 %% PLOT STATS
figure; semilogy(X1_chlor,N1_chlor,'ko-'); hold on;
        semilogy(X2_chlor,N2_chlor,'rs--'); 
        xlabel('chlor'); ylabel('Num Occurs'); 
        legend('L0','L0+Bounds');
figure; semilogy(X1_scatter,N1_scatter,'ko-'); hold on;
        semilogy(X2_scatter,N2_scatter,'rs--'); 
        xlabel('scatter'); ylabel('Num Occurs');
        legend('L0','L0+Bounds');
