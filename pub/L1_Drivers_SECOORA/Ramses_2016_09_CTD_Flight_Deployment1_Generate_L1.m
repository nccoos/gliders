% For flight and CTD data, this program converts L0 data to L1 data for the specified
% glider(s) by calling gliderCTD_Generate_L1_Data. The new L1 mat file is
% stored in the pwd.
%
% Update for peach 2017 glider ramses
% by Lu Han, 08/2017
% Level1: only thermal lag corrected with default parameter 
% Update for SECOORA G1 gliders
%
% by Sara Haines 03/2021
% paired down driver code to only do one glider and one deploy at a time --
% and code cleanup

clear all;
% close all;

% the needed MATLAB paths are in startup.m -- start MATLAB in path with
% startup.m and it loads automatically

% Set project label
projectLabel = 'SECOORA_2016';
strGliderName = 'Ramses';
strDeploymentNumber = num2str(1);  % use for numbering deploys of a project if needed
ebddir = 'D:/data/secoora/level0/ramses/2016_09/store/ascii/ebdasc/';
dbddir = 'D:/data/secoora/level0/ramses/2016_09/store/ascii/dbdasc/';

outdir = 'D:/data/secoora/level1/ramses/';

% deployment start date string...
strStartDate = '09-Sep-2016';
% deployment end date string...
strEndDate = '25-Sep-2016';

% Use sensor timestamp or science timestamp
timeBase_is_sensor_time = false;

% G1 gliders are not pumped and require special consideration of glider speed
ctd_Pumped = false;

if ctd_Pumped
  correctionParams = [0.028 10];
  correction_parameters = struct('alpha', correctionParams(1),...
				 'tau', correctionParams(2));
else
  % Not pumped
  % SET CORRECTION PARAMETERS STRUCTURE ...
  %                  correctionParams = [0.1328 0.0208 9.7492 4.6128]; %median from Garau et.al.2011
  %                  correctionParams = [0.1587 0.0214 6.5316 1.5969]; % longbay
  correctionParams = [0.2368    0.0023    7.9866    1.9207];
  %             correctionParams = [0.0016    0.0122   22.4810    0.0397];
  %             correctionParams = [0.1013    0.0163    9.6214    8.8860];
  %                 correctionParams = [0.13    0.0195    1    1];
  %                 correctionParams = [0.0752    0.0248   14.7322    3.5474];
  correction_parameters = struct('alpha_offset', correctionParams(1),...
				 'alpha_slope', correctionParams(2),...
				 'tau_offset', correctionParams(3),...
				 'tau_slope', correctionParams(4));
end

% bounds for plots
tempBounds =  [9.0, 26];
salinBounds = [29.5, 36.7];
densBounds =  [1021, 1026.6];
chlorBounds = [0.0 4.0];

        
% Pack
% myBounds
myBounds = struct;
myBounds.tempBounds = tempBounds;
myBounds.salinBounds = salinBounds;
myBounds.densBounds = densBounds;
myBounds.chlorBounds = chlorBounds;
% deploymentInfo
deploymentInfo = struct;
deploymentInfo.projectLabel = projectLabel;
deploymentInfo.strDeploymentNumber = strDeploymentNumber;
deploymentInfo.strStartDate = strStartDate;
deploymentInfo.strEndDate = strEndDate;
deploymentInfo.strGliderName = strGliderName;
deploymentInfo.ebddir = ebddir;
deploymentInfo.dbddir = dbddir;

% Call gliderFlight_Generate_L1_Data and gliderCTD_Generate_L1_Data
% remove the flight generating function and merge that into the CTD
% generating function
%         flight = gliderFlight_Generate_L1_Data(deploymentInfo);

disp('start!')
[flight, science, x] = gliderCTD_Generate_L1_Data(deploymentInfo,myBounds,correction_parameters,ctd_Pumped,timeBase_is_sensor_time);

movefile(['Ramses_Deployment' strDeploymentNumber '_CTD_L1.mat'], outdir);
movefile(['Ramses_Deployment' strDeploymentNumber '_Flight_L1.mat'], outdir);

