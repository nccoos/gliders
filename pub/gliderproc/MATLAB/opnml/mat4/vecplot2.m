function  retval=vecplot2(xin,yin,uin,vin,sc,sclab,scale_xor,scale_yor)
%VECPLOT2 routine to plot vectors.  
% VECPLOT2 draws vectors on the current figure, at (x,y)
% locations determined in one of two ways.  If the first
% argument to VECPLOT is a fem_grid_struct, then VECPLOT
% extracts the FEM domain coordinates as the vector origins.
% Otherwise, the user supplies the (x,y) coordinates
% explicitly.  This flexibility exists because vector
% plotting does not require any knowledge of nodal
% connectivity, and perhaps the (u,v) data are not
% from a FEM model output.
%
% VECPLOT scales the magnitude of
% (u,v) by the magnitude of max(abs(u,v)) and then
% forces a vector of magnitude sc to be 10% of the x data
% range.  By default, sc = 1., so that a 1 m/s vector will
% be scaled to 10% of the x data range.  If sc=.5, then
% a vector magnitude of 50 cm/s  will be scaled to 10% of the
% x data range.  Decreasing sc serves to make the vectors
% appear larger.  VECPLOT then prompts the user to place
% the vector scale on the figure, unless scale_xor,scale_yor
% is specified (see below).
%
% hv=vecplot(x,y,u,v,sc,sclab) 
% OR 
% hv=vecplot(fem_grid_struct,u,v,sc,sclab)
%
%      
%   INPUT:   fem_grid_struct  (from LOADGRID, see FEM_GRID_STRUCT)
%            OR
%            x,y    - vector origins
%            u,v    - vector amplitudes
%            These inputs are optional, but if one is needed, all
%            preceeding it wil be required.
%            sc     - vector scaler; (optional; default = 1.)
%            sclab  - label for vector scale; (optional; default = 'cm/s')
%            scale_xor,scale_yor  -  location to place vector scale
%
%  OUTPUT:   h - vector of handles to the vector lines drawn, the 
%                scale vector, and the scale vector text.
%
%   NOTES:   VECPLOT requires atleast 2 coordinates and vectors.
%
%    CALL:   hv=vecplot(x,y,u,v,sc,sclab)
%     or
%            hv=vecplot(fem_grid_struct,u,v,sc,sclab)
%
% Written by : Brian O. Blanton
%

if nargin==0,
   disp('Call as: hv=vecplot(x,y,u,v,sc,sclab) OR ')
   disp('         hv=vecplot(fem_grid_struct,u,v,sc,sclab)')
   return
end

% DEFINE ERROR STRINGS
err1=['Not enough input arguments; type "help vecplot2"'];
err2=['Too many input arguments; type "help vecplot2"'];
err3=['Length of x,y,u,v must be the same'];
err4=['Length of x,y,u,v must be greater than 1'];

%
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
if nargin < 4
   error(err1);
elseif nargin > 8
   error(err2);
end

% Is the first argument a structure?
if isstruct(xin)
   % Then is it valid?
   if ~is_valid_struct(fem_grid_struct)
      error('fem_grid_struct to VECPLOT not valid')
   end
   fem_grid_struct=xin; 
   xin=fem_grid_struct.x;
   yin=fem_grid_struct.y;
end
  
% process argument list
if nargin==4
   sc=1.;
   sclab='cm/s';      
elseif nargin==5 
   sclab='cm/s';      
end
sclab=[' ' sclab];
col='b';

if length(xin)~=length(yin) | ...
   length(xin)~=length(uin) | ...
   length(xin)~=length(vin)
   error(err3);
end
if length(xin)==1 
   error(err4);
end

xin=xin(:);
yin=yin(:);
uin=uin(:);
vin=vin(:);

% SCALE VELOCITY DATA TO RENDERED WINDOW SCALE 
%
RLs= get(gca,'XLim');
xr=RLs(2)-RLs(1);
X1=RLs(1);
X2=RLs(2);
RLs= get(gca,'YLim');
yr=RLs(2)-RLs(1);
Y1=RLs(1);
Y2=RLs(2);

% IF RenderLimits NOT SET, USE RANGE OF DATA
%
if(xr==0|yr==0)
   error('Axes must have been previously set for VECPLOT2 to work');
end
pct10=xr/10;

%FILTER DATA THROUGH VIEWING WINDOW
%
filt=find(xin>=X1&xin<=X2&yin>=Y1&yin<=Y2);
x=xin(filt);
y=yin(filt);
u=uin(filt);
v=vin(filt);

% SCALE BY MAX VECTOR SIZE IN U AND V
%
us=u/sc;
vs=v/sc;

% SCALE TO 10 PERCENT OF X RANGE
%
us=us*pct10;
vs=vs*pct10;
 
% SEND VECTORS TO DRAWVEC ROUTINE
%
hp=drawvec(x,y,us,vs,25,col);
set(hp,'UserData',[xin yin uin vin]);
set(hp,'Tag','vectors');

% COLOR LARGEST VECTOR RED
[trash,imax]=max(sqrt(us.*us+vs.*vs));
hvmax=drawvec(x(imax),y(imax),us(imax),vs(imax),25,'r');
set(hvmax,'Tag','scalearrow');

% PLACE SCALE WITH MOUSE ON SCREEN
%
if ~strcmp(blank(sclab),'no scale')
   ptr=get(gcf,'Pointer');
   if ~exist('scale_xor')| ~exist('scale_yor')
      disp('place scale on plot with a mouse button');
      [scale_xor,scale_yor]=ginput(1);
   end 
   
   ht1=drawvec(scale_xor,scale_yor,pct10,0.,25,'r');
   set(ht1,'Tag','scalearrow');
   if strcmp(blank(sclab),'m/s')
      sctext=[num2str(sc) sclab];
   else
      sctext=[num2str(100*sc) sclab];
   end
   scaletext=text((scale_xor+scale_xor+pct10)/2,scale_yor-(Y2-Y1)*(.05),sctext);
   set(scaletext,'HorizontalAlignment','center');
   set(scaletext,'VerticalAlignment','middle');
   set(scaletext,'Tag','scaletext');
   set(gcf,'Pointer',ptr);

end

% OUTPUT IF DESIRED
%
if nargout==1,retval=[hp ht1 scaletext];,end

%
% return the saved values of the current figure's WindowButtonDownFcn,
% WindowButtonMotionFcn, and WindowButtonUpFcn to the current figure
%
set(gcf,'WindowButtonDownFcn',WindowButtonDownFcn);
set(gcf,'WindowButtonMotionFcn',WindowButtonMotionFcn);
set(gcf,'WindowButtonUpFcn',WindowButtonUpFcn);

%
%        Brian O. Blanton
%        Department of Marine Science
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%      
%        SUMMER 1998
%
