close all
clear all

addpath('../gliderproc/MATLAB/util');
addpath('../gliderproc/MATLAB/plots');
%addpath('C:\Users\slockhar\Projects\Glider\DataMgmt\forPEACH\gliderproc\MATLAB\seawater');
%addpath('C:\Users\slockhar\Projects\LongBay\External\from_Chris_Calloway\gliderproc\MATLAB\plots');     % ccplot3
%addpath('C:\Users\slockhar\Projects\LongBay\External\from_Chris_Calloway\gliderproc\MATLAB\seawater');  % sw_pden
%addpath('C:\Users\slockhar\Projects\Glider\DataMgmt\forPEACH\gliderproc\MATLAB\strfun');
%addpath('C:\Users\slockhar\Projects\LongBay\Analysis\Mapping');
%addpath('C:\Users\slockhar\Projects\LongBay\Analysis\Common');



%target_Struct = load('C:\Users\slockhar\Projects\LongBay\Data\Level1\Ramses\Ramses_Deployment3_CTD_L1.mat');
%target_Struct = load('C:\Users\slockhar\Projects\Glider\DataMgmt\Output\mat\LongBay_2012\Ramses_Deployment1_CTD_L1');

dataset_Code = 'ECO';  % CTD or DO or ECO or FLIGHT
% Do any dataset-related xlat
switch dataset_Code
    case 'DO'
%         target_Struct = load('/Users/luhan/Documents/UNC2017/Data/Ramses/05:17/Ramses_Deployment1_DO_L1');
        target_Struct = load('/Users/luhan/Documents/UNC2017/Data/Ramses/05:17/Ramses_Deployment1_DO_L1.mat');
        target_Struct.depth = target_Struct.depthi;
        target_Struct.gpsLat = target_Struct.gpsLati;
        target_Struct.gpsLon = target_Struct.gpsLoni;
        x = [];
    case 'ECO'
        target_Struct = load('/Users/luhan/Documents/UNC2017/Data/Ramses/05:17/Ramses_Deployment1_ECO_L1.mat');
        x = [];
    case 'CTD'
        target_Struct = load('/Users/luhan/Documents/UNC2017/Data/Ramses/05:17/Ramses_Deployment1_CTD_L1.mat');
        % x is in workspace if you just built CTD mat file
        if exist('x') ~= 1
            x = [];
        end
    case 'FLIGHT'
        target_Struct = load('/Users/luhan/Documents/UNC2017/Data/Ramses/09:17/Ramses_Deployment1_Flight_L1.mat');
        x = [];
    otherwise
end

% t_Min_String = {'17-May-2017 16::03:50','18-May-2017 20::30:10',...
%     '21-May-2017 00::38:15','23-May-2017 00::37:00','26-May-2017 00::37:40',...
%     '27-May-2017 12::36:20'};
% t_Max_String = {'17-May-2017 16::10:30','18-May-2017 20::46:30',...
%     '21-May-2017 00::45:00','23-May-2017 00::43:40','26-May-2017 00::43:00',...
%     '27-May-2017 12::43:50'};
% t_Min_String = '26-May-2017 19::03:00';
% t_Max_String = '26-May-2017 19::09:00';
% t_Min_String = '21-May-2017 9::07:00';
% t_Max_String = '21-May-2017 9::15:00';
t_Min_String = '1-May-2017 19::06:00';
t_Max_String = '31-May-2017 19::14:00';
% t_Min_String = '1-Sep-2017 12::35:40';
% t_Max_String = '31-Sep-2017 12::46:10';     
% t_Min_String = '13-Sep-2016 18:00:00';
% t_Max_String = '13-Sep-2016 19:00:00';
%{
t_Min_String = '23-Sep-2016 18::27:00';
t_Max_String = '23-Sep-2016 18::28:00';
%}
%{
t_Min_String = '22-Jan-2012 00::00:00';
t_Max_String = '05-Apr-2012 21::00:00';
%}

platform_Label = 'Ramses';
% for i = 1:6
    plot_Glider_Data(target_Struct, t_Min_String, t_Max_String, platform_Label, dataset_Code, x);
% end
