% Make sure dbd2asc is in your windows/dos path

% This program converts the Dinkum binary data *.EBD (in the specified
% input data folder) to the ascii files *.ebdasc (in the specified output
% data folder).


clear all;

% Addpaths
addpath('../gliderproc/MATLAB/util');
addpath('../gliderproc/MATLAB/matutil');
addpath('../gliderproc/MATLAB/plots');
addpath('../gliderproc/MATLAB/strfun');


%% USER INPUT
% Specify input folders where raw Dinkum binary data are stored 
flight_Folder =  'C:\Users\slockhar\Projects\Glider\GliderFiles\SECOORA_2016\Ramses\history\All\EndOfMissionSecoora2016\flight\';
science_Folder = 'C:\Users\slockhar\Projects\Glider\GliderFiles\SECOORA_2016\Ramses\history\All\EndOfMissionSecoora2016\science\';

% Specify input folders for dbd, ebd, and related cache files
dbd_Folder = strcat(flight_Folder,'LOGS\');
ebd_Folder = strcat(science_Folder,'LOGS\');
dbd_Cache_Folder = strcat(flight_Folder,'STATE\CACHE\');
ebd_Cache_Folder = strcat(science_Folder,'STATE\CACHE\');

% Spcify folders for copies. These folders need to be created.
dbd_Copy_Folder =       'C:\Users\slockhar\Projects\Glider\GliderFiles\SECOORA_2016\Ramses\history\All\EndOfMissionSecoora2016\flightCopy\';
ebd_Copy_Folder =       'C:\Users\slockhar\Projects\Glider\GliderFiles\SECOORA_2016\Ramses\history\All\EndOfMissionSecoora2016\scienceCopy\';
dbd_Cache_Copy_Folder = 'C:\Users\slockhar\Projects\Glider\GliderFiles\SECOORA_2016\Ramses\history\All\EndOfMissionSecoora2016\flightCopy\cache\';
ebd_Cache_Copy_Folder = 'C:\Users\slockhar\Projects\Glider\GliderFiles\SECOORA_2016\Ramses\history\All\EndOfMissionSecoora2016\scienceCopy\cache\';

% Specify output folders (dbdasc, ebdasc). These folders need to be created.
dbdasc_Folder = 'C:\Users\slockhar\Projects\Glider\GliderFiles\SECOORA_2016\Ramses\history\All\EndOfMissionSecoora2016\dbdasc\';
ebdasc_Folder = 'C:\Users\slockhar\Projects\Glider\GliderFiles\SECOORA_2016\Ramses\history\All\EndOfMissionSecoora2016\ebdasc\';


%% COPY EBDCACHE FILES
[files, Dstruct] = wilddir(ebd_Cache_Folder, '.CAC');
nfile = size(files, 1)

% Copy ebd cache
for i=1:nfile
    ebd_Cache_Fullpath = strcat(ebd_Cache_Folder, files(i,:));
    ebd_Cache_Copy_Fullpath = strcat(ebd_Cache_Copy_Folder, files(i,:));
    copyfile(ebd_Cache_Fullpath,ebd_Cache_Copy_Fullpath);
end


%% PROCESS EBD
[files, Dstruct] = wilddir(ebd_Folder, '.EBD');
nfile = size(files, 1)

% Copy flight files
for i=1:nfile
    ebd_Fullpath = strcat(ebd_Folder, files(i,:));
    ebd_Copy_Fullpath = strcat(ebd_Copy_Folder, files(i,:));
    copyfile(ebd_Fullpath,ebd_Copy_Fullpath);
end

% Create ebdasc
cd(ebd_Copy_Folder)          % dbd2asc requires you to be here
for i=1:nfile
    ebd_Filename = files(i,:);
    ebdasc_Filename = lower(strcat(files(i,:),'ASC'));
    ebdasc_Fullpath = strcat(ebdasc_Folder,ebdasc_Filename);
    dos_String = sprintf('%s %s %s %s','dbd2asc',ebd_Filename,'>',ebdasc_Filename);
    dos(dos_String);
end

%%


