%
% MARKCCW  mark Counter Clockwise oriented ellipses with *'s at centers
%
%          The OPNML function TELLIPSE (or ELLIPSE) must have been run
%          before MARKCCW will work.
%
%          Input: Marker type (optional, default = '*')
%          Output: MARKCCW returns the handle to the *'s plotted.
%
% Call as: h=markccw(markerstyle);
%
function h=markccw(markerstyle)

%
%...Check input argument
if nargin>1
   error('Wrong number of inputs to MARKCCW.');
else
   if nargin==0
      markerstyle='*';
   elseif ~isstr(markerstyle)
      error('Input to MARKCCW must be a string marker style (i.e., ''+'')');
   else
      if ~strcmp(markerstyle,'*')|...
         ~strcmp(markerstyle,'+')|...
         ~strcmp(markerstyle,'o')
         error('Input to MARKCCW must be one of (*,+,o).')
      end   
   end
end

%
%...Find ellipse object in current axes
hell=findobj(gca,'Type','line','Tag','ellipse data');
if isempty(hell)
   error('No ellipse object in current axes.');
end

%
%...Extract UserData from ellipse object
data=get(hell,'UserData');

%
%...Extract Ellipse centers and Minor axis lengths from ellipse object
xc=data(:,1);
yc=data(:,2);
UMINOR=data(:,4);

%
%...Remove trailing NaN from centers and UMINOR
xc=xc(1:length(xc)-1);
yc=yc(1:length(yc)-1);
UMINOR=UMINOR(1:length(UMINOR)-1);

%
%...CCW ellipses
ccw=find(UMINOR>0);

%
%...Plot *'s at ellipse centers whose orientation is ccw
h=line(xc(ccw),yc(ccw),'Linestyle',markerstyle,'Color','r','Tag','ccw ellipse centers');
return
%
%        Brian O. Blanton
%        Curriculum in Marine Science
%        Ocean Processes Numerical Modeling Laboratory
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%        February 1995
%

