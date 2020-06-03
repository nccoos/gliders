% WHICH_ELEM determine bounding finite element in given domain
%    WHICH_ELEM finds the element number for the
%    current mouse position.  WHICH_ELEM prompts
%    the user to click on the current axes and returns
%    the element for the "click-on" position, or NaN
%    if the click is outside the domain.
%
%    Alternatively, a list of horizontal points can
%    be passed in and a list of element numbers, one for
%    each input point will be returned.
%
%    In determining which element has been selected,
%    WHICH_ELEM needs elemental areas and shape functions.
%    The routines BELINT and EL_AREAS compute these arrays
%    and add them to a previously created fem_grid_struct.
%    These two functions MUST be run before WHICH_ELEM will
%    run.
%    BELINT is run as:
%      >> new_struct=belint(fem_grid_struct); 
%    EL_AREAS is run as:
%      >> [new_struct,ineg]=el_areas(fem_grid_struct); 
%
%  INPUT : fem_grid_struct - (from LOADGRID, see FEM_GRID_STRUCT)     
%          xylist          - points to find elements for [n x 2 double] 
%           
% OUTPUT : an element number(s)
% 
%   CALL : >> j=which_elem(fem_grid_struct)   for interactive
%    or
%          >> j=which_elem(fem_grid_struct,xylist)        
%
% Written by : Brian O. Blanton 
% Summer 1997
%

function j=which_elem(fem_grid_struct,xylist)

% VERIFY INCOMING STRUCTURE
%
if ~is_valid_struct(fem_grid_struct)
   error('    fem_grid_struct to WHICH_ELEM invalid(1).')
end

% Make sure additional needed fields of the fem_grid_struct
% have been filled.
if ~is_valid_struct2(fem_grid_struct)
   error('fem_grid_struct to WHICH_ELEM invalid.')
end

if exist('xylist')
   xp=xylist(:,1);
   yp=xylist(:,2);
   line(xp,yp,'LineStyle','none','Marker','+')
else
   disp('Click on element ...');
   waitforbuttonpress;
   Pt=gcp;
   xp=Pt(2);yp=Pt(4);
   line(xp,yp,'LineStyle','none','Marker','+')

end
j=findelemex5(xp,yp,fem_grid_struct.ar,...
                    fem_grid_struct.A,...
                    fem_grid_struct.B,...
                    fem_grid_struct.T);

%
%        Brian O. Blanton
%        Department of Marine Sciences
%        Ocean Processes Numerical Modeling Laboratory
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%        Summer 1997
%

