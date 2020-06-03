%
% VECPLOTSTICK vecplotstick(x,y,u,v,sc,color,dotsize)
%
%            routine to plot vectors.  STICKPLOT scales the magnitude of 
%            (u,v) by the magnitude of max(abs(u,v)) and then 
%            to Q percent of the range of the domain (xin,yin) coordinates.  
%            Initially, Q is 10.  The input argument sc scales Q.  
%            If sc=1, Q=10.  If sc=2, Q=20. If sc=.5, Q=5. 
%
%	     STICKPLOT overlays on existing axes, regardless of the state 
%            of 'hold'.  If there is no current axes, STICKPLOT draws a
%            new axes. 
%          
%            x,y     - vector origins
%            u,v     - vector amplitudes
%            sc      - vector scale; use '1' first time.
%            color   - stick color; (optional, def = 'r')
%            dotsize - vector origin "dot" size (optional, def = 10)
%
%            dotsizes are given in points where a point is 1/72 inches
%            The MATLAB default MarkerSize of 6 is approx. the size of a . 
%            (period).
%
%            Example call:  stickplot(x,y,u,v,2,'r',10)
%            This will draw vectors at (x,y) with appropriately scaled
%            magnitudes (u,v), with the maximum vector size being 20 
%            percent of the domain exent, with red lines used
%            to draw the vectors, and with vector origin dots being
%            10 points wide.  
%
%  	     NOTES:
%            STICKPLOT requires atleast 2 points and vectors.
%            STICKPLOT does NOT force the axis aspect ratio to be 1:1.
%
% Call as:   hp=vecplotstick(x,y,u,v,sc,color,dotsize);
%
function  retval=vecplotstick(xin,yin,uin,vin,sc,...
                              vcolor,ds,sclab,scale_xor,scale_yor)
%
% Argument check
%
if nargin<5
   error('VECPLOTSTICK must have atleast 5 input arguments; type "help stickplot"');
elseif nargin == 5
   vcolor='k';
   ds=10;
elseif nargin == 6
   if ~isstr(vcolor)
      error('color argument to VECPLOTSTICK not a string');
   end
   ds=10;
elseif nargin > 10
   error('Too many input arguments; type "help stickplot"');
end

if ~isstr(vcolor)
   error('color argument to VECPLOTSTICK not a string');
end


if length(xin)~=length(yin) | length(xin)~=length(uin) | length(xin)~=length(vin)
   error('Length of x,y,u,v must be the same');
end
if length(xin)==1 
   error('Length of x,y,u,v must be greater than 1');
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

% SEND VECTORS TO DRAWSTICK ROUTINE
%
hp=drawstick(xin,yin,us,vs,ds,vcolor);
set(hp(1),'UserData',[xin yin uin vin]);
set(hp,'Tag','vectors');

mainax=gca;
% Draw vector scale
data_axis=axis;
cur_units=get(gca,'Units');
set(gca,'Units','normalized');
axnorm=get(gca,'Position');
xstart=axnorm(1)+axnorm(3)*.8;
ystart=axnorm(2);
dx=axnorm(3)*.2;
dy=axnorm(4)*.1;
%scale_axes=axes('Units','normalized','Position',[xstart ystart dx dy]);
scale_axes=axes('Units','normalized','Position',[0 0 dx dy]);
set(scale_axes,'XTick',[],'YTick',[])
set(scale_axes,'Tag','vecscaleaxes');
set(scale_axes,'ButtonDownFcn','movescaleaxes(1)');
dx1=data_axis(1)+(data_axis(2)-data_axis(1))*.8;
dx2=data_axis(2);
dy1=data_axis(3);
dy2=data_axis(3)+(data_axis(4)-data_axis(3))*.1;
axis([dx1 dx2 dy1 dy2])
sc_or_x=dx1+(dx2-dx1)/10;
ht1=drawstick(sc_or_x,(dy1+dy2)/2.05,pct10,0.,10,vcolor);
set(ht1,'Tag','scalearrow');
sctext=[num2str(sc) sclab];
scaletext=text((dx1+dx2)/2,(dy1+dy2)/1.95,sctext);
set(scaletext,'HorizontalAlignment','center');
set(scaletext,'VerticalAlignment','middle');
set(scaletext,'Tag','scaletext');
drawnow
axes(mainax)
set(scale_axes,'Visible','on')

% OUTPUT HANDLES IF DESIRED
%
if nargout==1,retval=hp;,end

%
%        Brian O. Blanton
%        Department of Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolna
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@cuda.chem.unc.edu
%
