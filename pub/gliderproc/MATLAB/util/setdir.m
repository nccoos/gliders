function theResult = setdir(theCommand, theTitle)

% setdir -- Dialog for setting directory.
%  setdir (no argument) displays a dialog for
%   selecting the directory to be made current,
%   starting from the present working directory.
%   Existing directories are prefixed by '>' in
%   in the file-list.  Navigation is accomplished
%   through single-clicks on the controls.
%  setdir([], 'theTitle') sets the dialog name
%   to theTitle.
%
%   "Cancel" -- No directory change.
%   "Select ..." -- Select the named directory.
%   "New" -- Create a new directory.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 30-Dec-1999 10:35:32.
% Updated    01-Jan-2000 08:34:38.

persistent result

if nargin < 1, theCommand = ''; end
if nargin < 2, theTitle = ''; end

if isempty(theCommand), theCommand = 'create'; end

switch lower(theCommand)
case 'closerequestfcn'
	result = [];
	theDialog = gcbf;
	if isempty(theDialog), theDialog = gcf; end
	delete(theDialog)
	return
case 'callback'
	theDialog = gcbf;
	if isempty(theDialog), theDialog = gcf; end
	switch lower(get(gcbo, 'Tag'))
	case 'up'
		s = get(gcbo, 'String');
		v = get(gcbo, 'Value');
		for i = v+1:length(s)
			cd ..
		end
		feval(mfilename, 'update')
	case 'down'
		s = get(gcbo, 'String');
		v = get(gcbo, 'Value');
		x = s{v};
		if x(1) == '>'
			cd(x(2:end))
			feval(mfilename, 'update')
		end
	case 'cancel'
		result = [];
		delete(theDialog)
	case 'new'
		try
			set(theDialog, 'WindowStyle', 'normal')
			s.NewFolderName = 'untitled folder';
			isModal = ~any(findstr(computer, 'pcwin'));
			s = guido(s, 'New Folder', isModal);
			set(theDialog, 'WindowStyle', 'modal')
			if ~isempty(s)
				try
					mkdir(s.NewFolderName)
					cd(s.NewFolderName)
				catch
					disp(lasterr)
				end
			end
		catch
		end
		feval(mfilename, 'update')
		return
	case 'okay'
		f = findobj(theDialog, 'Tag', 'up');
		s = get(f, 'String');
		result = pwd;
		delete(theDialog)
	otherwise
	end
	return
case 'keypressfcn'
	theDialog = gcbf;
	if isempty(theDialog), theDialog = gcf; end
	theKey = lower(get(theDialog, 'CurrentCharacter'));
	if lower(theKey) >= 'a' & lower(theKey) < 'z'
		h = findobj(theDialog, 'Type', 'uicontrol', 'Tag', 'down');
		s = get(h, 'String');
		theIndex = 0;
		for i = 1:length(s)
			theName = lower(s{i});
			if theName(1) == '>', theName(1) = ''; end
			if theName(1) > theKey
				break
			elseif theName(1) < theKey
				theIndex = i;
			else
				theIndex = i;
				break
			end
		end
		if any(theIndex)
			set(h, 'Value', theIndex, 'ListBoxTop', theIndex)
		end
	end
	return
case 'update'
	d = dir;
	s = [];
	theIndex = [];
	for i = 1:length(d)
		theName = d(i).name;
		if d(i).isdir
			theName = ['>' theName];
			if isempty(theIndex)
				theIndex = i;
			end
		end
		s{end+1} = theName;
	end
	if isempty(s), s = {'(folder is empty)'}; end
	if isempty(theIndex), theIndex = 1; end
	p = pwd;
	if p(1) ~= filesep, p = [filesep p]; end
	if p(end) ~= filesep, p(end+1) = filesep; end
	index = find(p == filesep);
	t = [];
	for i = 1:length(index)-1
		t{i} = p(index(i)+1:index(i+1)-1);
	end
	theDialog = gcbf;
	if isempty(theDialog), theDialog = gcf; end
	h = findobj(theDialog, 'Type', 'uicontrol', 'Tag', 'up');
	set(h, 'String', t , 'Value', length(t))
	h = findobj(theDialog, 'Type', 'uicontrol', 'Tag', 'down');
	set(h, 'String', s, 'Value', theIndex)
	h = findobj(theDialog, 'Type', 'uicontrol', 'Tag', 'okay');
	set(h, 'String', ['Select ' t{end}])
	return
case 'create'
	theOldPWD = pwd;
	if isempty(theTitle), theTitle = 'Set Directory'; end
	theFigure = figure( ...
					'Name', theTitle, ...
					'NumberTitle', 'off', ...
					'WindowStyle', 'modal', ...
					'CloseRequestFcn', 'setdir CloseRequestFcn', ...
					'KeyPressFcn', 'setdir KeyPressFcn' ...
					);
	width = 300;
	height = 200;
	pos = get(theFigure, 'Position');
	pos(1) = pos(1) + 100;
	pos(2) = pos(2)+pos(4)-height - 100;
	pos(3) = width;
	pos(4) = height;
	set(theFigure, 'Position', pos)
	h = [];
	h(end+1) = uicontrol(theFigure, ...
					'Style', 'popupmenu', ...
					'String', {'-'}, ...
					'Value', 1, ...
					'Tag', 'up');
	h(end+1) = uicontrol(theFigure, ...
					'Style', 'listbox', ...
					'FontSize', 12', ...
					'FontWeight', 'bold', ...
					'String', {'-'}, ...'
					'Value', 1, ...
					'Tag', 'down');
	h(end+1) = uicontrol(theFigure, ...
					'Style', 'pushbutton', ...
					'String', 'Cancel', ...
					'BackgroundColor', [10 5 5]/10, ...
					'Tag', 'cancel');
	h(end+1) = uicontrol(theFigure, ...
					'Style', 'pushbutton', ...
					'String', 'Okay', ...
					'BackgroundColor', [5 10 5]/10, ...
					'Tag', 'okay');
	h(end+1) = uicontrol(theFigure, ...
					'Style', 'pushbutton', ...
					'String', 'New', ...
					'BackgroundColor', [5 5 10]/10, ...
					'Tag', 'new');


	theFontName = get(0, 'DefaultUIControlFontName');
	theFontSize = 12;
	theFontWeight = 'bold';

	set(h, ...
			'FontName', theFontName, ...
			'FontSize', theFontSize, ...
			'FontWeight', theFontWeight, ...
			'Callback', [mfilename ' Callback'])
			
	x = inf;
	
	theLayout = [
					x x 1 1 1 1 1 x x
					2 2 2 2 2 2 2 2 2
					2 2 2 2 2 2 2 2 2
					2 2 2 2 2 2 2 2 2
					2 2 2 2 2 2 2 2 2
					2 2 2 2 2 2 2 2 2
					3 3 4 4 4 4 4 5 5
				];
				
	uilayout(h, theLayout)
	
	feval(mfilename, 'update')
	
	waitfor(theFigure)
	
	if isempty(result), cd(theOldPWD); end
	if nargout > 0
		theResult = result;
	else
		disp(pwd)
	end
	return
otherwise
	disp(theCommand)
	return
end


% ---------- uilayout ---------- %


function theResult = uilayout(theControls, theLayout, thePosition)

% uilayout -- Layout for ui controls.
%  uilayout(theControls, theLayout) positions theControls
%   according to theLayout, an array whose entries, taken
%   in sorted order, define the rectangular extents occupied
%   by each control.  TheLayout defaults to a simple vertical
%   arrangement of theControls.  A one-percent margin is
%   imposed between controls.  To define a layout region
%   containing no control, use Inf.
%  uilayout(..., thePosition) confines the controls to the
%   given normalized position of the figure.  This syntax
%   is useful for embedding controls within a frame.
%  uilayout (no argument) demonstrates itself.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 18-Apr-1997 08:07:54.

if nargin < 1, theControls = 'demo'; help(mfilename), end

if strcmp(theControls, 'demo')
   theLayout = [1 2;
                3 4;
                5 Inf;
                5 6;
                5 Inf;
                7 8;
                9 10;
                11 12;
                13 14];
   [m, n] = size(theLayout);
   thePos = get(0, 'DefaultUIControlPosition');
   theSize = [n+2 m+2] .* thePos(3:4);
   theFigure = figure('Name', 'UILayout', ...
                      'NumberTitle', 'off', ...
                      'Resize', 'off', ...
                      'Units', 'pixels');
   thePos = get(theFigure, 'Position');
   theTop = thePos(2) + thePos(4);
   thePos = thePos .* [1 1 0 0] + [0 0 theSize];
   thePos(2) = theTop - (thePos(2) + thePos(4));
   set(theFigure, 'Position', thePos);
   theFrame = uicontrol('Style', 'frame', ...
                        'Units', 'normalized', ...
                        'Position', [0 0 1 1], ...
                        'BackgroundColor', [0.5 1 1]);
   theStyles = {'checkbox'; 'text'; ...
                'edit'; 'text'; ...
                'listbox'; 'text'; ...
                'popupmenu'; 'text'; ...
                'pushbutton'; 'text'; ...
                'radiobutton'; 'text'; ...
                'text'; 'text'};
   theStrings = {'Anchovies?', '<-- CheckBox --', ...
                 'Hello World!', '<-- Edit --', ...
                 {'Now', 'Is', 'The' 'Time' 'For' 'All' 'Good', ...
                  'Men', 'To', 'Come' 'To' 'The' 'Aid' 'Of', ...
                  'Their' 'Country'}, ...
                 '<-- ListBox --', ...
                 {'Cheetah', 'Leopard', 'Lion', 'Tiger', 'Wildcat'}, ...
                 '<-- PopupMenu --', ...
                 'Okay', '<-- PushButton --', ...
                 'Cream?', '<-- RadioButton --', ...
                 'UILayout', '<-- Text --'};
   theControls = zeros(size(theStyles));
   for i = 1:length(theStyles)
      theControls(i) = uicontrol('Style', theStyles{i}, ...
                                 'String', theStrings{i}, ...
                                 'Callback', ...
                                 'disp(int2str(get(gcbo, ''Value'')))');
   end
   set(theControls(1:2:length(theControls)), 'BackGroundColor', [1 1 0.5])
   set(theControls(2:2:length(theControls)), 'BackGroundColor', [0.5 1 1])
   thePosition = [1 1 98 98] ./ 100;
   uilayout(theControls, theLayout, thePosition)
   set(theFrame, 'UserData', theControls)
   theStyles, theLayout, thePosition
   if nargout > 0, theResult = theFrame; end
   return
end

if nargin < 2, theLayout = (1:length(theControls)).'; end
if nargin < 3, thePosition = [0 0 1 1]; end

a = theLayout(:);
a = a(finite(a));
a = sort(a);
a(diff(a) == 0) = [];

b = zeros(size(theLayout));

for k = 1:length(a)
   b(theLayout == a(k)) = k;
end

[m, n] = size(theLayout);

set(theControls, 'Units', 'Normalized')
theMargin = [1 1 -2 -2] ./ 100;
for k = 1:min(length(theControls), length(a))
   [i, j] = find(b == k);
   xmin = (min(j) - 1) ./ n;
   xmax = max(j) ./ n;
   ymin = 1 - max(i) ./ m;
   ymax = 1 - (min(i) - 1) ./ m;
   thePos = [xmin ymin (xmax-xmin) (ymax-ymin)] + theMargin;
if (1)
   thePos = thePos .* thePosition([3 4 3 4]);
   thePos(1:2) = thePos(1:2) + thePosition(1:2);
end
   set(theControls(k), 'Position', thePos);
end

if nargout > 0, theResult = theControls; end

