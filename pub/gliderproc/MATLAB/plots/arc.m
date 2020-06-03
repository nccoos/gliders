function z=arc(z0,r,n,a1,a2)
%function z=arc(z0,r,n,a1,a2)   create arc with center z0, radius r
%Arc of a circle with center z0, radius r and angle going from
%  a1 to a2 in radians.  n is the number of points on the arc returned.
%Example: axis('square')
%         plot(arc(i,.5,25,pi/4,pi/2))
%
% Calls: none
t=a1:(a2-a1)/n:a2;
z=z0+r*exp(i*t);
