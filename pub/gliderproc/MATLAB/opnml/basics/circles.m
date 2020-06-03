% 
% CIRCLES  plot circles at optionally input centers with required input radii.
% 
%          CIRCLES(RAD) draws circles at the origin with radii RAD.
%
%          CIRCLES(XC,YC,RAD) draws circles with radii RAD and with
%          centers at (XC,YC).
%
% Input  : XC   - x-coord vector of circle centers (optional, See Note 4)
%          YC   - y-coord vector of circle centers (optional, See Note 4)
%          RAD  - vector of circle radii (required)
%          p1,v1... - parameter/value plotting pairs (optional, See Note 4)
%
% Output : HCIR - vector of handles to circles drawn.
%
%          The parameter/value pairs currently allowed in the CIRCLES
%          function are as follows ( default values appear in {} ) :
%
%                Color       {'r' = red}
%                LineStyle   {'-' = solid}
%                LineWidth   {0.5 points; 1 point = 1/72 inches}
%                MarkerSize  {6 points}
%
%          See the Matlab Reference Guide entry on the LINE command for
%          a complete description of parameter/value pair specification.
%
%          The idea and some of the constructs used in pv decoding
%          in this routine come from an unreleased MathWorks function
%          called polar2.m written by John L. Galenski III
%          and provided by Jeff Faneuff.
%
%          NOTES: 1) CIRCLES always overlays existing axes, regardless
%                    of the state of 'hold'.
%                 2) CIRCLES does not force the axis to be 'equal'.
%                 3) CIRCLES is a special case of the routine ELLIPSES;
%                    although ELLIPSES can be used to draw circles, 
%                    CIRCLES is much faster at drawing circles because 
%                    it does not deal with orientation and eccentricity
%                    parameters.
%                 4) If you want to specify parameter/vaule plotting 
%                    attributes with circles at the origin, you must pass
%                    CIRCLES 0-vectors for the x- and y- coordinates of
%                    the circles.  If you don't, CIRCLES will not be able 
%                    to decode the parameter/value sequence and you will 
%                    probably get the following error:
%                                ??? Error using ==> +
%                                Matrix dimensions must agree.
%
% Call as: >> hcir=circles(xc,yc,rad,p1,v1,p2,v2,...)
%
% Written by : Brian O. Blanton
%         
function hcir=circles(xc,yc,rad,p1,v1,p2,v2,p3,v3,p4,v4,...
                               p5,v5,p6,v6,p7,v7,p8,v8)

% DEFINE ERROR STRINGS
err1=['Need atleast radii as input.'];
err2=['Too many input arguments specified.'];
err3=['Must specify centers and radii or just radii.'];
err4=['Lengths of circle center vectors must be the same.'];
err5=['Number of circle centers and radii specified must be the same.'];
err6=['insufficient number of parameters or values'];

% check arguments.
if nargin==0
   error(err1);
elseif nargin>19
   error(err2)
elseif nargin==1
   rad=xc;
   xc=zeros(size(rad));
   yc=zeros(size(rad));
   flag=1;
elseif nargin==2
   error(err3);
elseif nargin==3
   if length(xc)~=length(yc)
      error(err4);
   elseif length(xc)~=length(rad)
      error(err5);
   end
   flag=1;
else
   flag=0;
   npv = nargin-3;
   if rem(npv,2)==1,error(err6);,end
   
   % process parameter/value pair argument list, if needed
   PropFlag = zeros(1,4);
   limt=npv/2;
   for X = 1:limt
     p = eval(['p',int2str(X)]);
     v = eval(['v',int2str(X)]);
     if X == 1
       Property_Names = p;
       Property_Value = v;
     else
       Property_Names = str2mat(Property_Names,p);
       Property_Value = str2mat(Property_Value,v);
     end
     if strcmp(lower(p),'color')
       PropFlag(1) = 1;
       color = v;
     elseif strcmp(lower(p),'linestyle')
       PropFlag(2) = 1;
       linestyle = v;
     elseif strcmp(lower(p),'linewidth')
       PropFlag(3) = 1;
       linewidth = v;
     elseif strcmp(lower(p),'markersize')
       PropFlag(4) = 1;
       markersize = v;
     end
   end

   % Determine which properties have not been set by
   % the user
   Set    = find(PropFlag == 1);
   NotSet = find(PropFlag == 0);

   % Define property names and default values
   Default_Settings =str2mat('''r''','''- ''','0.5','6');
   Property_Names = str2mat('color','linestyle','linewidth','markersize');
   for I = 1:length(NotSet)
     eval([Property_Names(NotSet(I),:),'=',Default_Settings(NotSet(I),:),';'])
   end
end

% force xc, yc, and rad to be column vectors.
xc=xc(:);
yc=yc(:);
rad=rad(:);

% t must be a row vector
delt=pi/24;
t=0:delt:2*pi;
t=t(:)';

% compute (0,0) origin-based circles
x=(rad*cos(t))';
y=(rad*sin(t))';
[nrow,ncol]=size(x);

% translate circles to input centers (xc,yc)
xadd=(xc*ones(size(1:nrow)))';
yadd=(yc*ones(size(1:nrow)))';
x=x+xadd;
y=y+yadd;

% append NaN's so we get one handle.
x=[x;
   NaN*ones(size(1:ncol))];
y=[y;
   NaN*ones(size(1:ncol))];
x=x(:);
y=y(:);

% draw circles and return handle in hcir.
if ~flag
   hcir=line(x,y,...
             'Color',color,...
             'Linestyle',linestyle,...
             'LineWidth',linewidth,...
             'MarkerSize',markersize);
else
   hcir=line(x,y);
end
set(hcir,'Tag','circles')
%
%        Brian O. Blanton
%        Curr. in Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolna
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
