%
% RANGE return the range (extent) of the input data x. 
%
% RANGE(x)  If x is a vector,
%           RANGE returns a scalar whose value is max(x)-min(x).
%           If x is a matrix, RANGE returns a vector 'retval' whose elements 
%           equal the range of each column in x. 
%
%           This is a trivial function which serves only to make code
%           look cleaner. 
%
% Call as: >> range(x)
%
%        Brian O. Blanton
%        Curr. in Marine Science
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%
function retval=range(x)
retval=max(x)-min(x);
