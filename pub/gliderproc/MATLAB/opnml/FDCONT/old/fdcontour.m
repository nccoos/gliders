function [c,h,hcb]=fdcontour(bfd,qfe,qmin,qmax,dq,cb)
%FDCONTOUR contour FE scalar on FD grid
%   FDCONTOUR accepts a scalar field from a FEM domain and
%   an FD grid in bfd form, and contours the FE scalar on the
%   FD grid, using MATLAB's contourf routine for filled color
%   bands.
%
%   Input: bfd  - big finite difference array (see GENBFD)
%          qfe  - the scalar on FE nodes
%          qmin - lower limit of scalar to contour
%          qmax - upper limit of scalar to contour
%          dq   - contour bandwidth (not the number of contours!!)
%          cb   - colorbar flag (0=no colorbar,1=colorbar)
%
%   Output: [c,h,hcb] - same vaules that contourf returns
%                       plus the axes handle to the colorbar
%                       if drawn (cb=1)
%
%   Call as: 
%        >> fdcontour(bfd,qfe)
%        >> fdcontour(bfd,qfe,qmin,qmax)
%        >> fdcontour(bfd,qfe,qmin,qmax,dq)
%        >> fdcontour(bfd,qfe,qmin,qmax,dq,cb)
%        >> [c,h,hcb]=fdcontour(bfd,qfe,qmin,qmax,dq,cb)
%        
%   Written by: Brian Blanton (Spring 99); based
%               on Chris E. Naimie's colorband routines.

if nargin==0
   disp('h=fdcontour(bfd,qfe,qmin,qmax,dq,cb);')
elseif nargin==1   %  Assume bathy contour plot, 
   error('Too many arguments to FDCONTOUR')      
elseif nargin==2
   qmin=min(qfe);
   qmax=max(qfe);
   dq=(qmax-qmin)/8;
   if dq<eps
      error(' No range in scalar to FDCONTOUR.')
   end
   cb=0;
elseif nargin==3
   error('Both qmin and qmax must be specified.')
elseif nargin==4
   if qmax<qmin
      error('qmax < qmin!!')
   end
   dq=(qmax-qmin)/8;
   if dq<eps
      error(' No range in scalar to FDCONTOUR.')
   end
   cb=0;
elseif nargin==5
   if qmax<qmin
      error('qmax < qmin!!')
   end
   if dq<eps
      error(' dq < eps in FDCONTOUR.')
   end
   cb=0;
elseif nargin==6
   if qmax<qmin
      error('qmax < qmin!!')
   end
   if dq<eps
      error(' dq < eps in FDCONTOUR.')
   end
   if cb~=0 & cb~=1
      error('Colorbar flag to FDCONTOUR must be 0|1')
   end
else
   error('Too many arguments to FDCONTOUR')      
end

%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% DEFINITIONS
%%%%%%%%%%%%%%%%%
cmapname='jet';
ncolbase=64;

% Extract parts of bfd array
xfd=bfd(:,1);
yfd=bfd(:,2);

% Determine number of points in x,y; assumes the FD points
% in BFD are rectangular
nx=2;
while xfd(nx+1)~=xfd(1)
   nx=nx+1;
end
ny=length(xfd)/nx;

fdon=find(bfd(:,3)==0);
fdonfe=ones(size(bfd(:,3)));fdonfe(fdon)=NaN;

%  Reshape FD arrays for contourf
xfd=reshape(xfd,nx,ny);
yfd=reshape(yfd,nx,ny);
qfd=reshape(fe2fd(qfe,bfd(:,4:9)),nx,ny);
fdon=reshape(fdonfe,nx,ny);

qfd=qfd.*fdon;

cval=qmin:dq:qmax;
%nband=(qmax-qmin)/dq;
nband=length(cval)-1;
if ~isint(nband)
   disp('Resulting number of colorbands not an integer')
   disp('Recompute qmin:dq:qmax')
   return
end

njet=64;
if nband>=ncolbase
   disp(['Number of colorbands (' int2str(nband) ') can''t exceed'])
   disp(['number of colors in colormap(' int2str(ncolbase) ')'])
   return
end

% Build ColorMap
cmap=gen_cmap(ncolbase,nband,cmapname);

[cc,hh]=contourf(xfd,yfd,qfd,cval);
colormap(cmap)
caxis([min(cval) max(cval)])

if cb == 1
   hb=colorbar;set(hb,'ytick',cval);set(hb,'ticklength',[0.05 0.025]);
end

if nargout==3
   c=cc;h=hh;hcb=hb;
elseif nargout==2
   c=cc;h=hh;
elseif nargout==1
   c=cc;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% PRIVATE FUNCTION FOR FDCONTOUR  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cmap=gen_cmap(ncolorbase,nband,cmaptype)
cmapbase=eval([cmaptype '(ncolorbase)']);
cmap=ones(nband,3);
idx1=floor(.1*ncolorbase);
idx2=ceil(.9*ncolorbase);
idx=round(linspace(idx1,idx2,nband));
cmap(1:nband,:)=cmapbase(idx,:);
