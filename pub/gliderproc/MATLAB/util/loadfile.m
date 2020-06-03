% LOADFILE: Script for interactivally selecting and loading data files.
%           Just enter 'loadfile' at the command prompt and a browser
%           appears (using 'uigetfile') which allows you to select a file
%           to be loaded into the current workspace. Files with extension
%           .mat or no extension are treated as .mat-files, others are
%           assumed to be ascii files.
%
%           See LOAD and UIGETFILE for further information.

%           Olof Liungman, 970310.

[file,path] = uigetfile('*','Load file');

if isstr(file)
  eval(['load ',path,file])
end

clear path file                             
