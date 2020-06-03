%LABCONT Private VIZICQ4 version!!
%
% LABCONT labels contours on the current axes that have been
% previously drawn with LCONTOUR.  Start up LABCONT by
% typing "labcont" at the MATLAB prompt (>>).  Then,
% click on the contour to label with the left mouse-button.
% Continue clicking with the left mouse-button button until
% all the labels have been added, then press the right 
% mouse-button in the current axes to stop LABCONT.  If
% an output argument was supplied to LABCONT, the handles
% to the text objects pointing to the labels is returned
%    to the MATLAB workspace.
%
% Written by : Brian O. Blanton, March 96
%
function h=lc(Figure,Axes,Info_Text,Error_Text)

setptr(Figure,'cross')

%
% save the current value of the current figure's WindowButtonDownFcn,
% WindowButtonMotionFcn, and WindowButtonUpFcn
%
WindowButtonDownFcn=get(Figure,'WindowButtonDownFcn');
WindowButtonMotionFcn=get(Figure,'WindowButtonMotionFcn');
WindowButtonUpFcn=get(Figure,'WindowButtonUpFcn');
set(Figure,'WindowButtonDownFcn','');
set(Figure,'WindowButtonMotionFcn','');
set(Figure,'WindowButtonUpFcn','');


npts=0;
set(Info_Text,'String',...
   'Click on contour with left mouse-button, right button to end')

while 1
   waitforbuttonpress;
   seltype=get(Figure,'SelectionType');
   if ~strcmp(seltype,'normal')break,end

   target=gco;
   if ~strcmp(get(target,'Tag'),'contour')
   set(Error_Text,'String',...
      'Target NOT a contour from LCONTOUR or ISOPHASE')
   else
      npts=npts+1;
      val=get(target,'UserData');
      pt=gcp;
      ht(npts)=text(pt(2),pt(4),num2str(val),...
                   'HorizontalAlignment','Center','FontSize',15,'Tag','contour');
   end
end

if nargout==1
   h=ht;
end

%
% return the saved values of the current figure's WindowButtonDownFcn,
% WindowButtonMotionFcn, and WindowButtonUpFcn to the current figure
%
set(Figure,'WindowButtonDownFcn',WindowButtonDownFcn);
set(Figure,'WindowButtonMotionFcn',WindowButtonMotionFcn);
set(Figure,'WindowButtonUpFcn',WindowButtonUpFcn);

%
%        Brian O. Blanton
%        Dept. of Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
