%COLORMESH2D draw a FEM mesh in 2-d colored by a scalar quantity.
%
%   INPUT : fem_grid_struct (from LOADGRID, see FEM_GRID_STRUCT)
%	    Q	      - scalar to color with (optional)
%	    nband     - number of contour bands to compute (optional)
%
%	    With no scalar specified to contour, COLORMESH2D
%	    defaults to the bathymetry fem_grid_struct.z
%
%  OUTPUT : hp - vector of handles, one for each element patch drawn.
%
%   COLORMESH2D colors the mesh using the scalar Q.  If Q
%   is omitted from the argument list, COLORMESH2D draws
%   the element connectivity in black and white.
%
% NOTE: This is one of the few (2 or 3) OPNML MATLAB functions that 
%       deletes existing patch objects in  the current axes before 
%       rendering the surface.  This is to avoid having an unmanageable 
%       number of patch objects on the screen.  
%
%   CALL : >> hp=colormesh2d(fem_grid_struct,Q,nband)
%
% Written by : Brian O. Blanton
%
function rv1=colormesh2d(fem_grid_struct,Q,nband)

nargchk(1,3,nargin);

% VERIFY INCOMING STRUCTURE
%
if ~isstruct(fem_grid_struct)
   error('First argument to COLORMESH2D must be a structure.')
end
if ~is_valid_struct(fem_grid_struct)
   error('fem_grid_struct to COLORMESH2D invalid.')
end
 
e=fem_grid_struct.e;
x=fem_grid_struct.x;
y=fem_grid_struct.y;

% DETERMINE SCALAR TO CONTOUR
%
if ~exist('Q')
  Q=fem_grid_struct.z;
  nband=16;
elseif ischar(Q)
  if strcmp(lower(Q),'z')
    Q=fem_grid_struct.z;            % Default to bathymetry
  else
     error('Second arg to COLORMESH2D must be ''z'' for depth')
  end
  nband=16;
elseif length(Q)==1
  % nband pass in as Q
  nband=Q;
  Q=fem_grid_struct.z;
else
   % columnate Q
   Q=Q(:);
   [nrowQ,ncolQ]=size(Q);
   if nrowQ ~= length(x)
      error('scalar used to color must be 1-D');
   end 
   if nargin==2,nband=16;,end
end

if nargin==3
   if length(nband)>1
      error('nband argument to COLORMESH2D must be 1 integer')
   end
end


                     
[nrowQ,ncolQ]=size(Q);
if ncolQ>1,error(err4);,end
if nrowQ ~= length(x)
   error('length of scalar must be the same length as coordinate vectors')

end
Q=Q(:);

[nelems,ncol]=size(e);   % nelems,ncol = number of elements, columns

e=e';
[m,n]=size(e);
xt=x(e);
xt=reshape(xt,m,n);
yt=y(e);
yt=reshape(yt,m,n);
Qt=Q(e);
Qt=reshape(Qt,m,n);

% delete previous colorsurf objects
%delete(findobj(gca,'Type','patch','Tag','colorsurf'))

hp=patch(xt,yt,Qt,'EdgeColor','interp',...
         'FaceColor','interp','Tag','colorsurf');
%colormap(jet(nband))

% Output if requested.
if nargout==1,rv1=hp;,end

%
%        Brian O. Blanton
%        Department of Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu

 
