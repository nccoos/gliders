function l=isvector(v)
% function l=isvector(v)
%
% is the argument a vector (a matrix with only one non-singular dimension)
%
% input  :	v		: matrix
%
% output :	l		: 1 if v is a vector
%				  0 if v is not a vector
%
% version 1.0.0		last change 10.08.2000

% Gerd Krahmann, LDEO, Aug 2000

if length(find(size(v)>1))>1
  l = 0;
else
  l = 1;
end
