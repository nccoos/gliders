function theResult = suspend(theValue)

% suspend -- Control for suspending any process.
%  suspend('demo') demonstrates itself.
%  suspend (no arguments) creates or activates a pushbutton
%   control labeled "Suspend" that can be used to guide the
%   suspension of activities.
%  suspend(0 or 1) sets/gets the state of the control.
%   If the control-value is 1, suspend execution by using
%   "keyboard" from within your procedure.  After resuming,
%   reset the control with "suspend(0)".
%  suspend([]) deletes the control.
%
% Also see: keyboard.
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 26-Jul-2000 13:57:27.
% Updated    27-Jul-2000 13:45:47.

persistent theControl

% Constants.

RED = [1 0 0];
GREEN = [0 1 0];
THE_TAG = '__Suspend__';
N_DEMO = 3;

% Demonstration.

if nargin > 0 & isequal(theValue, 'demo')
	disp([' ## Suspend this process ' int2str(N_DEMO) ...
			' times by clicking "Suspend".'])
	suspend(0)
	count = 0;
	while count < N_DEMO
		drawnow   % Very important.
		if suspend
			count = count + 1;
			disp([' ## Suspended at ' datestr(now)])
			disp([' ## Now entering "keyboard" mode ...'])
			disp([' ## Type "r-e-t-u-r-n" to continue.'])
			keyboard
			disp(' ## Resuming ...')
			suspend(0)
		end
	end
	suspend([])
	disp(' ## Done')
	return
end

% Create or activate the control.

if ~any(gcbo)
	theFigure = findobj('Type', 'figure', 'Tag', THE_TAG);
	if isempty(theFigure)
		theFigure = figure('Name', 'Suspend', 'Visible', 'off', ...
							'Tag', THE_TAG, ...
							'CloseRequestFcn', 'suspend([])');
		theControl = uicontrol(theFigure, 'Style', 'PushButton', ...
					'String', 'Suspend', 'BackgroundColor', GREEN, ...
					'Callback', mfilename);
		pos = get(theControl, 'Position');
		set(theControl, 'Position', [0 0 1 1] .* pos);
		pos = [1 1 0 0] .* get(theFigure, 'Position') + ...
				[0 0 1 1] .* get(theControl, 'Position');
		pos(1:2) = 20;
		p = get(theFigure, 'Position');
		set(theFigure, 'Position', pos, 'Resize', 'off', 'Visible', 'on')
	end
	figure(theFigure)
end

% Toggle the color-state via callback.

if any(gcbo) & isequal(theControl, gcbo)
	theColor = get(gcbo, 'BackGroundColor');
	if isequal(theColor, RED)
		set(gcbo, 'BackgroundColor', GREEN)
	else
		set(gcbo, 'BackgroundColor', RED)
	end
	return
end

% Set the color-state.

if nargin > 0
	if ischar(theValue), theValue = eval(theValue); end
	if isempty(theValue)
		theFigure = findobj('Type', 'figure', 'Tag', THE_TAG);
		delete(theFigure)
		theControl = [];
		return
	elseif isequal(theValue, 0)
		set(theControl, 'BackgroundColor', GREEN)
	else
		set(theControl, 'BackgroundColor', RED)
	end
end

% Get the color-state.

if nargout > 0
	theColor = get(theControl, 'BackgroundColor');
	theResult = isequal(theColor, RED);
	return
end
