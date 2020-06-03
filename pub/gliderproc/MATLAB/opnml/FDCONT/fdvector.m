function h=fdvector(bfd,ufe,vfe,sc,stride,sclab,scale_xor,scale_yor)
%FDVECTOR plot vectors from a bfd sampling.
%   FDVECTOR plots vectors from a FEM domain that has been
%   sampled on a finite difference grid.  The FD grid
%   is contained in a .bfd file (See GENBFD) and FDVECTOR
%   handles the interpolatopn of FE vector data onto
%   the FD grid.  (VECPLOT2 does the actual plotting.)
%
%   Input:   bdf    - bfd array (all 10 columns)
%            u      - east vector amplitude
%            v      - west vector amplitude
%            sc     - vector scaler; (optional; def = 1.)
%            stride - stride over nodes
%            sclab  - label for vector scale; (optional; def = 'cm/s')
%            scale_xor,scale_yor - vector scale origin (optional)
%
%   The stride argument is used to plot every other 
%   vector (stride=2, e.g.).
%
%   Including the scale_xor,scale_yor prevents the mouse-driven 
%   specification of the vector scale placement.
% 
%   Output: h - vector of handles to objects drawn.

% DEFINE ERROR STRINGS
err1=['Not enough input arguments; type "help fdvector"'];
err2=['Too many input arguments; type "help fdvector"'];
err3=['Length of x,y,u,v must be the same'];
err4=['Length of x,y,u,v must be greater than 1'];
err5=['Both x and y must be specified to vector scale origin.'];
err6=['Stride must be an integer >1'];
% save the current value of the current figure's WindowButtonDownFcn,
% WindowButtonMotionFcn, and WindowButtonUpFcn
%
WindowButtonDownFcn=get(gcf,'WindowButtonDownFcn');
WindowButtonMotionFcn=get(gcf,'WindowButtonMotionFcn');
WindowButtonUpFcn=get(gcf,'WindowButtonUpFcn');
set(gcf,'WindowButtonDownFcn','');
set(gcf,'WindowButtonMotionFcn','');
set(gcf,'WindowButtonUpFcn','');

% Argument check
if nargin < 3
   error(err1);
elseif nargin > 8
   error(err2);
end
  
% process argument list
if nargin==3
   sc=1.;
   sclab='cm/s';    
   stride=1;  
elseif nargin==4
   sclab='cm/s';
   stride=1;      
elseif nargin==5
   sclab='cm/s';
   if stride<1 | ~isint(stride)
      error(err6)
   end
end
sclab=[' ' sclab];
if nargin==7
   error(err5)
end

xfd=bfd(:,1);yfd=bfd(:,2);
ufd=fe2fd(ufe,bfd(:,4:9));
vfd=fe2fd(vfe,bfd(:,4:9));

if length(xfd)~=length(vfd)
   error(err3);
end
if length(ufd)==1 
   error(err4);
end


% Find which FD nodes are entirely within FE domain
fdonfe=find(bfd(:,3)~=0);

x=xfd(fdonfe);
y=yfd(fdonfe);
u=ufd(fdonfe);
v=vfd(fdonfe);

istride=1:stride:length(x);
x=x(istride);
y=y(istride);
u=u(istride);
v=v(istride);

if exist('scale_xor') 
   h=vecplot2(x,y,u,v,...
              sc,sclab,scale_xor,scale_yor);
else
   h=vecplot2(x,y,u,v,sc,sclab);
end

set(h,'Color','k');



