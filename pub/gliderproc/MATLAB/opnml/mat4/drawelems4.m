%DRAWELEMS4 draw FEM element configuration 
%   DRAWELEMS4 a routine to draw element boundries given an element,
%   node, and (optionally) bathymetry lists.  If no z-
%   coordinates are given, the mesh is drawn in 2-D.
%   Otherwise, the mesh is drawn in 3-D, with the view
%   perspective set to azimuth=-27 deg and 
%   elevation=30 deg.  See the MATLAB VIEW command for 
%   more on view points.
%
%     Input :
%             elems - a 3- or 4-column matrix giving the nodes comprising 
%                     each element.  If there are 3 columns, each line 
%                     should be "n1 n2 n3", a triangular element
%                     description.  If there are 4 columns, each line
%                     should be "n1 n2 n3 n4", a quadrilateral
%                     element description.
%             x     - an x-coord list of nodes;
%             y     - a  y-coord list of nodes; 
%             z     - a  z-coord list of nodes (optional);
%            
%             x,y,z must be 1-D vectors.
%           
%   Output :  DRAWELEMS returns the handle of the element object.
%
%             NOTES: 1) Element line-segments are drawn in solid white.
%                       This will be an optional argument in the future.
%                    2) Existing plots are added to.
%                    3) Axis limits are NOT set.  'axis('equal')' may
%                       need to be issued by the user, if it has not already.
%
%   Call as: >>  hel=drawelems4(elems,x,y,z);
%
% Written by: Brian O. Blanton
%                  
function hel=drawelems4(elems,x,y,z) 

% DEFINE ERROR STRINGS
err1=['matrix of elements must be 3 or 4 columns wide'];
err2=['more than 1 column in x-coordinate vector.'];
err3=['more than 1 column in y-coordinate vector.'];
err4=['more than 1 column in z-coordinate vector.'];
err6=['lengths of x & y must be equal'];
err7=['lengths of x, y, & z must be equal'];

% CHECK SIZE OF ELEMENT MATRIX
% NELEMS = NUMBER OF ELEMENTS, S = # OF COLS
%
[nelems,s]=size(elems);  
if s<3 | s>4
   error(err1);
elseif(s==4)
   elems=elems(:,2:4);
end

% COPY FIRST COLUMN TO LAST TO CLOSE ELEMENTS
%
elems=elems(:,[1 2 3 1]);
 
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

% CHECK SIZE OF Z-COORDINATE VECTOR
% NZ = NUMBER OF Z-COORDINATE VALUES, S = # OF COLS
%
if exist('z')
   [nz,s]=size(z);           
   if nz~=1&s~=1
      error(err4);
   end
% check lengths of x & z
   if nx~=nz
     error(err7);
   end
end

% MAKE SURE NUMBER OF NODES EQUALS THE MAX 
% NODE NUMBER FOUND IN ELEMENT MATRIX
% MAXNN = MAXIMUM NODE NUMBER IN ELEMENT MATRIX
%
maxnn=max(max(elems));
if maxnn~=length(x) | maxnn~=length(y)  
   disp('length of x, y, or z does not equal the')
   disp('max node number found in element list.');
   error;
end

elems=elems';
[m,n]=size(elems);
xt=x(elems);
yt=y(elems);
if n~=1 
   if m>n
      xt=reshape(xt,n,m);
      yt=reshape(yt,n,m);
   else
      xt=reshape(xt,m,n);
      yt=reshape(yt,m,n);
   end
   xt=[xt
       NaN*ones(size(1:length(xt)))];
   yt=[yt
       NaN*ones(size(1:length(yt)))];
end
xt=xt(:);
yt=yt(:);
%
% DRAW GRID
%
if exist('z')
   zt=z(elems);
   zt=reshape(zt,m,n);
   zt=[zt
       NaN*ones(size(1:length(zt)))];
   zt=zt(:);
   hel=line(xt,yt,zt,'Linewidth',.05,'LineStyle','-','Color',[.8 .8 .8]);
   %
   % SET 3-D VIEWPOINT
   %
   view(-27,30);
else
   hel=line(xt,yt,'Linewidth',.05,'LineStyle','-','Color',[.8 .8 .8]);
end
set(hel,'Tag','elements');
 
%
%        Brian O. Blanton
%        Curr. in Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@cuda.chem.unc.edu
%
