%
% GRAD - Compute the gradient of a FEM 2-D scalar field
%
%        GRAD(e,x,y,s) computes the divergence of a 2-D 
%        scalar field (s) over the FEM domain specified by the 
%        element list (e) and the corresponding horizontal node
%        coordinates (x,y).  The result is a 2-D vector field
%        returned to the workspace. 
%
%        Call as: gd=grad(e,x,y,s);
%
%        All arguments are REQUIRED.
%
%        Written by:
%        Brian O. Blanton
%        Curr. in Marine Science
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
function gr=grad(e,x,y,q)

if nargout~=1
   error('GRAD must have 1 (and only 1) output argument.')
else
   [grdu grdv]=gradmex5(x,y,e,q);
   gr=[grdu(:) grdv(:)];
end
