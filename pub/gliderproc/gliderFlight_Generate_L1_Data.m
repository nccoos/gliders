function flight = gliderFlight_Generate_L1_Data(deploymentInfo)

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
%}
% OUTPUTS
%{
The main output is a mat file (writtent to cwd, storing Flight data for the
glider/deployment specified in deploymentInfo. It also returns the last
processed flight struct (which was useful for debugging at one point).

%}


%% UNPACK
% deploymentInfo
projectLabel = deploymentInfo.projectLabel;
strDeploymentNumber = deploymentInfo.strDeploymentNumber;
strStartDate = deploymentInfo.strStartDate;
strEndDate = deploymentInfo.strEndDate;
strGliderName = deploymentInfo.strGliderName;
ebddir = deploymentInfo.ebddir;
dbddir = deploymentInfo.dbddir;


%% READ IN DBD DATA 
% declare variables for storing data...
ptime_dbd=[];
altitude=[];
horizontalVelocity=[];
depth = [];
pitch=[];
avgDepthRate = [];
angleOfAttack = [];

% try to load all *.dbdasc files at once...
[files, Dstruct] = wilddir(dbddir, '.dbdasc');
nfile = size(files, 1);

for i=1:nfile
    % protect against empty dbd file
    if(Dstruct(i).bytes>0)
        flight = read_gliderasc2([dbddir, files(i,:)]);

        % if the number of values (in flight.data) is less than the number of 
        % vars (in flight.vars), this means that the data were not completely read
        % in.  To correct this, pad flight.data with NaNs until its length
        % equals that of flight.vars...
        if (length(flight.data) < length(flight.vars))
            flight.data = padarray(flight.data, [0 length(flight.vars)-length(flight.data)], NaN, 'post');
        end

        % populate variables with data...
        if(~isempty(flight.data))
            ptime_dbd = [ptime_dbd; flight.data(:,strmatch('m_present_time', flight.vars, 'exact'))];
            altitude = [altitude; flight.data(:,strmatch('m_altitude', flight.vars, 'exact'))];
            horizontalVelocity = [horizontalVelocity; flight.data(:,strmatch('m_speed', flight.vars, 'exact'))];
            depth = [depth; flight.data(:,strmatch('m_depth', flight.vars, 'exact'))];
            pitch = [pitch; flight.data(:,strmatch('m_pitch', flight.vars, 'exact'))];
            avgDepthRate = [avgDepthRate; flight.data(:,strmatch('m_avg_depth_rate', flight.vars, 'exact'))];
            angleOfAttack = [angleOfAttack; flight.data(:,strmatch('u_angle_of_attack', flight.vars, 'exact'))];
        end

        flight = [];
    end
end

%% PREP OUTPUT
[Y,I] = sort(ptime_dbd);
ptime_dbd = Y;
altitude = altitude(I);
horizontalVelocity = horizontalVelocity(I);
depth = depth(I);
pitch = pitch(I);
avgDepthRate = avgDepthRate(I);
angleOfAttack = angleOfAttack(I);

% convert pitch and angle of attack from radians to degrees...
pitch = pitch*180/pi;
angleOfAttack = angleOfAttack*180/pi;

% % compute actual glide angle = pitch + angle of attack...
% glideAngle = pitch + angleOfAttack;

ptime = ptime_dbd;
% convert ptime into datenum style...for plotting I think, commenting out
% ptime_datenum = ptime/3600/24+datenum(1970, 1, 1, 0, 0, 0);
ptime_datenum = ptime/3600/24+datenum(1970, 1, 1, 0, 0, 0);
%ptimehrly = fix(ptime_datenum*24)/24;
%ptimedaily = fix(ptime_datenum);
%ptimedaily2 = unique(ptimedaily);
%ptimedaily2 = ptimedaily2(1:2:end);

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


%% SAVE OUTPUT
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
