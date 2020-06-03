%
% DIVG - Compute the divergence of a FEM 2-D vector field
%
%        DIVG(e,x,y,u,v) computes the divergence of a 2-D 
%        vector field (u,v) over the FEM domain specified by the 
%        element list e and the corresponding horizontal node
%        coordinates (x,y).  The result is a 1-D scalar field
%        returned to the workspace. 
%
%        Call as: dv=divg(e,x,y,u,v);
%
%        All arguments are REQUIRED.
%
%        WRitten by::
%        Brian O. Blanton
%        Curr. in Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
function dv=divg(e,x,y,u,v)

if nargout~=1
   error('DIVG must have 1 (and only 1) output argument.')
else
   dv=divgmex5(x,y,e,u,v);
end
