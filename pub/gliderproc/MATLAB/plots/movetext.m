function movetext(arg)
% MOVETEXT  Used to grab and move text objects.
%           To activate, type "movetext" or "movetext('on')".
%           Then, move the mouse pointer near the lower left corner of 
%           the text object you want to move.  Depress and hold down 
%           the left mouse button.  When the pointer changes from an arrow
%           to a fleur, drag the text to the new location.  Release the 
%           left mouse button.  This action can be done to any text object 
%           on the figure (including titles and axis labels) at any time 
%           until "movetext('off')" is executed.  This turns off the 
%           movetext capability.
%
%           This function is adapted from a routine written by Drea
%           Thomas at Mathworks Inc., and (signifigantly) enhanced by:
%
% Calls: none
%
%           Brian O. Blanton
%           Curriculum in Marine Science
%           Ocean Processes Numerical Modeling Laboratory
%           15-1A Venable Hall
%           CB# 3300
%           Uni. of North Carolina
%           Chapel Hill, NC
%                    27599-3300
%
%           919-962-4466
%           blanton@marine.unc.edu
%
%           September  1994

% get current window button functions
if nargin==0,
  set(gcf,'windowbuttondownf','movetext(1)')
  return
elseif nargin==1
  if isstr(arg)
    if strcmp(arg,'off')
      set(gcf,'WindowButtonMotionfcn','', ...
              'pointer','arrow',...
              'windowbuttonupfcn','',...
	      'windowbuttondownfcn','lastouch');   	           
    elseif strcmp(arg,'on')
      set(gcf,'windowbuttondownf','movetext(1)')
    else
      error('Invalid string argument to MOVETEXT; type "help MOVETEXT"')
    end
  end
else
  error('Too many arguments to MOVETEXT; type "help MOVETEXT"')
end
    
if arg==1
  if (~strcmp(get(gcf,'Selectiont'),'normal'))
    return
  end
  if(~strcmp(get(gco,'type'),'text')),
    return
  end
  set(gcf,'pointer','fleur');
  set(gco,'units','data');
  set(gco,'Selected','on');
  set(gcf,'windowbuttonmotionfcn','movetext(2)')
  set(gcf,'windowbuttonupfcn','movetext(3)');
elseif arg==2
  pp = [get(gca,'currentpoint')];
  yl = get(gca,'ylim');
  set(gco,'position',[pp(1,:)]);
elseif arg==3
  set(gcf,'WindowButtonMotionfcn','', ...
          'pointer','arrow',...
          'windowbuttonupfcn','');  
  set(gco,'Selected','off');
end
