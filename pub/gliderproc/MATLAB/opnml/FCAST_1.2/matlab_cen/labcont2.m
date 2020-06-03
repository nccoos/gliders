%
% LABCONT  -  label contours drawn with LCONTOUR2
%
%             LABCONT labels contours on the current axes that have been
%             previously drawn with LCONTOUR2.  Start up LABCONT by
%             typing "labcont" at the MATLAB prompt (>>).  Then,
%             click on the contour to label with the left mouse-button.
%             Continue clicking with the left mouse-button button until
%             all the labels have been added, then press the right 
%             mouse-button in the current axes to stop LABCONT.  If
%             an output argument was supplied to LABCONT, the handles
%             to the text objects pointing to the labels is returned
%             to the MATLAB workspace.
%
% Written by : Brian O. Blanton, March 96
%

function h=labcont2

if nargin~=0 
   error('labcont2 takes 0 input arguments')
elseif nargin~=0 & nargout~=1
   error('LABCONT2 takes 0 or 1 output arguments.')
end

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


npts=0;
disp('Click on contour with left mouse-button, right button to end')

while 1
   waitforbuttonpress;
   seltype=get(gcf,'SelectionType');
   if ~strcmp(seltype,'normal')break,end

   target=gco;
   if ~strcmp(get(target,'Tag'),'contour')
      disp('Target NOT a contour from LCONTOUR2 or ISOPHASE')
   else
      npts=npts+1;
      val=get(target,'UserData');
      pt=gcp;
      ht(npts)=text(pt(2),pt(4),num2str(val),...
                   'HorizontalAlignment','Center','FontSize',10);
      textlen=get(ht(npts),'Extent');
      jx1=textlen(1);
      jy1=textlen(2);
      jx2=textlen(1)+textlen(3);
      jy2=textlen(2)+textlen(4);
      delete(ht(npts))
      fill([jx1 jx2 jx2 jx1],[jy1 jy1 jy2 jy2],'w','Edgecolor','w')
      ht(npts)=text(pt(2),pt(4),num2str(val),...
                   'HorizontalAlignment','Center','FontSize',10);
      set(ht(npts),'color','k')
   end
end

if nargout==1
   h=ht;
end

%
% return the saved values of the current figure's WindowButtonDownFcn,
% WindowButtonMotionFcn, and WindowButtonUpFcn to the current figure
%
set(gcf,'WindowButtonDownFcn',WindowButtonDownFcn);
set(gcf,'WindowButtonMotionFcn',WindowButtonMotionFcn);
set(gcf,'WindowButtonUpFcn',WindowButtonUpFcn);

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

