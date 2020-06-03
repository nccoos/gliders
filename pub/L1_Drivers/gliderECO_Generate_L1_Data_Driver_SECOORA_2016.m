% For ECO data, this program converts L0 data to L1 data for the specified
% glider(s) by calling gliderECO_Generate_L1_Data. The new L1 mat file is
% stored in the pwd.

clear all;
close all;

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

% Set project label
projectLabel = 'SECOORA_2016';

% Use sensor timestamp or science timestamp
timeBase_is_sensor_time = true;

% SET THE GLIDER INDEX (Pelagia = 1, Ramses = 2) ...
for gliderIndex=2:2

    % SET THE DEPLOYMENT NUMBER (1, 2 or 3) ...
    for deploymentNumber=1:1
        
        %clearvars -except gliderIndex deploymentNumber;

        % glider name string
        if (gliderIndex==1)
            strGliderName = 'Pelagia';
        else
            strGliderName = 'Ramses';
        end
        
        disp(['Generating Level 1 ECO data for ', strGliderName, ' Deployment ', num2str(deploymentNumber)]);      

        % populate arrays for the deployment start and end dates...
        % ex. strStart(2, 3) is start date for Ramses, Deployment 3
        strStart = {'09-Sep-2016'; '09-Sep-2016'};
        strEnd   = {'09-Oct-2016'; '09-Oct-2016'};

        % deployment number string...
        strDeploymentNumber = num2str(deploymentNumber);

        % deployment start date string...
        strStartDate = strStart(gliderIndex, deploymentNumber);

        % deployment end date string...
        strEndDate = strEnd(gliderIndex, deploymentNumber);

        % define the path to the glider ascii files...
        %datadir = strcat('/Users/haloboy/Documents/MASC/MATLAB/CTD_data_correction/GLIDER_CTD_DATA_LEVEL0/',...
        %datadir = strcat('GLIDER_DATA_LEVEL0/', strGliderName, '_Deployment', strDeploymentNumber, '/');
        % My full set [SBL]
        ebddir = 'C:\Users\slockhar\Projects\Glider\GliderFiles\SECOORA_2016\Ramses\history\All\EndOfMissionSecoora2016\ebdasc\';
        dbddir = 'C:\Users\slockhar\Projects\Glider\GliderFiles\SECOORA_2016\Ramses\history\All\EndOfMissionSecoora2016\dbdasc\';
        
        % define default bounds for use in plots...
        switch gliderIndex
            case 1  % Pelagia
                switch deploymentNumber
                    case 1  % Deployment 1
                        chlorBounds = [0.0 4.0];

                    case 2  % Deployment 2
                        chlorBounds = [0.0 4.0];

                    case 3  % Deployment 3
                        chlorBounds = [0.0 4.0];
                end
            case 2  % Ramses
                switch deploymentNumber
                    case 1  % Deployment 1
                        chlorBounds = [0.0 4.0];

                    case 2  % Deployment 2
                        chlorBounds = [0.0 4.0];

                    case 3  % Deployment 3
                        chlorBounds = [0.0 4.0];
                end
        end
        
        % Pack
        % myBounds
        myBounds = struct;
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
        % Call gliderECO_Generate_L1_Data
        [flight, science] = gliderECO_Generate_L1_Data(deploymentInfo,myBounds,timeBase_is_sensor_time);
    end
end
