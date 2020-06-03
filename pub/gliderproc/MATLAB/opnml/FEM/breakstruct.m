function [e,x,y,z,b]=breakstruct(fem_grid_struct)
% BREAKSTRUCT - split fem_grid_struct into separate components
% 
%               BREAKSTRUCT returns the basic FEM domain arrays
%               to the calling workspace by breaking down the 
%               input fem_grid_struct.
%              
%               All arguments are required.
% 
%  INPUT : fem_grid_struct - (from LOADGRID, see FEM_GRID_STRUCT) 
%
% OUTPUT : e  - node connectivity list (triangular) 
%          x  - x-horizontal node coordinates      
%          y  - y-horizontal node coordinates      
%          z  - bathymetry list                    
%          b  - boundary segment list            
%
%   CALL : >> [e,x,y,z,b]=breakstruct(fem_grid_struct);
%


if ~is_valid_struct(fem_grid_struct)
   error('    Argument to BREAKSTRUCT must be a valid fem_grid_struct.')
end

e=fem_grid_struct.e;
x=fem_grid_struct.x;
y=fem_grid_struct.y;
z=fem_grid_struct.z;
b=fem_grid_struct.bnd;


