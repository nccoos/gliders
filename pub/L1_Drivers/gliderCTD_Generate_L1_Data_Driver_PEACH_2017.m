% For flight and CTD data, this program converts L0 data to L1 data for the specified
% glider(s) by calling gliderCTD_Generate_L1_Data. The new L1 mat file is
% stored in the pwd.
% Update for peach 2017 glider ramses
% by Lu Han, 08/2017
% Level1: only thermal lag corrected with default parameter 

clear all;
% close all;

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
% populate arrays for the deployment start and end dates...
        % ex. strStart(2, 3) is start date for Ramses, Deployment 3
strStart = {'10-Jul-2017',nan,nan,nan,nan,nan;'16-May-2017','5-Sep-2017','22-Dec-2017','15-May-2018','5-Jul-2018','7-Sep-2018'};
strEnd   = {'15-Jul-2017',nan,nan,nan,nan,nan;'29-May-2017','24-Sep-2017','10-Jan-2018','8-Jun-2018','18-Jul-2018','29-Sep-2018'};
ebdDIR = strcat(['/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_05/store/ascii/ebdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_09/store/ascii/ebdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_12/store/ascii/ebdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_05/store/ascii/ebdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_07/store/ascii/ebdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_09/store/ascii/ebdasc/']);
dbdDIR = strcat(['/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_05/store/ascii/dbdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_09/store/ascii/dbdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2017_12/store/ascii/dbdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_05/store/ascii/dbdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_07/store/ascii/dbdasc/';
          '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/ramses/2018_09/store/ascii/dbdasc/']);
          
% SET THE GLIDER INDEX (Salacia = 1, Ramses = 2) ...
for gliderIndex=1:1

    % SET THE DEPLOYMENT NUMBER (1, 2 or 3) ...
    for deploymentNumber=1:1
        
        %clearvars -except gliderIndex deploymentNumber;

        % glider name string and boolean ctd_Pumped
        if (gliderIndex==1)
            strGliderName = 'Salacia';
            ctd_Pumped = false;
        else 
            strGliderName = 'Ramses';
            ctd_Pumped = false;
        end
        if ctd_Pumped
            correctionParams = [0.028 10];
            correction_parameters = struct('alpha', correctionParams(1),...
                'tau', correctionParams(2));
        else
            % Not pumped
            % SET CORRECTION PARAMETERS STRUCTURE ...
%                              correctionParams = [0.1328 0.0208 9.7492 4.6128]; %median from Garau et.al.2011
            %                  correctionParams = [0.1587 0.0214 6.5316 1.5969]; %
            %                  longbay
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
        
        
        disp(['Generating Level 1 CTD data for ', strGliderName, ' Deployment ', num2str(deploymentNumber)]);

        

        
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
          ebddir = ebdDIR(deploymentNumber,:);
          dbddir = dbdDIR(deploymentNumber,:);
     if gliderIndex == 1
         ebddir = '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/salacia/2017_07/store/ascii/ebdasc/';
         dbddir = '/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/whewell.marine.unc.edu/data/peach/level0/salacia/2017_07/store/ascii/dbdasc/';
     end
        % define default bounds for use in plots...
        switch gliderIndex
            case 1  % Pelagia
                switch deploymentNumber
                    case 1  % Deployment 1
                        tempBounds =  [22.2 27.9];
                        salinBounds = [35.8 37];
                        densBounds =  [1023.0 1025.6];
                        chlorBounds = [0.0 4.0];

%                     case 2  % Deployment 2
%                         tempBounds =  [17.0 24.0];
%                         salinBounds = [36.0 36.5];
%                         densBounds =  [1024.5 1026.8];
%                         chlorBounds = [0.0 4.0];
% 
%                     case 3  % Deployment 3
%                         tempBounds =  [17.0 24.0];
%                         salinBounds = [35.9 36.7];
%                         densBounds =  [1024.4 1026.4];
%                         chlorBounds = [0.0 4.0];
                end
            case 2  % Ramses
                switch deploymentNumber
                    case 1  % Deployment 1 (Only one deployment, using this for now)
                        tempBounds =  [9.0, 26];
                        salinBounds = [29.5, 36.7];
                        densBounds =  [1021, 1026.6];
                        chlorBounds = [0.0 4.0];

                    case 2  % Deployment 2
                        tempBounds =  [12.6, 28];
                        salinBounds = [29.5 36.7];
                        densBounds =  [1019.5 1027];
                        chlorBounds = [0.0 4.0];

                    case 3  % Deployment 3
                        tempBounds =  [7.5 19.3];
                        salinBounds = [29.5 36];
                        densBounds =  [1022.6 1026.5];
                        chlorBounds = [0.0 4.0];
                    case 4  % Deployment 4
                        tempBounds =  [8.45 26.2];
                        salinBounds = [26.65 37];
                        densBounds =  [1017.65 1026.3];
                        chlorBounds = [0.0 4.0]; 
                     case 5  % Deployment 3
                        tempBounds =  [23.4 30];
                        salinBounds = [28.65 37];
                        densBounds =  [1018.4 1024.85];
                        chlorBounds = [0.0 4.0];
                     case 6  % Deployment 4
                        tempBounds =  [13.25 29.5];
                        salinBounds = [26.5 36];
                        densBounds =  [1016 1026];
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
        % remove the flight generating function and merge that into the CTD
        % generating function
%         flight = gliderFlight_Generate_L1_Data(deploymentInfo);

        disp('start!')
        [flight, science, x] = gliderCTD_Generate_L1_Data(deploymentInfo,myBounds,correction_parameters,ctd_Pumped,timeBase_is_sensor_time);
%         movefile Ramses_Deployment2_CTD_L1_no.mat /Users/luhan/Documents/UNC2017/Data/Ramses/09:17/
    end
end
