function [flight,science,x] = grab_sbd_tbd(deploymentInfo, myBounds, correction_parameters,ctd_Pumped)

%   9 Mar 2019 - LH - reformat data output as the other deployments
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
tbddir = deploymentInfo.tbddir;
sbddir = deploymentInfo.sbddir;
% correction_parameters
% correctThermalLag requires just a 4-element array
if ctd_Pumped
    thermalLagParams_Array = [correction_parameters.alpha correction_parameters.tau];
else
    thermalLagParams_Array = [correction_parameters.alpha_offset correction_parameters.alpha_slope correction_parameters.tau_offset correction_parameters.tau_slope];
end
%% READ IN TBD DATA 
% declare variables for storing data...

x = struct;
temp=[];
cond=[];
pres=[];
ctd_time=[];
%chlor=[];
ptime_ebd=[];
% mtime=[]; 
scioxy=[]; 
scibb=[]; 
scicdom=[]; 
scichlor=[]; 
scibbam=[];

% try to load all *.ebdasc files at once...
[files, Dstruct] = wilddir(tbddir, '.tbdasc');
nfile = size(files, 1);

for i=1:nfile-1
    filename = strcat(tbddir, files(i,:));
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
            % populate variables with data...
            if(~isempty(science.data))
                 temp = [temp;science.data(:,strmatch('sci_water_temp', science.vars, 'exact'))];             % temperature
                 cond = [cond;science.data(:,strmatch('sci_water_cond', science.vars, 'exact'))];             % conductivity
                 pres = [pres;science.data(:,strmatch('sci_water_pressure', science.vars, 'exact'))];         % pressure (measure of depth) science bay
                 ctd_time = [ctd_time;science.data(:,strmatch('sci_ctd41cp_timestamp', science.vars, 'exact'))];         % ctd timestamp
                 scioxysat = [scioxysat;data.data(:,strmatch('sci_oxy4_saturation',data.vars))];     % dissolved oxygen
                 scioxy = [scioxy;data.data(:,strmatch('sci_oxy4_oxygen',data.vars))];     % dissolved oxygen
                 scibb = [scibb;data.data(:,strmatch('sci_flbbcd_bb_units',data.vars))];          % bb ????
                 scicdom = [scicdom;data.data(:,strmatch('sci_flbbcd_cdom_units',data.vars))];    % cdom
                 scichlor = [scichlor;data.data(:,strmatch('sci_flbbcd_chlor_units',data.vars))]; % chlorophyll
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

nlast=i;
%********************************************************************

% HES - get time monotonic and sort appropriately

[ts,isort] = sort(ptime_ebd);
ptime_ebd = ts;
ctd_time = ctd_time(isort);
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


iweird=find(ptime_ebd-ctd_time > 10);
ptime_ebd(iweird)=NaN; temp(iweird)=NaN; pres(iweird)=NaN; cond(iweird)=NaN;
ctd_time(iweird)=NaN;

% calculate salinity...
salin = sw_salt(10*cond/sw_c3515, temp, 10*pres);


% eliminate salinity outliers by setting them to NaN...
salin(salin>38) = nan;

% calculate density...
rho = sw_dens(salin, temp, 10*pres);    % in situ density
%rho = sw_dens0(salin,temp);            % potential density

% convert rt into datenum style...
ptime_ebd = ptime_ebd/3600/24+datenum(1970, 1, 1, 0, 0, 0);
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

ptime_datenum = ptime_ebd/3600/24+datenum(1970, 1, 1, 0, 0, 0);
gpsLat = ddmm2decdeg(gpsLat);
gpsLon = ddmm2decdeg(gpsLon);

gpsLat(~isnan(ptime_ebd)) = interp1(ptime_dbd(~isnan(ptime_ebd)), gpsLat(~isnan(ptime_ebd)), ptime_ebd(~isnan(ptime_ebd)));
gpsLon(~isnan(ptime_ebd)) = interp1(ptime_dbd(~isnan(ptime_ebd)), gpsLon(~isnan(ptime_ebd)), ptime_ebd(~isnan(ptime_ebd)));

depth = sw_dpth(pres, gpsLat);
end

