function vis = blinksafe(varargin)

% blinksafe -- Toggle data points in (x, y, z) plot.
%  blinksafe('demo') demonstrates itself, using random (x, y)
%   data plotted with EraseMode = 'xor'.
%  blinksafe('on') enables blinking, in which a mouse click
%   on a plotted (x, y, z) point makes the point invisible
%   and marks the site with a distinctive dot.  The z-value
%   at that point is set to NaN, and its original value is
%   remembered for later restoration.  The proximity of the
%   click to a point is determined in the (x, y) plane only.
%  blinksafe(h) turns blinking on for just the lines specified
%   by the handles h.
%  blinksafe('off') turns blinking off and removes the markers.
%   Points invisible at this stage will remain invisible,
%   since the corresponding z values will now be NaN.
%  blinksafe('clear') restores all the plotted data to visibility.
%  vis = blinksafe(h) returns the visibility-vector (1 = visible;
%   0 = not visible) for the line whose handle is h.
 %
% Calls: none

% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 12-Jan-2000 09:44:58.
% Updated    18-Jan-2000 15:15:47.

BLINKER_TAG = ['_' mfilename '_'];
BLINKER_MARKER = '*';
BLINKER_SIZE = get(0, 'DefaultLineMarkerSize');
BLINKER_COLOR = [1 0 0];
BLINKER_BUTTONDOWNFCN = mfilename;

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
	if nargout > 0, vis = h; end
	return
end

% Get visibility of a line.
%  Requires a handle and an output variable.

if nargout > 0 & nargin > 0
	vis = [];
	h = varargin{1};
	if ischar(h), h = eval(h); end
	if ishandle(h)
		if isequal(get(h, 'Type'), 'line')
			if ~isequal(get(h, 'Tag'), BLINKER_TAG)
				vis = isfinite(get(h, 'ZData'));
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
			h = findobj(gcf, 'Tag', BLINKER_TAG);
			if any(h), delete(h), end
			return
		case 'clear'
			h = findobj(gcf, 'Tag', BLINKER_TAG);
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
	set(h, 'ButtonDownFcn', BLINKER_BUTTONDOWNFCN)
	for i = 1:length(h)
		z = get(h(i), 'ZData');
		if isempty(z)
			x = get(h(i), 'XData');
			z = zeros(size(x));
			set(h(i), 'ZData', z);
		end
	end
	return
end

% Process a click.  If clicking on the data, make
%  the closest data point invisible.  If clicking
%  on a "blinker", restore the visibility of the
%  corresponding point.

if isempty(varargin), varargin{1} = 'ButtonDownFcn'; end

if length(varargin) > 0 & ischar(varargin{1})
	theEvent = varargin{1};
	switch lower(theEvent)
	case 'buttondownfcn'
		switch get(gcbo, 'Tag')
		case '_blinksafe_'   % Restore visibility; delete the blinker.
			u = get(gcbo, 'UserData');
			z = get(u.handle, 'ZData');
			z(u.index) = u.z;
			set(u.handle, 'ZData', z);
			delete(gcbo)
		otherwise   % Make invisible; create a blinker.
			p = get(gca, 'CurrentPoint');
			x0 = p(1, 1);
			y0 = p(1, 2);
			x = get(gcbo, 'XData');
			y = get(gcbo, 'YData');
			
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
				z = get(gcbo, 'ZData');
				if isempty(z), z = zeros(size(x)); end
				if isfinite(z(index)) & 0
					u.handle = gcbo;
					u.index = index;
					u.z = z(index);
					theMarker = get(gcbo, 'Marker');
					if isequal(theMarker, BLINKER_MARKER)
						BLINKER_MARKER = 'o';
					end
					h = line(x(index), y(index),...
							'Marker', BLINKER_MARKER, ...
							'MarkerSize', BLINKER_SIZE, ...
							'MarkerFaceColor', 'none', ...
							'MarkerEdgeColor', BLINKER_COLOR, ...
							'EraseMode', 'xor', ...
							'ButtonDownFcn', BLINKER_BUTTONDOWNFCN, ...
							'UserData', u, ...
							'Tag', BLINKER_TAG);
					z(index) = nan;
					set(gcbo, 'ZData', z)
				else
					h = make_blinker(gcbo, index);
				end
			end
		end
	otherwise
		disp(['## No such event: ' theEvent])
	end
end

% ---------- make_blinker ---------- %

function theResult = make_blinker(h, index)

% make_blinker -- Create a blinker.
%  make_blinker(h, index) places a blinker
%   on line h at the given index.
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 18-Jan-2000 14:11:55.
% Updated    18-Jan-2000 14:11:55.

BLINKER_TAG = ['_' mfilename '_'];
BLINKER_MARKER = '*';
BLINKER_SIZE = get(0, 'DefaultLineMarkerSize');
BLINKER_COLOR = [1 0 0];
BLINKER_BUTTONDOWNFCN = mfilename;

result = zeros(size(h));

for i = 1:length(h)
	x = get(h(i), 'XData');
	y = get(h(i), 'YData');
	z = get(h(i), 'ZData');
	if isempty(z)
		z = zeros(size(x));
	end
	theMarker = get(h(i), 'Marker');
	if isequal(theMarker, BLINKER_MARKER)
		BLINKER_MARKER = 'o';
	end
	if ~isequal(get(gcbo, 'Marker'), 'none')
		BLINKER_SIZE = 2 + get(gcbo, 'MarkerSize');
	end
	
	if isfinite(z(index))
		u.handle = h(i);
		u.index = index;
		u.z = z(index);
		result(i) = line(x(index), y(index),...
				'Marker', BLINKER_MARKER, ...
				'MarkerSize', BLINKER_SIZE, ...
				'MarkerFaceColor', 'none', ...
				'MarkerEdgeColor', BLINKER_COLOR, ...
				'EraseMode', 'xor', ...
				'ButtonDownFcn', BLINKER_BUTTONDOWNFCN, ...
				'UserData', u, ...
				'Tag', BLINKER_TAG);
		z(index) = nan;
		set(h(i), 'ZData', z)
	end
end

if nargout > 0, theResult = result; end
