function [tout,rout] = rosescale(theta,x,scaleradius)
%ROSESCALE   Angle distribution plot.
%   
%   Same as ROSE but adds scale for radius if distribution 
%   (or some other manipulation) is preferred over count
%
%   See also ROSE, HIST, POLAR, COMPASS.

%   Altered from orig ROSE by Catherine Edwards
%
%   Clay M. Thompson 7-9-91
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.14 $  $Date: 2002/06/05 20:05:16 $

if isstr(theta)
        error('Input arguments must be numeric.');
end
theta = rem(rem(theta,2*pi)+2*pi,2*pi); % Make sure 0 <= theta <= 2*pi
if nargin==1,
  x = (0:19)*pi/10+pi/20;
  scaleradius=1;
elseif nargin==2,
   scaleradius=1;

elseif nargin>=2,
  if isstr(x)
        error('Input arguments must be numeric.');
  end
  if length(x)==1,
    x = (0:x-1)*2*pi/x + pi/x;
  else
    x = sort(rem(x(:)',2*pi));
  end
elseif nargin==3,
  if isstr(scaleradius)
        error('Input arguments must be numeric.');
  end 
end
if isstr(x) | isstr(theta)
        error('Input arguments must be numeric.');
end

% Determine bin edges and get histogram
edges = sort(rem([(x(2:end)+x(1:end-1))/2 (x(end)+x(1)+2*pi)/2],2*pi));
edges = [edges edges(1)+2*pi];
nn = histc(rem(theta+2*pi-edges(1),2*pi),edges-edges(1));
nn(end-1) = nn(end-1)+nn(end);
nn(end) = [];

% Form radius values for histogram triangle
if min(size(nn))==1, % Vector
  nn = nn(:); 
end
[m,n] = size(nn);
mm = 4*m;
r = zeros(mm,n);
r(2:4:mm,:) = nn;
r(3:4:mm,:) = nn;

% Form theta values for histogram triangle from triangle centers (xx)
zz = edges;

t = zeros(mm,1);
t(2:4:mm) = zz(1:m);
t(3:4:mm) = zz(2:m+1);

if nargout<2
  h = polar(t,r*scaleradius);
  if nargout==1, tout = h; end
  return
end

if min(size(nn))==1,
  tout = t'; rout = r'*scaleradius;
else
  tout = t; rout = r*scaleradius;
end


