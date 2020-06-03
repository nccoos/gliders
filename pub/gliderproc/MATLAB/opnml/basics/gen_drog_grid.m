function outmat=gen_drog_grid(nx,ny,nlev,z,box_coords)
%GEN_DROG_GRID Mouse-driven drogue input coordinate generator
%
% GEN_DROG_GRID - Mouse-driven drogue input coordinate generator prompts
%                 the user to draw a box on the current figure, and returns
%                 an array of coordinates suitable for a drogue
%                 initialization file.
%
%  INPUT:  nx,ny  - number of drogues in the x and y direction (REQUIRED, 
%                   INTEGERS).  If nx or ny==1, then the output is a 
%                   diagonal line from between starting and ending points.
%          nlev   - number of vertical levels to duplicate the 
%                   horizontal positions (OPTIONAL, DEFAULT=1, INTEGER)
%                   If nlev is given, then so must z.
%          z      - the depth to assign to the horizontal drogue
%                   locations.  z must be of length 1:nlev, providing
%                   one depth for each horizontal level.  (OPTIONAL, FLOAT)
%                   In this version, z must be a single
%                   number.  It will be used as the depth for the (nx*ny)
%                   horizontal locations. 
%
%          box_coords - optional 4x1 vector defining the sample region.  
%                       The 4 values are [X1 Y1 X2 Y2], and if defined
%                       they take precedence over the mouse-driven facility.
%
% OUTPUT:  outmat - if z is supplied as input, outmat is a (nx*ny) by 3 
%                   array of 3-D starting locations
%                   if z is NOT supplied as input, outmat is a (nx*ny) by 2
%                   array of 2-D starting locations
%
% Call as: outmat=gen_drog_grid(nx,ny)
%      OR: outmat=gen_drog_grid(nx,ny,z)
%      OR: outmat=gen_drog_grid(nx,ny,nlev,z)
%      OR: outmat=gen_drog_grid(nx,ny,nlev,z,box_coords)
%
% Written by :Brian O. Blanton
% Summer 1998
%

% Process incoming arguments
if nargin<2|nargin>5
      error('Incorrect number of argument!. "help gen_drog_grid"!');
elseif nargin==2
   if (~isint(nx)|~isint(ny))&(nx~=0|ny~=0)
      error('First two arguments must be non-0 integers. "help gen_drog_grid"!');
   end
   z=[];;
   nlev=[];
elseif nargin==3
   if (~isint(nx)|~isint(ny))&(nx~=0|ny~=0)
      error('First two arguments MUST be non-0 integers. "help gen_drog_grid"!');
   end
   % if arg==3, assume third is depth
   z=nlev;
   nlev=1;
elseif nargin==4
   if (~isint(nx)|~isint(ny))&(nx~=0|ny~=0)
      error('First two arguments MUST be non-0 integers. "help gen_drog_grid"!');
   end
   % if arg==4, assume third is nlev, check for integer, as length of z==nlev
   if ~isint(nlev)
      error('Number of vertical levels MUST be integer. "help gen_drog_grid"!');
   end
   if length(z)~=nlev
      error('Length of z MUST equal nlev.  "help gen_drog_grid"!');
   end
elseif nargout~=1
   error('gen_drog_grid MUST have one output argument')
end

% if 5th arg exists, must be 1x4 or 4x1
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

% Delete previously drawn drog grids
delete(findobj(gca,'Tag','Gen Drog Grid Box'))
delete(findobj(gca,'Tag','Gen Drog Grid Points'))

currfig=gcf;
figure(currfig);

% Get Grid dimensions
if ~exist('box_coords')
   disp('Click and drag mouse to cover drog patch (lower-left to upper-right)');
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

% Draw box around drogue grid
line([Pt1(1) Pt2(1) Pt2(1) Pt1(1) Pt1(1)],...
     [Pt1(3) Pt1(3) Pt2(3) Pt2(3) Pt1(3)],'Tag','Gen Drog Grid Box')
     
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
 
line(X,Y,'Marker','*','LineStyle','none','Tag','Gen Drog Grid Points')

if isempty(z)
   X=X(:);Y=Y(:);
   outmat=[X Y];
else
   X=X(:)*ones(size(1:nlev));
   Y=Y(:)*ones(size(1:nlev));
   Z=ones(size(Y));
   temp=z'*zeros(size(z));
   temp(:,1)=z';
   Z=Z*temp';
   outmat=[X(:) Y(:) Z(:)];
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
 
