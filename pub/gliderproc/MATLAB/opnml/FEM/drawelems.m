% DRAWELEMS draw 2-D FEM element configuration 
%
% DRAWELEMS draws element boundries given a valid grid structure.  
%
%  INPUT : fem_grid_struct - (from LOADGRID, see FEM_GRID_STRUCT)       
%           
% OUTPUT : hel - handle to the element object.
%
%   CALL : hel=drawelems(fem_grid_struct);
%
% Written by: Brian O. Blanton
% Summer 1997
%                  
function hel=drawelems(fem_grid_struct) 

% DEFINE ERROR STRINGS
err1=['Not enough input arguments; need a fem_grid_struct'];

% check arguments
if nargin ==0 
   error(err1);
end  

if ~is_valid_struct(fem_grid_struct)
   error('    Argument to DRAWELEMS must be a valid fem_grid_struct.')
end

% Extract grid fields from fem_grid_struct
%
elems=fem_grid_struct.e;
   % COPY FIRST COLUMN TO LAST TO CLOSE ELEMENTS
   %
   elems=elems(:,[1 2 3 1]);
x=fem_grid_struct.x;
y=fem_grid_struct.y;

elems=elems';
[m,n]=size(elems);
xt=x(elems);
yt=y(elems);
if n~=1 
   if m>n
      xt=reshape(xt,n,m);
      yt=reshape(yt,n,m);
   else
      xt=reshape(xt,m,n);
      yt=reshape(yt,m,n);
   end
   xt=[xt
       NaN*ones(size(1:length(xt)))];
   yt=[yt
       NaN*ones(size(1:length(yt)))];
end
xt=xt(:);
yt=yt(:);
%
% DRAW GRID
%
hel=line(xt,yt,'LineWidth',1,'LineStyle','-','Color',[.8 .8 .8]);
set(hel,'Tag','elements');
 
%
%        Brian O. Blanton
%        Curr. in Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@cuda.chem.unc.edu
%
%        Summer 1997
%
