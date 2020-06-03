% For flight and CTD data, this program converts L0 data to L1 data for the specified
% glider(s) by calling gliderCTD_Generate_L1_Data. The new L1 mat file is
% stored in the pwd.

% Started with the LongBay_2012 driver and made the following changes:
%{
    -Replaced Pegasus with Salacia. However, there is currently no support
    for Salacia in the called programs, and we're keeping the Pegasus
    values for now. In other words, only Ramses is really supported here
%}


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

% SET THE GLIDER INDEX (Salacia = 1, Ramses = 2) ...
for gliderIndex=2:2

    % SET THE DEPLOYMENT NUMBER (1, 2 or 3) ...
    for deploymentNumber=1:1
        
        %clearvars -except gliderIndex deploymentNumber;

        % glider name string and boolean ctd_Pumped
        if (gliderIndex==1)
            strGliderName = 'Salacia';
            ctd_Pumped = false;
            % Use sensor timestamp or science timestamp
            timeBase_is_sensor_time = false;
        else
            strGliderName = 'Ramses';
            ctd_Pumped = false;
            if ctd_Pumped
                correctionParams = [0.028 10];                      % Using values in Lueck paper for now
                correction_parameters = struct('alpha', correctionParams(1),...
                                    'tau', correctionParams(2));
            else
                % Not pumped
                % SET CORRECTION PARAMETERS STRUCTURE ...
                %correctionParams = [0.1587 0.0214 6.5316 1.5969];   % used in Long Bay
                %correctionParams = [0.1328 0.0208 9.7492 4.6128];   % median vals from Garau
                correctionParams = [0.1328 0.03 9.7492 4.6128];   % median vals from Garau but alpha slope set to zero
                correction_parameters = struct('alpha_offset', correctionParams(1),...
                                   'alpha_slope', correctionParams(2),...
                                   'tau_offset', correctionParams(3),...
                                   'tau_slope', correctionParams(4));
            end
            % Use sensor timestamp or science timestamp
            timeBase_is_sensor_time = true;
        end
        
        disp(['Generating Level 1 CTD data for ', strGliderName, ' Deployment ', num2str(deploymentNumber)]);

        

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
            case 1  % Salacia
                switch deploymentNumber
                    case 1  % Deployment 1 (using Pegasus Long Bay deployment 3 for now)
                        tempBounds =  [17.0 24.0];
                        salinBounds = [35.9 36.7];
                        densBounds =  [1024.4 1026.4];
                        chlorBounds = [0.0 4.0];
                end
            case 2  % Ramses
                switch deploymentNumber
                    case 1  % Deployment 1 (using Ramses Long Bay deployment 3 for now)
                        tempBounds =  [10.0 24.5];
                        salinBounds = [35.3 36.7];
                        densBounds =  [1024.4 1027.4];
                        chlorBounds = [0.0 4.0];
                end
        end
        
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
        flight = gliderFlight_Generate_L1_Data(deploymentInfo);
        [flight, science, x] = gliderCTD_Generate_L1_Data(deploymentInfo,myBounds,correction_parameters,ctd_Pumped,timeBase_is_sensor_time);
    end
end
