%
% PAN	Mouse-driven pan-around facility.   
%
% PAN	Mouse-driven pan-around facility.  PAN prompts the user to choose 
%       the new center of the viewing box with the left mouse button
%       and then shifts the view accordingly.
%
% Call as: ">> pan"
%
% Written by: Brian O. Blanton
%

% get current axis limits
OLDXP = get(gca,'Xlim');
OLDYP = get(gca,'Ylim');
 
% compute width and height of axes
width=OLDXP(2)-OLDXP(1);
height=OLDYP(2)-OLDYP(1);
waitforbuttonpress;
Pt1=get(gca,'CurrentPoint');
xcen=Pt1(1,1);
ycen=Pt1(1,2);

% compute new window extent
xmin=xcen-width/2;
xmax=xcen+width/2;
ymin=ycen-height/2;
ymax=ycen+height/2;

% set new axis limits
set(gca,'Xlim',[xmin xmax]);
set(gca,'Ylim',[ymin ymax]);
clear OLDXP OLDYP width height xcen ycen xmin xmax ymin ymax

%
%        Brian O. Blanton
%        Curr. in Marine Science
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%


