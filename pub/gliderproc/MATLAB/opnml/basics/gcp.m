function h = gcp
%GCP    Get current point on current axes and current figure.
%       H = GCP returns two sets of points:
%             1) the current point on the current figure;
%             2) the current 2-D point on the current axes. 
%
%       The current point is the last place on an axes that a mouse
%       button was pressed (or released if dragged).
%
%       The first set (figure point) is not useful for most purposes.
%       The second set (axes point) can be used to get the axes location
%       at which to place text strings for labelling.  
%
%       The current points are returned in a 2X2 matrix, with the units
%       specified by the figure (axes) property 'Units', as:
%
%         |                  |
%         |  Fig_X     Fig_Y |
%         |                  |
%         | Axes_X    Axes_Y |
%         |                  |
%
%       The figure units are most likely to be in pixels.
%
%       See the MATLAB Reference Guide for details on the 'CurrentPoint'
%       property of figures and axes.

%       Written by: Brian O. Blanton

hf = get(get(0,'CurrentFigure'),'CurrentPoint');
ha = get(get(get(0,'CurrentFigure'),'CurrentAxes'),'CurrentPoint');

h=[hf;ha(1) ha(3)];

%
%        Brian O. Blanton
%        Curriculum in Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%        FALL 95
%
