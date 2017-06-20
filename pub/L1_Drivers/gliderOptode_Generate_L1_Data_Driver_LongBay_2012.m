% For dissolved oxygen data, this program converts L0 data to L1 data for the specified
% glider(s) by calling gliderOptode_Generate_L1_Data. The new L1 mat file is
% stored in the pwd.

clear all;
close all;

% Addpaths
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
projectLabel = 'LongBay_2012';

% Use sensor timestamp or science timestamp
timeBase_is_sensor_time = false;

% populate arrays for the deployment start and end dates...
% ex. strStart(2, 3) is start date for Ramses, Deployment 3
strStart = {'26-Jan-2012', '16-Feb-2012', '16-Mar-2012'; ...
            '26-Jan-2012', '16-Feb-2012', '16-Mar-2012'};
strEnd   = {'14-Feb-2012', '08-Mar-2012', '04-Apr-2012'; ...
            '14-Feb-2012', '12-Mar-2012', '03-Apr-2012'};
        
% Setting debug_Level to:
%   0: No plots
%   1: Summary plots per glider, per deployment
%   2: Detailed plots
debug_Level = 0;

% SET THE GLIDER INDEX (Pelagia = 1, Ramses = 2) ...
for gliderIndex=2:2
    
    % SET THE DEPLOYMENT NUMBER (1, 2 or 3) ...
    for deploymentNumber=1:1

        % glider name string...
        if (gliderIndex==1)
            strGliderName = 'Pelagia';
        else
            strGliderName = 'Ramses';
        end

        % deployment number string...
        strDeploymentNumber = num2str(deploymentNumber);

        % deployment start date string...
        strStartDate = strStart(gliderIndex, deploymentNumber);

        % deployment end date string...
        strEndDate = strEnd(gliderIndex, deploymentNumber);

        % define the path to the glider ascii files...
        ebddir = strcat('C:\Users\NewFolderSamsung\Desktop\scp\', strGliderName, filesep,'0', strDeploymentNumber,...
                         filesep, 'ebdasc', filesep);
        
        % define the path to the L1 CTD data (as the called program will
        % need to integrate optode data with processed CTD data)
        %L1_CTD_Dir = strcat('C:\Users\slockhar\Projects\LongBay\Data\Level1\', strGliderName, '\');
        L1_CTD_Dir = 'C:\Users\slockhar\Projects\Glider\DataMgmt\Output\mat\LongBay_2012\';
                     
        % define optode foil calibration coefficients
        % and oxygen bounds values by glider and deployment
        switch gliderIndex
            case 1 % Pelagia
                my_Delay_Secs = 27;         % Called program will delay CTD data by this amount before performing TSP correction
                switch deploymentNumber
                    case {1, 2} % Deployment 1 or 2;
                                % before foil replacement;
                                % 21 June 2004 calibration date;
                                % batch 2204
                        C0coef=[3.12899E+03,-1.05764E+02,2.06640E+00,-1.68983E-02];
                        C1coef=[-1.67671E+02,4.80582E+00,-8.73323E-02,6.61507E-04];
                        C2coef=[3.73685E+00,-8.78300E-02,1.47560E-03,-9.96701E-06];
                        C3coef=[-3.96052E-02,7.46930E-04,-1.17804E-05,6.677619E-08];
                        C4coef=[1.61999E-04,-2.37870E-06,3.63223E-08,-1.62194E-10];
                        oxyBounds = [50 2000];
                        satBounds = [50 2000];
                    case 3 % Deployment 3;
                           % replaced foil on 12 March 2012;
                           % 18 August 2010 calibration date;
                           % batch 1023
                        C0coef=[4.27019336E+03,-1.32723585E+02,2.15629751E+00,-1.40275831E-02];
                        C1coef=[-2.29729690E+02,5.74242078E+00,-6.85357898E-02,1.88612346E-04];
                        C2coef=[5.06401550E+00,-9.62084932E-02,5.22180779E-04,7.70889717E-06];
                        C3coef=[-5.26332308E-02,7.15467419E-04,3.31185072E-06,-1.86124024E-07];
                        C4coef=[2.10916841E-04,-1.84087896E-06,-4.28645540E-08,1.11120317E-09];
                        oxyBounds = [100 300];
                        satBounds = [20 140];                      
                end
            case 2 % Ramses all deployments;
                my_Delay_Secs = 27;         % Called program will delay CTD data by this amount before performing TSP correction
                % 2 June 2010 calibration date;
                % batch 5009
                C0coef=[4.53793e3 -1.62595e2 3.29574 -2.79285e-2];
                C1coef=[-2.50953e2 8.02322 -1.58398e-1 1.31141e-3];
                C2coef=[5.66417 -1.59647e-1 3.07910e-3 -2.46265e-5];
                C3coef=[-5.99449e-2 1.48326e-3 -2.82110e-5 2.15156e-7];
                C4coef=[2.43614e-4 -5.26759e-6 1.00064e-7 -7.14320e-10];
                oxyBounds = [10 250];
                satBounds = [20 100];
        end

        % Pack
        % myBounds
        myBounds = struct;
        myBounds.oxyBounds = oxyBounds;
        myBounds.satBounds = satBounds;
        % deploymentInfo
        deploymentInfo = struct;
        deploymentInfo.projectLabel = projectLabel;
        deploymentInfo.strDeploymentNumber = strDeploymentNumber;
        deploymentInfo.strStartDate = strStartDate;
        deploymentInfo.strEndDate = strEndDate;
        deploymentInfo.strGliderName = strGliderName;
        deploymentInfo.ebddir = ebddir;
        deploymentInfo.L1_CTD_Dir = L1_CTD_Dir;
        % Coefficients
        coefficient_Struct = struct;
        coefficient_Struct.C0coef = C0coef;
        coefficient_Struct.C1coef = C1coef;
        coefficient_Struct.C2coef = C2coef;
        coefficient_Struct.C3coef = C3coef;
        coefficient_Struct.C4coef = C4coef;
        % Call gliderCTD_Generate_L1_Data
        science = gliderOptode_Generate_L1_Data(deploymentInfo,myBounds,coefficient_Struct,my_Delay_Secs,timeBase_is_sensor_time,debug_Level);
    end
end