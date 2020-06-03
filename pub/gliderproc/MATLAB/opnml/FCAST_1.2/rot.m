function [ur,vr]=rot(u,v,theta)
%ROT Rotate vectors
% ROT rotates input vectors u,v by radian angle
% theta COUNTERCLOCKWISE, and returns the rotated
% vectors.
%
% Input: u,v   - series to rotate
%        theta - rotation angle (in radians)
%
% Output: ur,vr - rotated series
%
% Call as: [ur,vr]=rot(u,v,theta);
%

% Find not NaN's in data
temp=[u(:) v(:)];
idx=find(~isnan(sum(temp.')));




% Complexify input series
w=u(:)+i*v(:);

% Rotate vector
wr=w*exp(i*theta);

% extract rotated ur,vr
ur=real(wr);
vr=imag(wr);

%
%        Brian O. Blanton
%        Department of Marine Sciences
%        Ocean Processes Numerical Modeling Laboratory
%        12-7 Venable Hall
%        CB# 3300
%        University of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%        Spring  1999
%

