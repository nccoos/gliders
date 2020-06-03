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
projectLabel = 'PEACH_2017';

% Use sensor timestamp or science timestamp
timeBase_is_sensor_time = true;
strStart = {nan,nan,nan,nan,nan,nan;'16-May-2017','5-Sep-2017','22-Dec-2017','15-May-2018','5-Jul-2018','7-Sep-2018'};
strEnd   = {nan,nan,nan,nan,nan,nan;'29-May-2017','24-Sep-2017','10-Jan-2018','8-Jun-2018','18-Jul-2018','29-Sep-2018'};
ebdDIR = strcat(['/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_05/store/ascii/ebdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_09/store/ascii/ebdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_12/store/ascii/ebdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_05/store/ascii/ebdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_07/store/ascii/ebdasc/'
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_09/store/ascii/ebdasc/']);
dbdDIR = strcat(['/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_05/store/ascii/dbdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_09/store/ascii/dbdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_12/store/ascii/dbdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_05/store/ascii/dbdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_07/store/ascii/dbdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_09/store/ascii/dbdasc/']);
          
% SET THE GLIDER INDEX (Pelagia = 1, Ramses = 2) ...
for gliderIndex=2:2

    % SET THE DEPLOYMENT NUMBER (1, 2 or 3) ...
    for deploymentNumber=2:6
        
        %clearvars -except gliderIndex deploymentNumber;

        % glider name string
        if (gliderIndex==1)
            strGliderName = 'Pelagia';
        else
            strGliderName = 'Ramses';
        end
        
        disp(['Generating Level 1 ECO data for ', strGliderName, ' Deployment ', num2str(deploymentNumber)]);      

        
        % deployment number string...
        strDeploymentNumber = num2str(deploymentNumber);

        % deployment start date string...
        strStartDate = strStart(gliderIndex, deploymentNumber);%(gliderIndex, deploymentNumber);

        % deployment end date string...
        strEndDate = strEnd(gliderIndex, deploymentNumber);%(gliderIndex, deploymentNumber);

        % define the path to the glider ascii files...
        %datadir = strcat('/Users/haloboy/Documents/MASC/MATLAB/CTD_data_correction/GLIDER_CTD_DATA_LEVEL0/',...
        %datadir = strcat('GLIDER_DATA_LEVEL0/', strGliderName, '_Deployment', strDeploymentNumber, '/');
        % My full set [SBL]
        ebddir = ebdDIR(deploymentNumber,:);
        dbddir = dbdDIR(deploymentNumber,:);
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
                    case 4  % Deployment 4
                        chlorBounds = [0.0 4.0];
                    case 5  % Deployment 3
                        chlorBounds = [0.0 4.0];
                    case 6  % Deployment 4
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
