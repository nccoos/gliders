function [re,rx,ry,rz,rbnd,perm]=reduce(e,x,y,z,b)
% REDUCE compute a bandwidth-reduced FEM domain connectivity list
%
%        REDUCE reduces the bandwidth of a FEM element list
%        using the symmetric reverse Cuthill-McKee bandwidth reduction 
%        algorithm.  It employs the MATLAB routine SYMRCM to perform 
%        the reordering and then permutes the remaining input arguments 
%        according to the new node numbering. 
%
%  INPUT: e        -  element list; 3 (.tri) or 4 (.ele) columns wide (REQ)
%         x,y,z    -  nodal coordinate lists (OPT)
%
% OUTPUT: re       -  reordered element list (REQ)
%         rx,ry,rz -  reordered nodal coordinates (OPT)
%         rb       -  reordered boundary segment list (OPT)
%         perm     -  permutation list (REQ)
%
%   CALL: REDUCE requires one of the following calling formats:
%         1) [re,perm]=reduce(e);
%         2) [re,rx,ry,rz,rbnd,perm]=reduce(e,x,y,z);
%
% Written by : Brian O. Blanton 
%              October 1995
%

% DEFINE ERROR STRINGS
err1=['REDUCE requires 1 or 4 input arguments. Type "help reduce"'];
err2=['Element list passed to REDUCE does not have 3 or 4 columns'];
err3=['REDUCE requires 2 or 6 output arguments.  Type "help reduce"'];
err6=['node coordinate vectors must be the same length'];
err10=['more than 1 column in x-coordinate vector.'];
err11=['more than 1 column in y-coordinate vector.'];
err12=['more than 1 column in z-coordinate vector.'];

errusingstr=['??? Error using ==> reduce'];
err4=str2mat(errusingstr,...
             ['If REDUCE has 1 input argument, it must have 2 output arguments.'],...
             ['Type "help reduce".']);
err5=str2mat(errusingstr,...
             ['If REDUCE has 4 input arguments, it must have 6 output arguments.'],...
             ['Type "help reduce".']);
err14=str2mat(errusingstr,...
              ['Maximum node number in element list ~= length of coordinate vectors'],...
              ['Type "help reduce".']);


% check argument lists
if nargin~=1&nargin~=4
   error(err1);
end

if nargout~=2&nargout~=6
   disp(err3);
   return
end

if nargin==1&nargout~=2
   disp(err4);
   return
end
if nargin==4&nargout~=6
   disp(err5);
   return
end

% Check size of element list
[nelems,ncol]=size(e);
if ncol < 3 | ncol > 4
   error(err2);
   return
elseif ncol==4
   in=in(:,2:4);
end

if nargin==4
   % CHECK SIZE OF X-COORDINATE VECTOR
   % NX = NUMBER OF X-COORDINATE VALUES, S = # OF COLS
   %
   [nx,s]=size(x);           
   if nx~=1&s~=1
      error(err10);
   end
   x=x(:);
   % CHECK SIZE OF Y-COORDINATE VECTOR
   % NY = NUMBER OF Y-COORDINATE VALUES, S = # OF COLS
   %
   [ny,s]=size(y);           
   if ny~=1&s~=1
      error(err11);
   end
   y=y(:);
   % CHECK SIZE OF Z-COORDINATE VECTOR
   % NZ = NUMBER OF Z-COORDINATE VALUES, S = # OF COLS
   %
   [nz,s]=size(z);           
   if nz~=1&s~=1
      error(err12);
   end
   z=z(:);
   %check coordinate lists
   if length(x) ~= length(y)
      error(err6);
   end
   if length(x) ~= length(z)
      error(err6);
   end

   maxnode=max(max(e));
   if maxnode ~= length(x)
      disp(err14);
      return
   end

end

% Report original bandwidth to screen
disp(['Initial 1/2 Bandwidth = ',int2str((bwidth(e)-1)/2)])

disp('Forming adjacency matrix ...');
% Form (i,j) connection list from .ele element list
%
i=[e(:,1);e(:,2);e(:,3)];
j=[e(:,2);e(:,3);e(:,1)];

% Form the sparse adjacency matrix.
%
n = max(max(i),max(j));
A = sparse(i,j,1,n,n);
disp('Cuthill-McKee ...');
perm=symrcm(A);
perm=perm(:);

% The reduced bandwidth adjacency matrix in 
% sparse form for boundary segment determination
%
ARBW=A(perm,perm);

disp('Permute inputs ...');
% Reverse the permutation "direction"
%
orignodelist=1:n;
l = zeros(n,1);
v=perm;
l(v)=orignodelist;

%Permute the element list
re=NaN*ones(size(e));
re(:,1) = l(e(:,1));
re(:,2) = l(e(:,2));
re(:,3) = l(e(:,3));
%[ju,l]=sort(re(:,1));
%re=re(l,:);

% Report reduced bandwidth to screen
disp(['Reduced 1/2 Bandwidth = ',int2str((bwidth(re)-1)/2)])

% return arguments
if nargin==4
   % Permute remaining input arguments
   rx=x(perm);
   ry=y(perm);
   rz=z(perm);
   % Compute new boundary
   disp('Computing new boundary ...');
   ARBW = ARBW + ARBW';
   ARBW=ARBW.*triu(ARBW);
   B=ARBW==1;
   [ib,jb,s]=find(B);
   rbnd=[ib(:),jb(:)];
else
   rx=perm;
end

%
%        Brian O. Blanton
%        Curriculum in Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        University of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%

