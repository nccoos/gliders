function ineg=el_areas4(e,x,y)
%EL_AREAS4 - compute triangular finite element areas
%   EL_AREAS4(e,x,y) computes the areas for the elements 
%   defined by the element list (e) and the node coordinates
%   (x,y).  The areas are NOT returned to the workspace, but
%   instead are stored globally in AR.  An index of element
%   numbers whose areas are negative (if any) are returned.
%   Negative element areas indicate clockwise elemental
%   node numbering, instead of the conventional counter-
%   clockwise numbering.
%
% Call as:   >> ineg=el_areas4(e,x,y);
%
% Written by : Brian O. Blanton (October 95)
%

clear global AR 

% DEFINE ERROR STRINGS
err1=['matrix of elements must be 3 or 4 columns wide'];
err2=['more than 1 column in x-coordinate vector.'];
err3=['more than 1 column in y-coordinate vector.'];
err5=str2mat('length of x or y does not equal the',...
      'max node number found in element list.');
err6=['lengths of x & y must be equal'];

% CHECK SIZE OF ELEMENT MATRIX
% NELEMS = NUMBER OF ELEMENTS, S = # OF COLS
%
[ne,s]=size(e);  
if s<3 | s>4
   error(err1);
elseif(s==4)
   e=e(:,2:4);
end
% CHECK SIZE OF X-COORDINATE VECTOR
% NX = NUMBER OF X-COORDINATE VALUES, S = # OF COLS
%
[nx,s]=size(x);           
if nx~=1&s~=1
   error(err2);
end
 
% CHECK SIZE OF Y-COORDINATE VECTOR
% NY = NUMBER OF Y-COORDINATE VALUES, S = # OF COLS
%
[ny,s]=size(y);           
if ny~=1&s~=1
   error(err3);
end

% CHECK LENGTHS OF X & Y
%
if nx~=ny 
  error(err6);
end

% MAKE SURE NUMBER OF NODES EQUALS THE MAX 
% NODE NUMBER FOUND IN ELEMENT MATRIX
% MAXNN = MAXIMUM NODE NUMBER IN ELEMENT MATRIX
%
maxnn=max(max(e));
if maxnn~=length(x) | maxnn~=length(y)  
   error(err5);
end

% COMPUTE GLOBAL DY
%
dy=[y(e(:,2))-y(e(:,3)) y(e(:,3))-y(e(:,1)) y(e(:,1))-y(e(:,2))];

% COMPUTE ELEMENTAL AREAS
%
AR=(x(e(:,1)).*dy(:,1)+x(e(:,2)).*dy(:,2)+x(e(:,3)).*dy(:,3))/2.;

% ANY NEGATIVE OR ZERO AREAS ?
%
ineg=find(AR<=0);

global AR

%
%        Brian O. Blanton
%        Curriculum in Marine Sciences
%        Ocean Processes Numerical Modeling Laboratory
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%        October 1995
%
