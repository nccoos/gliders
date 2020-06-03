function dateaxis(theTickAxis, theDateFormat, theBias)

% dateaxis -- Resizeable "datetick" function.
%  dateaxis('theTickAxis', theDateFormat, theBias) converts
%   the labels of 'theTickAxis' {'x' | 'y' | 'z'} to dates
%   in theDateFormat (see "help datestr") and makes the
%   affected axis resizeable.  The Matlab "datenum" or
%   "datestr" that corresponds to zero can be entered as
%   theBias.  More than one axis can be labeled with dates
%    by stringing 'theTickAxis' codes together, as in 'xy'.
%   The input defaults are 'x', 2, and 0, respectively.
%  dateaxis('demo') demonstrates itself.
%
% Calls: none
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 26-May-1998 11:03:32.

if nargin < 1, theTickAxis = 'x'; end

% Demonstration.

if isequal(theTickAxis, 'demo')
	help(mfilename)
	theNow = now;
	t = -50:10:50;
	theTitle = 'Original'; theXLabel = 'x'; theYLabel = 'y';
	for i = 1:2
		subplot(2, 1, i)
		plot([0 -50; 0 0], [-50 0; 0 0], 'r-', t, t, '-o')
		axis(55 * [-1 1 -1 1])
		text(+5, 0, 'now')
		title(theTitle), xlabel(theXLabel), ylabel(theYLabel)
		theTitle = ['dateaxis(''x'', 2, now)'];
		theXLabel = 'Date'; theYLabel = 'Day Number';
	end
	set(gcf, 'Name', 'DateAxis Demo')
	dateaxis('x', 2, theNow)
	figure(gcf)
	return
end

% Defaults.

if nargin < 2, theDateFormat = 2; end
if nargin < 3, theBias = 0; end
if isstr(theBias), theBias = datenum(theBias); end

% Process each 'tick-axis' code.

for k = 1:length(theTickAxis)
	
% Revert to "auto" tick-labels temporarily.
	
	switch upper(theTickAxis(k))
	case {'X', 'Y', 'Z'}
		set(gca, [theTickAxis(k) 'TickMode'], 'auto')
		set(gca, [theTickAxis(k) 'TickLabelMode'], 'auto')
	otherwise
		help(mfilename)
		error([' ## Unknown Tick-Axis Designation: ' theTickAxis(k) '.']);
	end
	
% Convert ticks to date-strings.
	
	theTicks = get(gca, [theTickAxis(k) 'Tick']);
	theTickLabels = cell(size(theTicks));
	for i = 1:length(theTicks)
		theTicklabels{i} = '';
		if rem(i, 2)
			if nargin < 2
				theTickLabels{i} = datestr(theTicks(i)+theBias);
			else
				theTickLabels{i} = datestr(theTicks(i)+theBias, theDateFormat);
			end
		end
	end
	set(gca, [theTickAxis(k) 'Tick'], theTicks, ...
				[theTickAxis(k) 'TickLabel'], theTickLabels)
end

% Make resizeable if called directly.

if isempty(gcbo)
	if nargin < 2
		theResizeFcn = ['dateaxis(''' theTickAxis ''');'];
	elseif ischar(theDateFormat)
		theResizeFcn = ['dateaxis(''' theTickAxis ''', ''' theDateFormat ''', ' num2str(theBias) ');'];
	else
		theResizeFcn = ['dateaxis(''' theTickAxis ''', ' int2str(theDateFormat) ', ' num2str(theBias) ');'];
	end
	set(get(gca, 'Parent'), 'ResizeFcn', theResizeFcn)
end
