%
% DRAWSTICK draw sticks for vectors, as opposed to arrows  
%
% DRAWSTICK routine to  draw vectors as sticks.
%           A line eminates from the vector
%           origins (xo,yo) with "large" dots at the origins.
%           No arrow heads are drawn.  Use VECPLOT for arrow heads.
%
%           This is a fairly low-level routine in that in does no scaling 
%           to the vectors.  This function is called primarily by STICKPLOT 
%           and returns the handle of the vector object drawn.
%
%           All Input arguments to DRAWSTICK are required.
%
%  Inputs:  x,y     - vector origins
%           u,v     - vector components
%           dotsize - vector origin size in points (a point is 1/72 inches; 
%                     the MATLAB default MarkerSize of 6 is approximately
%                     the size of a . (period))
%           color  - vector linecolor
%
% Outputs:  A 2-vector of handles to the sticks and dots drawn.
%           The first value is the handle to the dots, the second
%           a handle to the shafts.
%
% Call as: >> hp=drawstick(x,y,u,dotsize,color);
%
function hp=drawstick(x,y,u,v,dotsize,lcolor) 
 
% COLUMNATE INPUT
%
x=x(:);y=y(:);u=u(:);v=v(:);

% DRAW STICK ORIGINS AS DOTS
%
ht=line(x,y,'Marker','.','LineStyle','none','Color',lcolor,'Markersize',dotsize);
set(ht,'Tag','stickdots');

% COMPUTE SHAFT ENDS
%
xe = x + u;
ye = y + v;   
xe=xe(:);ye=ye(:); 
  
% BUILD PLOT MATRIX
%
xs=[x xe NaN*ones(size(x))]';
ys=[y ye NaN*ones(size(y))]';
xs=xs(:);
ys=ys(:);
hp=line(xs,ys,'LineStyle','-','Color',lcolor);
set(hp,'Tag','stickshafts');
hp=[ht(:);hp(:)];
%
%        Brian O. Blanton
%        Department of Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolna
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%


