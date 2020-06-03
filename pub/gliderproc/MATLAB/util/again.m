function theResult = again(varargin)

% again -- Button for "Again" actions.
%  again('theCallback') adds an "Again" pushbutton
%   to the current figure, to evaluate 'theCallback'
%   when pressed.  The button handle is returned.
%  again('s1', 's2', ...) joins the string-arguments
%   with blank-separators to form the actual
%   callback.  The word 'then' causes a comma
%   separator to be used.
%  h = again (no argument) returns the handle of
%   the existing "Again" pushbutton.
%  again('demo') demonstrates itself by plotting
%   random numbers each time the button is pressed.
%
% Note: this code needs some work to prevent
%  run-away recursions when it is called from
%  another routine as part of a demo.
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 17-Feb-2000 23:41:04.
% Updated    24-Mar-2000 09:59:05.

% Process the callback.

if any(gcbo)
	oldPointer = get(gcbf, 'Pointer');
	set(gcbf, 'Pointer', 'watch')
	drawnow
	eval(get(gcbo, 'Tag'))
	set(gcbf, 'Pointer', oldPointer)
	return
end

% Return the existing handle.

props = {'Style', 'pushbutton', 'String', 'Again', ...
				'Position', [20 10 60 20]};
h = findobj(gcf, props{:});
if any(h) & nargin < 1 & nargout > 0
	theResult = h;
	return
end

% Create or update the button.

if nargin < 1, varargin{1} = 'demo'; help(mfilename), end

theCallback = '';
for i = 1:length(varargin)
	if i > 1, theCallback = [theCallback ' ']; end
	if isequal(varargin{i}, 'then')
		varargin{i} = ',';
	end
	theCallback = [theCallback varargin{i}];
end

if isequal(theCallback, 'demo')
	theCallback = 'n=ceil(50*rand(1,1))+1;plot(fft(eye(n,n)),''-o''),axis equal';
	eval(theCallback)
end

if isempty(h) & ~isempty(theCallback)
	h = uicontrol(props{:});
	set(h, 'Callback', mfilename, 'Tag', theCallback, ...
			'ToolTipString', theCallback)
elseif ~isempty(theCallback)
	set(h, 'Callback', mfilename, 'Tag', theCallback, ...
			'ToolTipString', theCallback)
end

figure(gcf)

if nargout > 0, theResult = h; end
