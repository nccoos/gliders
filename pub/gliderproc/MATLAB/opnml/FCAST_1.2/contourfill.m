function [CSO,H] = contourfill(arg1,arg2,arg3,arg4)
% CONTOURFILL Filled contour plot
%        CONTOURFILL(Z) is a filled contour plot of matrix Z treating the 
%        values in Z as heights above a plane.
%
%        CONTOURFILL(X,Y,Z), where X and Y are vectors, specifies X- and 
%        Y- axes used on the plot. X and Y can also be matrices of the 
%        same size as Z, in which case they specify a surface in an 
%        identical manner as SURFACE.
%
%        CONTOURFILL(Z,N) and CONTOURFILL(X,Y,Z,N) draw N contour lines, 
%        overriding the default automatic value.
%
%        CONTOURFILL(Z,V) and CONTOURFILL(X,Y,Z,V) draw LENGTH(V) contour 
%        lines at the values specified in vector V.
%
%        CONTOURFILL([X Y],N,Z,V) contour fills the triangular mesh 
%        specified by node location vectors X,Y with height vector Z, 
%        where N is a 3xn matrix containing the node indices for n 
%        triangles.

%  Author: R. Pawlowicz (IOS)  rich@ios.bc.ca
%          14/12/94

recmesh=1;

if (nargin == 4),
   x = arg1;
   y = arg2;
   z = arg3;
   nv = arg4;
   if min(size(z))==1 & any(size(y)==3), % fall-through for triangular mesh
     recmesh=0;
   else
     if (size(y,1)==1), y=y'; end;
     if (size(x,2)==1), x=x'; end;
     [mz,nz] = size(z);
   end;
elseif (nargin == 3),
  x = arg1;
  y = arg2;
  z = arg3;
  nv = [];
   if min(size(z))==1 & any(size(y)==3), % fall-through for triangular mesh
     recmesh=0;
   else
    if (size(y,1)==1), y=y'; end;
    if (size(x,2)==1), x=x'; end;
    [mz,nz] = size(z);
   end;
elseif (nargin == 2),
  [mz,nz] = size(arg1);
  x = 1:nz;
  y = [1:mz]';
  z = arg1;
  nv = arg2;
elseif (nargin == 1),
  [mz,nz] = size(arg1);
  x = 1:nz;
  y = [1:mz]';
  z = arg1;
  nv = [];
end

i = find(finite(z));
minz = min(min(z(i)));
maxz = max(max(z(i)));

% Generate default contour levels if they aren't specified 
nv=getlevels(z,nv);

% Handle interior holes correctly
draw_min=0;
if any(nv<=minz),
 draw_min=1;
end;

% Get the unique levels

if (recmesh),
 % Get the unique levels

  nv = sort([minz nv maxz]);
  zi = [1, find(diff(nv))+1];
  nv = nv(zi);
 % Surround the matrix by a very low region to get closed contours, and
  % replace any NaN with low numbers as well.

  zz=[ NaN+ones(1,nz+2) ; NaN+ones(mz,1) z NaN+ones(mz,1) ; NaN+ones(1,nz+2)];
  kk=find(isnan(zz(:)));
  zz(kk)=minz-1e4*(maxz-minz)+zeros(size(kk));

  xx = [2*x(:,1)-x(:,2), x, 2*x(:,nz)-x(:,nz-1)];
  yy = [2*y(1,:)-y(2,:); y; 2*y(mz,:)-y(mz-1,:)];
  if (min(size(yy))==1),
   CS=contoursurf(xx,yy,zz,nv);
  else
   CS=contoursurf(xx([ 1 1:mz mz],:),yy(:,[1 1:nz nz]),zz,nv);
  end;
else
  CS=contourtri(x,z,y,nv,'fill');
end;

if length(CS)==0, return; end;  % No contours to be drawn!

% Find the indices of the curves in the c matrix, and get the
% area of closed curves in order to draw patches correctly. 
ii = 1;
ncurves = 0;
I = [];
Area=[];
while (ii < size(CS,2)),
  nl=CS(2,ii);
  ncurves = ncurves + 1;
  I(ncurves) = ii;
  x=CS(1,ii+[1:nl]);  % First patch
  y=CS(2,ii+[1:nl]);
  Area(ncurves)=sum( diff(x).*(y(1:nl-1)+y(2:nl))/2 );
  ii = ii + nl + 1;
end

plot(CS(1,2),CS(2,2),'-');

% Plot patches in order of decreasing size. This makes sure that
% all the levels get drawn, no matter if we are going up a hill or
% down into a hole. When going down we shift levels - you can
% tell whether we are going up or down by checking the sign of the
% area (since curves are oriented so that the high side is always
% the same side). Lowest curve is largest and always encloses higher 
% data

H=[];
[FA,IA]=sort(-abs(Area));

for jj=IA,
 nl=CS(2,I(jj));
 lev=CS(1,I(jj));
 if (lev ~=minz | draw_min ),
   x=CS(1,I(jj)+[1:nl]);  
   y=CS(2,I(jj)+[1:nl]); 
   if (sign(Area(jj)) ~=sign(Area(IA(1))) ),
     kk=find(nv==lev);
     if (kk>1+sum(nv<=minz)*(~draw_min)), 
      lev=nv(kk-1);
     else 
      lev=NaN;         % missing data section
     end;
   end;

   if (finite(lev)),
     H=[H;patch(x,y,lev,'facecolor','flat','edgecolor','none')];
   else
     H=[H;patch(x,y,lev,'facecolor',get(gcf,'color'),'edgecolor','none')];
   end;
 end;
end;

if nargout
	CSO=CS;
end