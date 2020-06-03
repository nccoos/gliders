% PERPVECPLOT routine to plot vectors perpendicular to view axis.  
%
% PERPVECPLOT scales the magnitude of w and then 
% forces a vector of magnitude sc to be 10% of the x data
% range.  By default, sc = 1., so that a 1 m/s vector will
% be scaled to 10% of the x data range.  If sc=.5, then
% a vector magnitude of 50 cm/s  will be scaled to 10% of the 
% x data range.  Decreasing sc serves to make the vectors
% appear larger.  PERPVECPLOT then prompts the user to place
% the vector scale on the figure, unless scale_xor,scale_yor
% is specified (see below).
%      
%   INPUT:   x,y    - vector origins
%            w      - perpendicular velocity 
%            These inputs are optional, but if one is needed, all
%            preceeding it wil be required.
%            sc     - vector scaler; (optional; default = 1.)
%
%  OUTPUT:   h - vector of handles to the vector lines drawn, the 
%                scale vector, and the scale vector text.
%
%   NOTES:   VECPLOT requires atleast 2 coordinates and vectors.
%
%    CALL:   hv=vecplot(x,y,w,sc)
%
% Calls: plots/drawperpvec
%
% Catherine R. Edwards
% Last modified: 1 Feb 2004
% Scaling code by Brian O. Blanton
% 
%

function  [hp,hc]=perpvecplot(x,y,w,sc)

% Copy incoming cell array

% DEFINE ERROR STRINGS
err1=['Invalid number of input arguments to PERPVECPLOT'];
err4=['Length of (x,y) must equal length of w.'];
err7=['Second optional argument (sclab) must be a string.'];
err8=['Both x- and y-coords of vector scale must be specified.'];

% PROCESS THE INPUT ARGUMENTS
% Length of varargin must be between 3 and 7, inclusive.
if nargin<3 |  nargin>4
   error(err1)
end 

xin=x;yin=y;
win=w;

% At this point, the copy of the input cell has been reduced to
% contain the optional arguments, if any.
if nargin==3
   sc=1.;sclab=' cm/s';
elseif nargin==4
   sc=sc;
   sclab=' cm/s';
end
col='b';

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
   error('Axes must have been previously set for PERPVECPLOT to work');
end
xpct10=xr/10; ypct10=yr/10;

%FILTER DATA THROUGH VIEWING WINDOW
%
filt=find(xin>=X1&xin<=X2&yin>=Y1&yin<=Y2);
x=xin(filt);
y=yin(filt);
win(filt);

% SCALE BY MAX VECTOR SIZE IN U AND V
%
ws=w/sc;

% SCALE TO 10 PERCENT OF X,Y RANGE
%
wx=ws*xpct10; wy=ws*ypct10;
 
% SEND VECTORS TO DRAWVEC ROUTINE
%
[hc,hp]=drawperpvec(x,y,wx,wy,col);

set(hp,'UserData',[xin yin win]);
set(hc,'UserData',[xin yin win]);
set(hp,'Tag','perpvectors');
set(hc,'Tag','perpvectors');

% OUTPUT IF DESIRED
%
if nargout==1,retval=[hp hc];,end

%
% return the saved values of the current figure's WindowButtonDownFcn,
% WindowButtonMotionFcn, and WindowButtonUpFcn to the current figure
%
set(gcf,'WindowButtonDownFcn',WindowButtonDownFcn);
set(gcf,'WindowButtonMotionFcn',WindowButtonMotionFcn);
set(gcf,'WindowButtonUpFcn',WindowButtonUpFcn);

