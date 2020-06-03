%ELLIPSE_EAST plot ellipse given center, major/minor axes, orientation, etc. 
%
% ELLIPSE_EAST plot ellipse given center, major and minor axes, 
%         orientation (CCW from EAST=0 radians, and color (optional, def = 'r')
%
%  Input : xc    - ellipse x-coordinate centers, usually node x's;
%          yc    - ellipse y-coordinate centers, usually node y's;
%          umaj  - major axis component
%          umin  - minor axis component
%          orien - orientation counterclockwise from east (radians)
%          col   - color to draw ellipses (optional, def = 'r')
% 
%          ELLIPSE_EAST plots ellipses centered at (xc,yc) with major
%          and minor axes (umaj,umin) at an orientation 
%          (orien) radians counterclockwise from east.  The first
%          five arguments are required; the color (col) is not and
%          defaults to red.
%
%  Output: ELLIPSE_EAST returns the handle to the ellipse object drawn.
%            
% Call as: hell=ellipse_east(xc,yc,umaj,umin,orien,col)
%
% Written by : Brian O. Blanton
% CRE - added npts as argument
%
function hell=ell_east(xc,yc,umaj,umin,orien,col,npts)

% DEFINE ERROR STRINGS
err1=['Too many input arguments. Type "help ELLIPSE_EAST"'];

if nargin == 5
   col='r';
elseif nargin>7
   error(err1);
end
if length(xc)~=length(yc) | length(xc)~=length(umaj) | ...
   length(umaj)~=length(umin) | length(umin)~=length(orien) 
   error('Length of xc,yc,umaj,umin,orien must be the same');
end

% compute non-rotated ellipses at (0,0)-origin
% force xc, yc, umaj, umin, orien  to be column vectors.
xc=xc(:); 
yc=yc(:);
umaj=umaj(:);
umin=umin(:);
orien=orien(:);

% t must be a row vector
delt=2*pi/npts;
t=0:delt:2*pi;
%t=-pi:delt:pi;
t=t(:)';

% compute non-rotated ellipses at (0,0)-origin
x=(umaj*ones(size(t)).*cos(ones(size(orien))*t))';
y=(umin*ones(size(t)).*sin(ones(size(orien))*t))';

% account for orientation
xn=x.*cos((orien*ones(size(t)))')-y.*sin((orien*ones(size(t)))');
yn=x.*sin((orien*ones(size(t)))')+y.*cos((orien*ones(size(t)))');
x=xn;
y=yn;
[nrow,ncol]=size(x);

% translate ellipses to input centers
xadd=(xc*ones(size(1:nrow)))';
yadd=(yc*ones(size(1:nrow)))';
x=x+xadd;
y=y+yadd;
x=[x;
   NaN*ones(size(1:ncol))];
y=[y;
   NaN*ones(size(1:ncol))];
x=x(:);
y=y(:);
hell=line(x,y,'Color',col);

% assign 'ellipse' string to 'UserData' parameter of hell
set(hell,'UserData','ellipse');
set(hell,'Tag','ellipse');

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
%
