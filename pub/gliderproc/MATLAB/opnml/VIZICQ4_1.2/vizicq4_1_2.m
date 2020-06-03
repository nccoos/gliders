%VIZICQ4 Visualization GUI for QUODDY4 hot-start files.
%   VIZICQ4 is an interactive MATLAB program to help 
%   quickly visualize a hot-start file output from QUODDY4.
%   Horizontal and vertical slices can be computed on (almost)
%   any of the variables defined in the .icq4 standard.
%
%   VIZICQ4 can take two input arguments on startup;
%     1) the gridname defining the domain on which 
%        the .icq4 file was computed.  This is the name
%        of the domain.
%     2) the name, including the absolute or relative path,
%        to the .icq4 file under consideration.  This is
%        is the NAME of the file, not the fem_icq4_struct
%        itself. 
%
%   This is version 1.2
%
% CALL as: >> vizicq4
%    or    >> vizicq4(gridname)
%    or    >> vizicq4(gridname,icq4name)
%
% Written by: 
%         Brian O. Blanton
%         Department of Marine Sciences
%         Ocean Processes Numerical Modeling Laboratory
%         15-1A Venable Hall
%         CB# 3300
%         Uni. of North Carolina
%         Chapel Hill, NC
%                  27599-3300
% 
%         919-962-4466
%         blanton@marine.unc.edu
% 
%         Version 1.2 (M5.2.0) April 1999
%
function retval=vizicq4(gridname,icq4name)

% make sure this is atleast MATLAB version 5.2.0
%
vers=version;
vers=vers(1:5);
if sum(vers<'5.2.0') 
   disp(' ');
   disp('VIZICQ4_1.2 REQUIRES MATLAB version 5.2 or later.');
   return
end


% Check for other instances of VIZICQ4
VIZICQ4_Figure=findobj(0,'Type','figure','Tag','VIZICQ4_Figure');
if ~isempty(VIZICQ4_Figure)
   VIZICQ4_Slicer_Fig=findobj(0,'Type','figure','Tag','VIZICQ4_Slicer_Fig');
   VIZICQ4_Icq4_Info_Fig=findobj(0,'Type','figure','Tag','VIZICQ4_Icq4_Info_Fig');
   delete([VIZICQ4_Figure VIZICQ4_Slicer_Fig VIZICQ4_Icq4_Info_Fig])
end
 
%if ~isempty(VIZICQ4_Figure)
%   disp('Two instances of VIZICQ4 cannot run under the')
%   disp('same instance of MATLAB.')
%   return
%end


% This function sets up VIZICQ4, and verifies arguments on the 
% first call.  The guts of VIZICQ4 are in the private function 
% vizicq4_guts.m

nargchk(0,2,nargin);

if nargin==0
   gridname=[];
   icq4name=[];
else
   % check first arg to make sure it's a fem_grid_struct
   if ~isstr(gridname)
      error('First argument to VIZICQ4 must be a gridname (string)')
   end   
end

% if narg==2
if nargin==2
   if ~isstr(icq4name)
     error('    Second argument to VIZICQ4 must be a string.')
   end
   option='no opt';
   [fpath,fname,fext,fver] = fileparts(icq4name);
   if ~strcmp(fext,'.icq4')
      error('icq4name passed to VIZICQ4 does not end in ''.icq4''')
   end
   if ~exist(icq4name)
      disp('.icq4 file passed to VIZICQ4 does not exist.')
      % Find out why
      % Check path existence
      if ~isempty(fpath)
         if exist(fpath)~=7
	    disp([fpath ' not a directory'])
	 end
      end
      if ~isempty(fname)
         if exist(fname)~=2
	    disp([fname ' not a file'])
	 end
      end 
   end
else
   icq4name=[];
end


% Check for the existence of map_scalar_mex5.mex<arch>
global MAP_SCALAR_EXIST
if ~(exist('map_scalar_mex5')==3)
   disp('The mapping function map_scalar_mex5 cannot be located.')
   disp('The volume section is disabled.  To compile the mex file')
   disp('map_scalar_mex5.c, cd in MATLAB to the VIZICQ4_1.2 directory')
   disp('and type "mex map_scalar_mex5.c".  You will then need to ')
   disp('restart MATLAB.')
   MAP_SCALAR_EXIST=0;
else
   MAP_SCALAR_EXIST=1;
end

% At this point, input arguments are valid, and time
% to set up the VIZICQ4 GUI.  We will not return to this
% function; 
disp('building vizicq4 gui')
vizicq4_gui;
get_VIZICQ4_handles;

if ~isempty(gridname)
   set(VIZICQ4_Current_Domain,'String',gridname)
   vizicq4_guts('Load_Grid')
end

if ~isempty(icq4name)
   set(VIZICQ4_Current_Icq4_Name,'String',icq4name)
   vizicq4_guts('Load_Icq4','Name')
end

% Last, set Info line if MAP_SCALAR_EXIST==0
