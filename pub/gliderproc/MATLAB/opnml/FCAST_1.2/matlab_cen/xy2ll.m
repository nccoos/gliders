function [lat,lon]=xy2ll(x,y,reflat,reflon)

% [LAT,LON]=XY2LLGOM(X,Y,REFLAT,REFLON)
%
% Returns vectors of latitudes and longitudes, LAT and LON, 
% for X and Y vectors (as distance in meters from arbitrary 
% origin REFLAT and REFLON).  Uses a Newton-Raphson Method
% to calculate latitude.  In situations where one or more
% values do not converge, that location is assigned the value
% NaN and a warning is issued.
%
% REFLAT and REFLON default to Boston
%
% X and Y may be specified as X+i*Y
%
% Specifying only a single output yields LON+i*LAT

% CVL, 7-10-97
% Hacked from mercgom2 from C. Naimie.

if nargin<3
	reflon=-71.03*pi/180;
	reflat=42.35*pi/180;
end

if nargin==1
	y=imag(x);
	x=real(x);
end

r=6.3675e+6;
xo=r*cos(reflat)*reflon;
yo=r*cos(reflat)*log((1.0+sin(reflat))/cos(reflat));

rlon=(x+xo)/(r*cos(reflat));

y=y+yo;

tol=0.0001;
n=1000;

po=reflat*ones(size(x));
for in=1:n
	p1=po-((1.0+sin(po))./cos(po)-exp(y./(r*cos(reflat))))...
		./((1.0+sin(po))./(cos(po).^2.0));
	if max(abs(p1-po))<tol
		break
	end
	po=p1;
end

if in==n
	in=find(max(abs(p1-po))<tol);
	p1(in)=NaN*p1(in);
	rlon(in)=NaN*rlon(in);
	disp('Did not converge after 1000 iterations, some values NaN')
end

rlat=p1;
lon=rlon*180/pi;
lat=rlat*180/pi;

if nargout<=1
	lat=lon+i*lat;
end
