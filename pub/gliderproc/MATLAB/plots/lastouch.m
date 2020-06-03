function lastouch
% lastouch 
%
% Abstract: This function keeps track of last object and type touched in
%   a figure window.  Figure handles touched are kept in globals.
%
% Usage: windowbuttondown callback function, not to be called directly.
%
% Calls: none
%
% Sara Haines, April 1995
% 
%

figNUM=gcf;
figNUM = watchon;

% determine globals
global LASTOBJECT LASTTYPE LASTAXIS LASTFIGURE LASTCONTROL LASTMENU
global LASTTEXT LASTLINE LASTPATCH LASTIMAGE LASTSURFACE

% set last object and type touched
LASTOBJECT = get(gcf, 'CurrentObject');
if isempty(LASTOBJECT)
  LASTOBJECT = gcf;
end
LASTTYPE = get(LASTOBJECT, 'Type');
LASTFIGURE = figNUM;

% find open windows that need updating
figCHAXIS = findfig('Edit Axis Limits');
figLABEL = findfig('Edit Labels');

% find uimenu indicators
uiTYPE = findobj(LASTFIGURE, 'type', 'uimenu', 'Tag', 'PrType');
uiOBJ = findobj(LASTFIGURE, 'type', 'uimenu', 'Tag', 'PrObject');

% find all the figure objects that are axes and children of axes.
figOBJ = findobj(LASTFIGURE, 'type', 'axes');
figOBJ = findobj(figOBJ);
    
if strcmp( get(LASTOBJECT, 'selected'), 'off')
  % set selected off for each one
  set(figOBJ, 'selected', 'off');
end

  % set handle depending on type
if ( strcmp(LASTTYPE, 'figure') )
  LASTFIGURE = LASTOBJECT;
elseif ( strcmp(LASTTYPE, 'uimenu') )
  LASTMENU = LASTOBJECT;
elseif ( strcmp(LASTTYPE, 'uicontrol') )
  LASTCONTROL = LASTOBJECT;
elseif ( strcmp(LASTTYPE, 'axes') )
  LASTAXIS = LASTOBJECT;
  set(LASTOBJECT, 'selected', 'on');
  if (figCHAXIS)
    EditAxis('reset','newaxestouched');
  end
  if (figLABEL)
    EditLabel('reset','newaxestouched');
  end
elseif ( strcmp(LASTTYPE, 'text') )
  LASTTEXT = LASTOBJECT;
  set(LASTOBJECT, 'selected', 'on');
elseif ( strcmp(LASTTYPE, 'line') )
  LASTLINE = LASTOBJECT;
  set(LASTOBJECT, 'selected', 'on');
elseif ( strcmp(LASTTYPE, 'patch') )
  LASTPATCH = LASTOBJECT;
  set(LASTOBJECT, 'selected', 'on');
elseif ( strcmp(LASTTYPE, 'image') )
  LASTIMAGE = LASTOBJECT;
  set(LASTOBJECT, 'selected', 'on');
end

if (uiTYPE)
  set(uiTYPE, 'Label', LASTTYPE);
end
if (uiOBJ)
  set(uiOBJ, 'Label', num2str(LASTOBJECT,6));
end

watchoff(figNUM);
