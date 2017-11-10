% For flight and CTD data, this program converts L0 data to L1 data for the specified
% glider(s) by calling gliderCTD_Generate_L1_Data. The new L1 mat file is
% stored in the pwd.
% Update for peach 2017 glider ramses
% by Lu Han, 08/2017

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
projectLabel = 'PEACH_2017';

% Use sensor timestamp or science timestamp
timeBase_is_sensor_time = false;

% SET THE GLIDER INDEX (Pelagia = 1, Ramses = 2) ...
for gliderIndex=2:2

    % SET THE DEPLOYMENT NUMBER (1, 2 or 3) ...
    for deploymentNumber=2:2
        
        %clearvars -except gliderIndex deploymentNumber;

        % glider name string and boolean ctd_Pumped
        if (gliderIndex==1)
            strGliderName = 'Pelagia';
            ctd_Pumped = false;
        else 
            strGliderName = 'Ramses';
            ctd_Pumped = false;
            if ctd_Pumped
                correctionParams = [0.028 10];
                correction_parameters = struct('alpha', correctionParams(1),...
                                    'tau', correctionParams(2));
            else
                % Not pumped
                % SET CORRECTION PARAMETERS STRUCTURE ...
                 correctionParams = [0.1587 0.0214 6.5316 1.5969];
%                 correctionParams = [0.2368    0.0023    7.9866    1.9207];
%                 correctionParams = [0.0752    0.0248   14.7322    3.5474];
                correction_parameters = struct('alpha_offset', correctionParams(1),...
                                   'alpha_slope', correctionParams(2),...
                                   'tau_offset', correctionParams(3),...
                                   'tau_slope', correctionParams(4));
            end
        end
        
        disp(['Generating Level 1 CTD data for ', strGliderName, ' Deployment ', num2str(deploymentNumber)]);

        

        % populate arrays for the deployment start and end dates...
        % ex. strStart(2, 3) is start date for Ramses, Deployment 3
        strStart = {nan,nan;'1-May-2017','5-Sep-2017'};
        strEnd   = {nan,nan;'30-May-2017','24-Sep-2017'};

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
%         ebddir = strcat('C:\Users\NewFolderSamsung\Desktop\scp\', strGliderName, filesep,'0', strDeploymentNumber,...
%                          filesep, 'ebdasc', filesep);
%         dbddir = strcat('C:\Users\NewFolderSamsung\Desktop\scp\', strGliderName, filesep,'0', strDeploymentNumber,...
%                          filesep, 'dbdasc', filesep);
          ebddir = strcat('/Users/luhan/Documents/UNC2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_09/store/ascii/ebdasc/');
          dbddir = strcat('/Users/luhan/Documents/UNC2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_09/store/ascii/dbdasc/');
%           ebddir = strcat('/pine/scr/l/u/luh/whewell.marine.unc.edu/data/peach/level0/ramses/2017_09/store/ascii/ebdasc/');
%           dbddir = strcat('/pine/scr/l/u/luh/whewell.marine.unc.edu/data/peach/level0/ramses/2017_09/store/ascii/dbdasc/');

        % define default bounds for use in plots...
        switch gliderIndex
            case 1  % Pelagia
                switch deploymentNumber
                    case 1  % Deployment 1
                        tempBounds =  [17.0 24.0];
                        salinBounds = [36.0 36.4];
                        densBounds =  [1025.0 1026.6];
                        chlorBounds = [0.0 4.0];

                    case 2  % Deployment 2
                        tempBounds =  [17.0 24.0];
                        salinBounds = [36.0 36.5];
                        densBounds =  [1024.5 1026.8];
                        chlorBounds = [0.0 4.0];

                    case 3  % Deployment 3
                        tempBounds =  [17.0 24.0];
                        salinBounds = [35.9 36.7];
                        densBounds =  [1024.4 1026.4];
                        chlorBounds = [0.0 4.0];
                end
            case 2  % Ramses
                switch deploymentNumber
                    case 1  % Deployment 1 (Only one deployment, using this for now)
                        tempBounds =  [8.0 23.0];
                        salinBounds = [35.0 36.4];
                        densBounds =  [1024.5 1027.5];
                        chlorBounds = [0.0 4.0];

                    case 2  % Deployment 2
                        tempBounds =  [9.0 25.0];
                        salinBounds = [35.2 36.6];
                        densBounds =  [1024.0 1027.5];
                        chlorBounds = [0.0 4.0];

                    case 3  % Deployment 3
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
%         movefile Ramses_Deployment2_CTD_L1_no.mat /Users/luhan/Documents/UNC2017/Data/Ramses/09:17/
    end
end
