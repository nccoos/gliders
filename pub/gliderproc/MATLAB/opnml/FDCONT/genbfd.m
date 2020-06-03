function bfd=genbfd(fem_grid_struct,xylist,outflag,bfdfilename,refl)
%GENBFD generate a "basis function data" file for FD contouring 
%   GENBFD computes an information file for contouring FEM
%   node-based data using FD sampled points and MATLAB's
%   contourf routine.  The FD-based plotting tools are part
%   of the FDCONT toolkit.
%
%   Input: fem_grid_struct - FEM domain
%   	   xylist - FD point list (n X 2) or a 1x2 vector
%   		    containing [nx ny], the number of FD
%   		    points in (x,y) to discretize the area.
%   		    See below.
%   	   outflag - flag to output .bfd file to disk
%   		     if outflag==1, the bfd matrix is output to
%   		     the current directory with the name
%   		     <gridname>.bfd.
%   		     if outflag==0, the bfd matrix is returned
%   		     workspace.
%   	   bfdfilename - optional filename to write bfd matrix to.
%	   refl - Reference lon/lat for CPP transformation
%		  1x2 vector [reflon reflat]
%	 	  (optional: output will be in input coordinates)
%
%   	   Arguments 1-3 are required.
%
%   	   If xylist is passed in as [nx ny], GENBFD generates
%   	   the FD points convering an area equal to the
%   	   total extent of the FEM domain.  If only 1 integer
%   	   is passed in, then nx=ny, GENBFD takes the smaller
%   	   of [(xmax-xmin),(ymax-ymin)] for equal spacing.
%
%   Output: The result of GENBFD is a matrix
%   containing the following information.
%
%   For each FD point:
%    x y elem n1 n2 n3 b1 b2 b3 depth
%
%   where x,y = FD point coordinate
%   	  elem = FE element containing x y (==0 if outside FE mesh)
%   	  n1,n2,n3 = node numbers of containing element (or closest)
%   	  b1,b2,b3 = basis function values (or 1 0 0 if outside FEM)
%   	  depth = depth at xy (or depth of closest node)
%
%   For any given FD discretization, the bfd matrix need only be
%   computed once.  The bfd matrix is passed to FE2FD to perform
%   the actual FE to FD interpolation.
%
%   Call:  bfd=genbfd(fem_grid_struct,xylist,outflag)
%     OR   bfd=genbfd(fem_grid_struct,xylist,outflag,bfdfilename)
%     OR   bfd=genbfd(fem_grid_struct,[nx ny],outflag,bfdfilename)
%     OR   bfd=genbfd(fem_grid_struct,[nx ny],outflag,refl)
%     OR   bfd=genbfd(fem_grid_struct,[nx ny],outflag,bfdfilename,refl)
%
%   Written by: Brian Blanton (Spring 99) to implement
%   Chris Naimie's "bfd" file in MATLAB.
%
%   CPP transformation added 07/08/2003 (CRE)
%

if nargin<3 | nargin>5
   error('Incorrect number of arguments to GENBFD.')
end

if outflag~=0 & outflag~=1
   error('outflag to GENBFD must be 0|1.')
end

grid=fem_grid_struct; grid=el_areas(grid);
if ~is_valid_struct(fem_grid_struct)
   error('    Argument to GENBFD must be a valid fem_grid_struct.')
end
if ~is_valid_struct2(fem_grid_struct)
   disp('Adding Grid Components')
   grid=belint(grid);
   grid=el_areas(grid);
end

if nargin==3
   bfdfilename=fem_grid_struct.name;
end
if nargin==4
   if ~isstr(bfdfilename)
      if(isa(bfdfilename,'double')&(size(bfdfilename)==[1 2]))
        refl=bfdfilename;
	bfdfilename=fem_grid_struct.name;
        if outflag==0
          disp('Outflag==0, ignoring bfdfilename input.')
        end
      else
        error('bfdfilename to GENBFD must be a string.')
      end
   end
end

if nargin==5
   if ~isstr(bfdfilename)
      error('bfdfilename to GENBFD must be a string.')
   end
   if outflag==0
      disp('Outflag=0, ignoring bfdfilename input.')
   end
end

% Check size of xylist; if it is 1x1|1x2|2x1, assume this is
% the [nx ny] case and generate the FD points
[m,n]=size(xylist);
if m*n==1 | m*n==2
   if m*n==1
      nx=xylist;ny=[];  
   else
      nx=xylist(1);ny=xylist(2);
   end
   
   if nx<3 | ny < 3
      error('[nx,ny] to genbfd must be larger than 3x2 or 2x3')
   end
   disp(...
   ['Generating FD points as [' int2str(nx) ' ' int2str(ny) '] array...'])
   [xylist,nnx,nny]=gen_fd_points(nx,ny,fem_grid_struct);
   nx=nnx;ny=nny;
else
   if (n==1 | m==1)&m*n>2
      error('xylist to BASIS1D must be Nx2')
   end
end

% allow for possible 2 x N shape
if n>2
   xylist=xylist';
end

[m,n]=size(xylist);

bfd=NaN*ones(m,10);

xfd=xylist(:,1);
yfd=xylist(:,2);
if(exist('refl','var'))
  [xfd,yfd]=ll2xy(xylist(:,2),xylist(:,1),refl(2),refl(1));
  [xgrd,ygrd]=ll2xy(grid.y,grid.x,refl(2),refl(1));
  grid.x=xgrd; grid.y=ygrd; grid=el_areas(grid); grid=belint(grid);
end
bfd(:,1)=xfd;
bfd(:,2)=yfd;

% Locate elements for xylist
disp('Finding elements...')
j=findelem(grid,[xfd yfd]); 

% which points are in.out of the FEM domain
idx_in_fem=find(~isnan(j));
idx_out_fem=find(isnan(j));

% Fill element column of bfd
bfd(idx_in_fem,3)=j(idx_in_fem);
bfd(idx_out_fem,3)=zeros(size(idx_out_fem));

% NODE COLUMNS of bfd
bfd(idx_in_fem,4:6)=grid.e(j(idx_in_fem),:);
% Find nearest nodes for fd points outside FEM
% Only need to search boundary nodes for closest
disp('Minimizing distances...')
[bnd,cbnd] = count(grid.bnd); 
xbnd=grid.x(bnd);
ybnd=grid.y(bnd);
xout=xfd(idx_out_fem);
yout=yfd(idx_out_fem);
XOUT=xout*ones(size(xbnd'));
XBND=ones(size(xout))*xbnd';
YOUT=yout*ones(size(ybnd'));
YBND=ones(size(yout))*ybnd';
XDIF=XOUT-XBND;YDIF=YOUT-YBND;
DIST=sqrt(XDIF.*XDIF + YDIF.*YDIF);
[min_dist,imin] = min(DIST');
nearest_nodes=bnd(imin);
nearest_nodes=nearest_nodes(:);
bfd(idx_out_fem,4:6)=[nearest_nodes nearest_nodes nearest_nodes];

% BASIS
disp('Computing interp basis...')
%size([xfd(idx_in_fem) yfd(idx_in_fem)])
phi=basis2d(grid,[xfd(idx_in_fem) yfd(idx_in_fem)],j(idx_in_fem));
bfd(idx_in_fem,7:9)=phi;

%
% Check sum of basis;
bsum=sum(phi');
tol=1e-8;
idx=find(bsum>1+tol | bsum<0-tol);
if ~isempty(idx)
   error('Sum of FE basis ~=1.')
end

% 
bfd(idx_out_fem,7:9)=...
   [ones(size(nearest_nodes)) zeros(size(nearest_nodes)) zeros(size(nearest_nodes))];

% DEPTHS
disp('Interpolating depths...')
bfd(idx_out_fem,10)=grid.z(nearest_nodes);
bfd(idx_in_fem,10)=interp_scalar(grid,grid.z,xfd(idx_in_fem),yfd(idx_in_fem),...
j(idx_in_fem));

if ~isempty(find(isnan(bfd(:))))
   disp('Still NaNs in bfd array')
end

if(exist('refl','var'))
  bfd(:,1:2)=xylist; 
end

delete(findobj(0,'Tag','GENBFD fig'))
figure('MenuBar','none','Name','GENBFD Output')
line(bfd(:,1),bfd(:,2),'LineStyle','none','Marker','.','Color','r')
set(gcf,'Tag','GENBFD fig')
title_string=['GENBFD disc. [' int2str(nx) ' ' int2str(ny) '] on ' fem_grid_struct.name];
title(title_string)
hb=plotbnd(fem_grid_struct);set(hb,'LineWidth',2)
axis('tight')
drawnow


% Check for output file flag
if outflag==1
   filename=[bfdfilename '.bfd'];
   disp(['Writing BFD matrix to ' filename])
   fid=fopen(filename,'w');
   fprintf(fid,'%.3f %.3f %d %d %d %d %f %f %f %.2f\n',bfd');
end
if nargout==0
   bfd=[];
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% PRIVATE FUNCTION FOR GENBFD  %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xy,nnx,nny]=gen_fd_points(nx,ny,fem_grid_struct)
x=fem_grid_struct.x;
y=fem_grid_struct.y;

xmin=min(x);
xmax=max(x);
ymin=min(y);
ymax=max(y);
xrange=xmax-xmin;
yrange=ymax-ymin;

if isempty(ny)
   minrange=min(xrange,yrange);
   nnx=nx;
else
   nnx=nx;
   nny=ny;
end

if isempty(ny)
   dx=((xmax-xmin)/(nnx-1));
   xx=xmin:dx:xmax;
   yy=ymin:dx:ymax;
   nny=length(yy);
else
   xx=linspace(xmin,xmax,nnx);
   yy=linspace(ymin,ymax,nny);
end
[XX,YY]=meshgrid(xx,yy);
XX=XX';YY=YY';   %  to get x-coord to vary fastest.
xy=[XX(:) YY(:)];

disp(['DX = ' num2str(xx(2)-xx(1))])
disp(['DY = ' num2str(yy(2)-yy(1))])


%
%        Brian O. Blanton
%        Department of Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%        Spring 1999









