%
% CURL - Compute the CURL of a FEM 2-D vector field
%
%        CURL(fem_grid_struct,u,v) computes the curl of a 2-D 
%        vector field (u,v) (curl X (u,v)) over the FEM domain 
%        specified by fem_grid_struct.  The result is a 2-D 
%        scalar field containing the curl, returned to the workspace.
%
%        The computed quantity is:    crl=dv/dx - du/dy
%
%   INPUT : fem_grid_struct (from LOADGRID, see FEM_GRID_STRUCT)
%           u,v - u,v vector field
%
%  OUTPUT : crl - curl X (u,v)
%
%    CALL : crl=curl(fem_grid_struct,u,v);
%
%        ALL ARGUMENTS ARE REQUIRED.
%
% Written by : Brian O. Blanton
% Spring 1998
%
function crl=curl(fem_grid_struct,u,v)

if nargin ~=3 
   error('    CURL MUST (ONLY) HAVE 3 INPUT ARGUMENTS.');
end

if nargout~=1
   error('    CURL must have 1 (and only 1) output argument.')
end

if ~is_valid_struct(fem_grid_struct)
   error('    First argument to CURL must be a valid fem_grid_struct.')
end

crl=curlmex5(fem_grid_struct.x,...
             fem_grid_struct.y,...
	     fem_grid_struct.e,...
	     u,v);
%
%        Written by:
%        Brian O. Blanton
%        Dept. of Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
