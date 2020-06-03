function outmat=sample_field_2d(fem_grid_struct,nx,ny,Q,box_coords)
%SAMPLE_FIELD_2D Mouse-driven 2-D FEM Field Sampler
%   SAMPLE_FIELD_2D is a mouse-driven 2-D field sampler prompts
%   the user to draw a box on the current figure, and 
%   returns an array of coordinates and interpolated 
%   field values.  The input field array can be any number
%   of columns wide (scalar, vector, etc.) but must be as
%   long as the node coordinate lists in fem_grid_struct.
%   I.e., the fields to interpolate will usually come from 
%   the FEM domain itself.
%
%  INPUT:  fem_grid_struct - FEM domain structure on which the field
%                   to sample is related (from LOADGRID, see FEM_GRID_STRUCT).
%          nx,ny  - number of points in the x and y direction at which to 
%                   sample the fields Q.  (REQUIRED, INTEGERS)
%          Q      - the fields to sample. This array must be the same length as 
%                   the node coordinate arrays in the valid fem_grid_struct
%                   passed in, but the number of columns is arbitrary.
%
%          box_coords - optional 4x1 vector defining the sample region.  
%                       The 4 values are [X1 Y1 X2 Y2], and if defined
%                       they take precedence over the mouse-driven facility.
%
% OUTPUT:  S      - an array containing the sample points and sample values.
%                   If nx or ny==1, then S contains the sample points and 
%                   sample values in columns.  Otherwise, S is an 
%                   [nx X ny X ncol] array, where ncol is the number of
%                   columns in the input array Q and the first 2 levels of
%                   S are the X and Y coordinates (X=S(:,:,1), Y=S(:,:,2)).
%                   Points not located within FEM domain are assigned NaN's 
%                   as field values.
% 
%                   To contour the results in the case where nx and ny > 1, 
%                   call MATLAB's contourf routine with S appropriately
%                   sampled.  For example:
%                   >> contourf(S(:,:,1),S(:,:,2),S(:,:,3))
%           
%   CALL: S=sample_field_2d(fem_grid_struct,nx,ny,Q)
%
% Written by Brian O. Blanton
% Summer 1998
%

% Process incoming arguments
if nargin~=4 & nargin~=5
   error('Incorrect number of argument to SAMPLE_FIELD_2D.');
end

% Make sure first argument is a valid fem_grid_struct
if ~is_valid_struct(fem_grid_struct)
   error('    fem_grid_struct to SAMPLE_FIELD_2D invalid.')
end

if (~isint(nx)|~isint(ny))&(nx~=0|ny~=0)
   error('2nd and 3rd arguments to SAMPLE_FIELD_2D MUST be non-0 integers.');
end

% 4th arg must me a vector with same length as fem_grid_struct.x
[nrow,ncol]=size(Q);
if nrow~=length(fem_grid_struct.x)
   error('Input field to SAMPLE_FIELD_2D MUST be same length as fem_grid_struct.x');
end

% An optional 5th argument must be 4x1 or 1x4
if nargin==5
   [m,n]=size(box_coords);
   if (m*n)~=4 
      error('Box_Coords must be 4x1 or 1x4 in SAMPLE_FIELD_2D.')
   end
   if m~=1&n~=1
      error('Box_Coords must be 4x1 or 1x4 in SAMPLE_FIELD_2D.')
   end
   % Further box coord checks??
end 
 
 
% Delete previously drawn objects grids
delete(findobj(gca,'Tag','Sample_Field_Box'))
delete(findobj(gca,'Tag','Sample_Field_Points'))

currfig=gcf;
figure(currfig);

% Get Grid dimensions
if ~exist('box_coords')
   disp('Click and drag mouse to define sample points');
   waitforbuttonpress;
   Pt1=get(gca,'CurrentPoint');
   rbbox([get(gcf,'CurrentPoint') 0 0],get(gcf,'CurrentPoint'));
   Pt2=get(gca,'CurrentPoint');
   curraxes=gca;
else
   Pt1=[box_coords(1) box_coords(2) NaN;
        box_coords(1) box_coords(2) NaN];
   Pt2=[box_coords(3) box_coords(4) NaN;
        box_coords(3) box_coords(4) NaN];
end
 
% Draw box around sampling grid
line([Pt1(1) Pt2(1) Pt2(1) Pt1(1) Pt1(1)],...
     [Pt1(3) Pt1(3) Pt2(3) Pt2(3) Pt1(3)],'Tag','Sample_Field_Box')
     
xstart=Pt1(1);
ystart=Pt1(3);
xend=Pt2(1);
yend=Pt2(3);

% If nx or ny==1, then the output is a diagonal line
% from (xstart,ystart) to (xend,yend)

if nx==1 | ny==1
   n=max(nx,ny);
   X=linspace(xstart,xend,n);
   Y=linspace(ystart,yend,n);
else
   x=linspace(xstart,xend,nx);
   y=linspace(ystart,yend,ny);
   X=x(:)*(ones(size(y(:)')));
   X=X';
   Y=y(:)*(ones(size(x(:)')));
end
 
line(X,Y,'Marker','.','MarkerSize',14,'Color','r',...
         'LineStyle','none','Tag','Sample_Field_Points')

% Call interp_scalar to do the work; once for each column of Q
S=NaN*ones(length(X(:)),ncol);
for i=1:ncol
   S(:,i)=interp_scalar(fem_grid_struct,Q(:,i),X(:),Y(:));
end

if nx==1 | ny==1
   outmat=[X(:) Y(:) S];
else
   outmat=NaN*ones(ny,nx,ncol);
   outmat(:,:,1)=X;
   outmat(:,:,2)=Y;
   outmat(:,:,3:ncol+2)=reshape(S,ny,nx,ncol);
end  
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
%        Summer 1998
