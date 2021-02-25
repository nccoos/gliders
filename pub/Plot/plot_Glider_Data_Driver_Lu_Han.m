close all
clear all

addpath('../gliderproc/MATLAB/util');
addpath('../gliderproc/MATLAB/plots');
addpath('/Users/luhan/Documents/MATLAB/cre_matlab/oceans/');
addpath('/Users/luhan/Documents/MATLAB/cre_matlab/saga/')

%addpath('C:\Users\slockhar\Projects\Glider\DataMgmt\forPEACH\gliderproc\MATLAB\seawater');
%addpath('C:\Users\slockhar\Projects\LongBay\External\from_Chris_Calloway\gliderproc\MATLAB\plots');     % ccplot3
%addpath('C:\Users\slockhar\Projects\LongBay\External\from_Chris_Calloway\gliderproc\MATLAB\seawater');  % sw_pden
%addpath('C:\Users\slockhar\Projects\Glider\DataMgmt\forPEACH\gliderproc\MATLAB\strfun');
%addpath('C:\Users\slockhar\Projects\LongBay\Analysis\Mapping');
%addpath('C:\Users\slockhar\Projects\LongBay\Analysis\Common');



%target_Struct = load('C:\Users\slockhar\Projects\LongBay\Data\Level1\Ramses\Ramses_Deployment3_CTD_L1.mat');
%target_Struct = load('C:\Users\slockhar\Projects\Glider\DataMgmt\Output\mat\LongBay_2012\Ramses_Deployment1_CTD_L1');

dataset_Code = 'CTD';  % CTD or DO or ECO or FLIGHT
% Do any dataset-related xlat
switch dataset_Code
    case 'DO'
%         target_Struct = load('/Users/luhan/Documents/UNC2017/Data/Ramses/05:17/Ramses_Deployment1_DO_L1');
%         target_Struct = load('/Users/luhan/Documents/2017/Data/Ramses/05:17/Ramses_Deployment1_DO_L1.mat');
        target_Struct = load('/Users/luhan/Documents/2017/Data/Ramses/12:17/Ramses_Deployment3_DO_L1.mat');
        target_Struct.depth = target_Struct.depthi;
        target_Struct.gpsLat = target_Struct.gpsLati;
        target_Struct.gpsLon = target_Struct.gpsLoni;
        x = [];
    case 'ECO'
%         target_Struct = load('/Users/luhan/Documents/2017/Data/Ramses/05:17/Ramses_Deployment1_ECO_L1.mat');
        target_Struct = load('/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/gliders/pub/L1_Drivers/Angus_Deployment1_ECO_L1.mat');
        x = [];
    case 'CTD'
%         target_Struct = load('/Users/luhan/Documents/2017/Data/Ramses/05:17/Ramses_Deployment1_CTD_L1.mat');
        target_Struct = load('/Users/luhan/Documents/OneDrive - University of North Carolina at Chapel Hill/2017/Data_glider_l1/Modena_Deployment1_CTD_L1.mat');
        % x is in workspace if you just built CTD mat file
        if exist('x') ~= 1
            x = [];
        end
    case 'FLIGHT'
        target_Struct = load('/Users/luhan/Documents/2017/Data_glider_l1/Ramses/12_17/Ramses_Deployment3_Flight_L1.mat');
        x = [];
    otherwise
end
t_Min_String = target_Struct.config.start_date;
t_Max_String = target_Struct.config.end_date;


platform_Label = 'Salacia';
for i = 1:1
    plot_Glider_Data(target_Struct, t_Min_String, t_Max_String, platform_Label, dataset_Code, x);
end
