% GRIDINFO - display info about fem_grid_struct
%
%            GRIDINFO(fem_grid_struct) displays information
%            about the grid structure pointed to by the
%            input argument fem_grid_struct.  GRIDINFO lists
%            each field and the size of its contents.  This function
%            amounts to typing WHOS on a valid structure.
%
%            GRIDINFO, with no input argument, checks to see 
%            if the global DOMAIN has been set.  If so, it 
%            describes the fem_grid_struct pointed to by DOMAIN.
%
%     CALL - GRIDINFO(fem_grid_struct)
%            GRIDINFO
%
% SEE ALSO - FEM_GRID_STRUCT
%            
%
% Written by : Brian O. Blanton
% Summer 1997
%
function gridinfo(fem_grid_struct)


% make sure this is atleast MATLAB version 5.0.0
%
vers=version;
if vers(1)<5
   disp('??? Error using ==>> GRIDINFO ');
   disp('GRIDINFO REQUIRES!! MATLAB version 5.0.0 or later.');
   disp('Sorry, but this is terminal.');
   return
end 

fem_grid_struct

disp(['Min,Max x= ' num2str(min(fem_grid_struct.x)) ' '   num2str(max(fem_grid_struct.x))])
disp(['Min,Max y = ' num2str(min(fem_grid_struct.y)) ' ' num2str(max(fem_grid_struct.y))])
disp(['Min,Max z = ' num2str(min(fem_grid_struct.z)) ' ' num2str(max(fem_grid_struct.z))])

%
%        Brian O. Blanton
%        Curriculum in Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        University of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%        Summer 1997
%

