%
% OPNMLINIT a setup file for OPNML matlab directories and datafiles.
%
%           OPNMLINIT is a script that adds paths and variables to
%           the local workspace so that matlab functions written for
%           finite element work can be accessed.
% 
%           At the matlab command line prompt, type 'opnmlinit'.
%
%           Brian O. Blanton
%           Dept. in Marine Science
%           15-1A Venable Hall
%           CB# 3300
%           Uni. of North Carolina
%           Chapel Hill, NC
%                    27599-3300
%
%           919-962-4466
%           blanton@marine.unc.edu
%
disp(' ');
disp('Type "help opnml" for a list of routines written for ');
disp('finite element related applications.');
disp(' ');

set(0,'DefaultAxesBox','on')

global OPNML
OPNML='C:\MATLAB6p1\toolbox\opnml';

% adding local paths to MATLABPATH ... 
%
disp('adding local toolboxes (OPNML/FEDAR) to MATLABPATH ... ');
addpath([eval('OPNML') '\FDCONT'],'-end') 
addpath([eval('OPNML') '\FEM'],'-end') 
addpath([eval('OPNML') '\IO_Functions'],'-end') 
addpath([eval('OPNML') '\MEX'],'-end') 
addpath([eval('OPNML') '\basics'],'-end') 
addpath([eval('OPNML') '\mat4'],'-end') 

%add_grid_database;
griddb;
