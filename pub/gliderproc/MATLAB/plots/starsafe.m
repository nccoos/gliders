function [x, y] = starsafe(x0, y0, theSize, theColor, varargin)

% starsafe -- Star symbols.
%  starsafe(x0, y0, theSize, theColor, ...) draws stars as patchs,
%   centered on (x0, y0), with theSize and theColor.  Additional
%   name/value pairs are passed directly to the "patch" routine.
%   The star sizes are given in the units of the y-axis.
%  [xx, yy] = starsafe(...) returns the (x, y) coordinates of
%   the stars, one per row, but does not plot them.
%  h = starsafe(...) draws the stars and returns their handles.
%
% Also see: arrowsafe.
%
% Note: this routine is a useful example for dealing with
%  symbol-like entities.
%
% Calls: none
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 13-Jan-2000 16:21:37.
% Updated    13-Jan-2000 17:12:22.

if nargin < 2, y0 = 0; end
if nargin < 3, theSize = 1; end
if nargin < 4, theColor = [0 0 0]; end

% Update.

if nargin < 1
	h = findobj(gcf, 'Type', 'patch', 'Tag', mfilename);
	if any(h)
		for i = 1:length(h)
			u = get(h(i), 'UserData');
			[xx, yy] = feval(mfilename, u(1), u(2), u(3));
			set(h(i), 'XData', xx, 'YData', yy)
		end
	end
	return
end

% Demonstration.

if nargin == 1
	if isequal(x0, 'demo'), x0 = 10; end
	n = x0;
	if ischar(n), n = eval(n); end
	delete(findobj(gcf, 'Type', 'patch', 'Tag', mfilename))
	axis auto
	x0 = (rand(1, n) - 0.5) * n;
	y0 = rand(1, n) - 0.5;
	s = rand(1, n)/10;
	cmap = colormap;
	index = floor(rand(prod(size(x0)), 1) * size(cmap, 1)) + 1;
	c = cmap(index, :);
	feval(mfilename, x0, y0, s, c)
	set(gca, 'XLim', [-n n], 'Ylim', [-1 1])
	feval(mfilename)
	return
end

if length(x0) == 1
	x0 = x0 * ones(size(y0));
elseif length(y0) == 1
	y0 = y0 * ones(size(x0));
end

if length(theSize) == 1
	theSize = theSize * ones(size(x0));
end

if size(theColor, 1) == 1
	theColor = ones(prod(size(x0)), 1) * theColor;
end

oldUnits = get(gca, 'Units');
set(gca, 'Units', 'pixels')
thePosition = get(gca, 'Position');
set(gca, 'Units', oldUnits)
theWidth = thePosition(3);
theHeight = thePosition(4);

axis('manual')
dx = diff(get(gca, 'XLim'));
dy = diff(get(gca, 'YLim'));
dydx = dy / dx;   % Not used.
dxdp = dx / theWidth;   % sci/pixel.
dydp = dy / theHeight;   % sci/pixel.

scale = dxdp / dydp;

f = zeros(1, 10);
f(2) = 1;
f = ifft(f)*length(f);
f(2:2:end) = f(2:2:end) * 0.38;
f(end+1) = f(1);
xs = -imag(f);
ys = real(f);

h = zeros(size(x0));

for i = 1:prod(size(x0))
	xstar = xs * theSize(i) * scale + x0(i);
	ystar = ys * theSize(i) + y0(i);
	cstar = theColor(i, :);
	ustar = [x0(i) y0(i) theSize(i)];
	if nargout == 2
		x(i, 1:length(xstar)) = xstar;
		y(i, 1:length(ystar)) = ystar;
	else
		if length(varargin) > 1
			h(i) = patch(xstar, ystar, cstar, ...
				'Tag', mfilename, ...
				'UserData', ustar);
		else
			h(i) = patch(xstar, ystar, cstar, ...
				'Tag', mfilename, ...
				'UserData', ustar);
		end
	end
end

set(gcf, 'ResizeFcn', mfilename)
