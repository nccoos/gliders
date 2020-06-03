function marked = marksafe(varargin)

% marksafe -- Mark data points in (x, y) plot.
%  marksafe('demo') demonstrates itself, using random (x, y)
%   data plotted with EraseMode = 'xor'.
%  marksafe('on') enables marking, in which a mouse click
%   on a plotted (x, y) point marks the site with a symbol.
%   The z-data must be empty, or consist of TRUE (non-zero,
%   marked) and FALSE (zero, not marked) values.
%  marksafe(h) turns marking on for just the lines specified
%   by the handles h.
%  marksafe('off') turns marking off and removes the markers.
%   The z-data of the targetted lines remain marked with 1.
%  marksafe('clear') restores all the plotted data to visibility.
%  marked = marksafe(h) returns the mark-vector (1 = marked;
%   0 = not marked) for the line whose handle is h.
%
% Calls: none
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 12-Jan-2000 09:44:58.
% Updated    18-Jan-2000 23:03:12.

MARKER_TAG = ['_' mfilename '_'];
MARKER_MARKER = '*';
MARKER_SIZE = get(0, 'DefaultLineMarkerSize');
MARKER_COLOR = [1 0 0];
MARKER_BUTTONDOWNFCN = mfilename;
MARKER_ERASEMODE = 'xor';

% Demonstration.

if nargin > 0 & isequal(varargin{1}, 'demo')
	help(mfilename)
	x = linspace(0, 1, 101);
	y  = sin(3*pi*x);
	noise = 2*(rand(size(x)) - 0.5);
	noise(abs(noise) < 0.95) = 0;
	h = plot(x, y+noise, '-o', ...
				'MarkerSize', 4, 'EraseMode', 'xor');
	eval(mfilename)
	if exist('zoomsafe', 'file') == 2
		eval('zoomsafe')
	end
	set(gcf, 'Name', [mfilename ' demo'])
	if nargout > 0, marked = h; end
	return
end

% Get marks of a line.
%  Requires a handle and an output variable.

if nargout > 0 & nargin > 0
	vis = [];
	h = varargin{1};
	if ischar(h), h = eval(h); end
	if ishandle(h)
		if isequal(get(h, 'Type'), 'line')
			if ~isequal(get(h, 'Tag'), MARKER_TAG)
				marked = ~~get(h, 'ZData');
			end
		end
	end
	return
end

% Actions: on, off, clear.

if nargin > 0 & isempty(gcbo)
	if ischar(varargin{1})
		theAction = varargin{1};
		switch theAction
		case 'on'
			varargin = {};
		case 'off'
			h = findobj(gcf, 'Tag', MARKER_TAG);
			if any(h), delete(h), end
			return
		case 'clear'
			h = findobj(gcf, 'Tag', MARKER_TAG);
			if any(h)
				for i = 1:length(h)
					u = get(h(i), 'UserData');
					z = get(u.handle, 'ZData');
					z(u.index) = u.z;
					set(u.handle, 'ZData', z)
				end
				delete(h)
			end
			return
		otherwise
			disp([' ## No such action: "' theAction '"'])
			return
		end
	end
end

% Initialize.

if isempty(gcbo)
	if isempty(varargin)
		h = findobj(gcf, 'Type', 'line');
		varargin{1} = h;
	end
	h = varargin{1};
	set(h, 'ButtonDownFcn', MARKER_BUTTONDOWNFCN)
	for i = 1:length(h)
		z = get(h(i), 'ZData');
		if isempty(z)
			x = get(h(i), 'XData');
			z = zeros(size(x));
			set(h(i), 'ZData', z);
		end
		f = find(z);
		make_marker(h(i), f)
	end
	return
end

% Process a click.  If clicking on the data, mark
%  the closest data point.  If clicking on a marker,
%  restore the corresponding point.

if isempty(varargin), varargin{1} = 'ButtonDownFcn'; end

if length(varargin) > 0 & ischar(varargin{1})
	theEvent = varargin{1};
	switch lower(theEvent)
	case 'buttondownfcn'
		switch get(gcbo, 'Tag')
		case '_marksafe_'   % Delete the marker.
			u = get(gcbo, 'UserData');
			z = get(u.handle, 'ZData');
			z(u.index) = u.z;
			set(u.handle, 'ZData', z);
			delete(gcbo)
		otherwise   % Create a marker.
			p = get(gca, 'CurrentPoint');
			x0 = p(1, 1);
			y0 = p(1, 2);
			x = get(gcbo, 'XData');
			y = get(gcbo, 'YData');
			z = get(gcbo, 'ZData');
			if isempty(z), z = zeros(size(x)); end
			
			theMarker = get(gcbo, 'Marker');
			if isequal(theMarker, MARKER_MARKER)
				MARKER_MARKER = 'o';
			end
			if ~isequal(get(gcbo, 'Marker'), 'none')
				MARKER_SIZE = 2 + get(gcbo, 'MarkerSize');
			end
			if (1)
				MARKER_ERASEMODE = get(gcbo, 'EraseMode');
			end
			
			dx = diff(get(gca, 'XLim'));   % Scale to pixels.
			dy = diff(get(gca, 'YLim'));
			theOldUnits = get(gca, 'Units');
			set(gca, 'Units', 'pixels');
			thePosition = get(gca, 'Position');
			theWidth = thePosition(3);
			theHeight = thePosition(4);
			dx = dx / theWidth;
			dy = dy / theHeight;
			set(gca, 'Units', theOldUnits)
			
			d = abs((x*dy+sqrt(-1)*y*dx - (x0*dy+sqrt(-1)*y0*dx)));
			
			index = find(d == min(d));
			if any(index)
				index = index(1);
				if ~z(index) & 0
					u.handle = gcbo;
					u.index = index;
					u.z = z(index);
					h = line(x(index), y(index),...
							'Marker', MARKER_MARKER, ...
							'MarkerSize', MARKER_SIZE, ...
							'MarkerFaceColor', 'none', ...
							'MarkerEdgeColor', MARKER_COLOR, ...
							'EraseMode', MARKER_ERASEMODE, ...
							'ButtonDownFcn', MARKER_BUTTONDOWNFCN, ...
							'UserData', u, ...
							'Tag', MARKER_TAG);
					z(index) = 1;
					set(gcbo, 'ZData', z)
				else
					h = make_marker(gcbo, index);
				end
			end
		end
	otherwise
		disp(['## No such event: ' theEvent])
	end
end


% ---------- make_marker ---------- %

function theResult = make_marker(h, index)

% make_marker -- Create a marker.
%  make_marker(h, index) places a mark on line h
%   at the index, on behalf of the given mfile.
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 18-Jan-2000 14:11:55.
% Updated    18-Jan-2000 23:03:12.

MARKER_TAG = ['_' mfilename '_'];
MARKER_MARKER = '*';
MARKER_SIZE = get(0, 'DefaultLineMarkerSize');
MARKER_COLOR = [1 0 0];
MARKER_BUTTONDOWNFCN = mfilename;
MARKER_ERASEMODE = 'xor';

x = get(h, 'XData');
y = get(h, 'YData');
z = get(h, 'ZData');
if isempty(z)
	z = zeros(size(x));
end

theMarker = get(h, 'Marker');
if isequal(theMarker, MARKER_MARKER)
	MARKER_MARKER = 'o';
end
if ~isequal(get(h, 'Marker'), 'none')
	MARKER_SIZE = 2 + get(h, 'MarkerSize');
end

if (1), MARKER_ERASEMODE = get(h, 'EraseMode');end

result = zeros(size(index));

for i = 1:length(index)
	u.handle = h;
	u.index = index;
	u.z = z(index);
	result(i) = line(x(index(i)), y(index(i)),...
			'Marker', MARKER_MARKER, ...
			'MarkerSize', MARKER_SIZE, ...
			'MarkerFaceColor', 'none', ...
			'MarkerEdgeColor', MARKER_COLOR, ...
			'EraseMode', MARKER_ERASEMODE, ...
			'ButtonDownFcn', MARKER_BUTTONDOWNFCN, ...
			'UserData', u, ...
			'Tag', MARKER_TAG);
	z(index(i)) = 1;
end

set(h, 'ZData', z)

if nargout > 0, theResult = result; end
