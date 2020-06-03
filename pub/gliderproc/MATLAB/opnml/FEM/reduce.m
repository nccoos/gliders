function [new_struct,perm]=reduce(fem_grid_struct)
% REDUCE compute a bandwidth-reduced FEM domain connectivity list
%
%        REDUCE reduces the bandwidth of a FEM element list
%        using the symmetric reverse Cuthill-McKee bandwidth reduction 
%        algorithm.  It employs the MATLAB routine SYMRCM to perform 
%        the reordering and then permutes the remaining input arguments 
%        according to the new node numbering. 
%
%  INPUT: fem_grid_struct  - Finite element structure
%
% OUTPUT: new_struct - new structure with reduced bandwidth
%         perm       -  permutation list (OPT)
%
%   CALL: REDUCE requires the following calling formats:
%
%	[new_struct,perm]=reduce(fem_grid_struct)
%
% Calls: opnml, sparfun toolbox, 
%
% Written by : Brian O. Blanton 
%              October 1995
% Modified by: Jay Veeramony
%		April 2000

% VERIFY INCOMING STRUCTURE
%
if ~is_valid_struct(fem_grid_struct)
   error('    Argument to INTERP_SCALAR must be a valid fem_grid_struct.')
end

if ~is_valid_struct2(fem_grid_struct)
   disp('Adding components')
   fem_grid_struct=el_areas(fem_grid_struct);
end

% BREAK DOWN INCOMING STRUCTURE
%
e=fem_grid_struct.e;
x=fem_grid_struct.x;
y=fem_grid_struct.y;
z=fem_grid_struct.z;

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

% Report reduced bandwidth to screen
disp(['Reduced 1/2 Bandwidth = ',int2str((bwidth(re)-1)/2)])

% Permute remaining input arguments
new_struct.name=fem_grid_struct.name;
new_struct.e=re;
new_struct.x=x(perm);
new_struct.y=y(perm);
new_struct.z=z(perm);
new_struct.bnd=detbndy(re);
new_struct=el_areas(new_struct);
