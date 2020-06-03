%BELINT4 - compute shape function information for a FEM domain
%   BELINT4(E,X,Y) computes shape function information 
%   to be used in element finding (FINDELE).  BELINT4
%   returns nothing;  all results are stored in global 
%   variables and accessed as needed.
% Globals: A - elemental x-edge differences
%
% Call as:  >> belint4e,x,y);
%          
% Written by : Brian O. Blanton (October 95)
%
function belint4e,x,y)
clear global A B T A0
global A B T A0

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
   disp(' ');
   disp('??? Error using ==>> belint');
   disp(err5);
   error;
end

% COMPUTE GLOBAL DY
%
dy=[y(e(:,2))-y(e(:,3)) y(e(:,3))-y(e(:,1)) y(e(:,1))-y(e(:,2))];

% COMPUTE ELEMENTAL AREAS
%
AR=(x(e(:,1)).*dy(:,1)+x(e(:,2)).*dy(:,2)+x(e(:,3)).*dy(:,3))/2.;

% COMPUTE ARRAYS FOR ELEMENT FINDING (BELEL)
%
n1 = e(:,1);
n2 = e(:,2);
n3 = e(:,3);
A(:,1)=x(n3)-x(n2);
A(:,2)=x(n1)-x(n3);
A(:,3)=x(n2)-x(n1);
B(:,1)=y(n2)-y(n3);
B(:,2)=y(n3)-y(n1);
B(:,3)=y(n1)-y(n2);
A0(:,1)=.5*(x(n2).*y(n3)-x(n3).*y(n2));
A0(:,2)=.5*(x(n3).*y(n1)-x(n1).*y(n3));
T(:,1)=A0(:,1)*2;
T(:,2)=A0(:,2)*2;
T(:,3)=2*AR-T(:,1)-T(:,2);


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
