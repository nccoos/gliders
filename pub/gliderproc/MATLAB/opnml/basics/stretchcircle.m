function line_coords=stretchline(action)
% STRETCHLINE creates a line and stretches it following the mouse
%
% TO USE: set(gcf,'WindowButtonDownFcn','stretchline')
%
% Written by: Brian Blanton (Dec 98)

if nargin==0  % Button pushed, initialize

  % Get the current WindowButton*Fcn's, and store globally
  % for return 
  global WindowButtonDownFcn WindowButtonMotionFcn WindowButtonUpFcn
  WindowButtonDownFcn = get(gcf,'WindowButtonDownFcn');
  WindowButtonMotionFcn = get(gcf,'WindowButtonMotionFcn');
  WindowButtonUpFcn = get(gcf,'WindowButtonUpFcn');

% Delete any previous text and lines from stretchline
  delete(findobj(gca,'Tag','Box Lines For stretchline'))
  delete(findobj(gca,'Tag','Text1 For stretchline'))
  delete(findobj(gca,'Tag','Text2 For stretchline'))

  % Determine the location of the mouse and create the XData,
  % YData, and ZData for the line coords.
  currrentpoint = get(gca,'CurrentPoint');
  xpos = [currrentpoint(1) currrentpoint(1)];
  ypos = [currrentpoint(3) currrentpoint(3)];
  zpos = [0 0];
  
  % Add some text that displays the current point
  tp1 = text(currrentpoint(1),currrentpoint(3),...
        sprintf('(%8.3f,%8.3f)',currrentpoint(1),currrentpoint(3)), ...
       'Tag','Text1 For stretchline','HorizontalAlignment','center');

  % Create the initial line object
  hs = line('XData',xpos,'YData',ypos,'ZData',zpos, ...
       'Color','r','EraseMode','xor', ...
       'LineStyle','--','Tag','Box Lines For stretchline','LineWidth',2);

  % Add some text that displays the current point
  tp2 = text(currrentpoint(1),currrentpoint(3),...
        sprintf('(%8.3,%8.3f)',currrentpoint(1),currrentpoint(3)), ...
       'EraseMode','xor','Tag','Text2 For stretchline','HorizontalAlignment','center');

  % Set the WindowButtonMotionFcn WindowButtonUpFcn
  set(gcf,'WindowButtonMotionFcn','stretchline move', ...
          'WindowButtonUpFcn','stretchline up')

elseif strcmp(action,'move');  % Mouse moved

  % Get the location of the mouse
  currrentpoint = get(gca,'CurrentPoint');
  
  % Find the handle to the surface plot and text object
  hs = findobj(gca,'Type','line','Tag','Box Lines For stretchline');
  tp2 = findobj(gca,'Type','text','Tag','Text2 For stretchline');

  % Update the locations of the line plot and text object #2
  xpos = get(hs,'XData');
  ypos = get(hs,'YData');
  xpos(2) = [currrentpoint(1)];
  ypos(2) = [currrentpoint(3)];
  set(hs,'XData',xpos,'YData',ypos)
  set(tp2,'Position',[currrentpoint(1) currrentpoint(3) 0],...
          'String',sprintf('(%8.3f,%8.3f)',currrentpoint(1),currrentpoint(3)));

elseif strcmp(action,'up')   
%%%%
%%%% Mouse button released 
%%%
   % Set the WindowButtonDownFcn WindowButtonMotionFcn, and 
   % WindowButtonUpFcn to original values.
   global WindowButtonDownFcn WindowButtonMotionFcn WindowButtonUpFcn
   set(gcf,'WindowButtonDownFcn',WindowButtonDownFcn, ...
           'WindowButtonMotionFcn',WindowButtonMotionFcn, ...
           'WindowButtonUpFcn',WindowButtonUpFcn)
   clear global WindowButtonDownFcn WindowButtonMotionFcn WindowButtonUpFcn

end  

%set(gcf,'WindowButtonDownFcn','', ...
%          'WindowButtonMotionFcn','', ...
%          'WindowButtonUpFcn','')
