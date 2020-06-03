function theResult = findstr1(theText, theString)

% findstr1 -- Find string, using * wildcard.
%  findstr('demo') demonstrates itself.
%  findstr1('theText', 'theString') searches 'theText'
%   for all examples of 'theString', which may include
%   one or more asterisks '*' as wildcards, representing
%   zero or more characters.  The sought-after string may
%   also contain escaped characters, preceeded by backslash
%   '\', and followed by one of '\bfnrt'.  The routine
%   returns or displays the indices of the starts of all
%   qualifying strings.  Not case-sensitive.
%
% Calls: none
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 04-Jan-2000 15:13:15.
% Updated    14-Jun-2001 05:35:04.

% To do:
%
%    1. Need ? wildcard for single character.
%    2. Need $ for end of line.

if nargout > 0, theResult = []; end

if nargin < 1, theText = 'demo'; end

if nargin < 2 & isequal(theText, 'demo')
	help(mfilename)
	theCommand = [mfilename '(''abracadabra'', ''a*b*a'')'];
	disp(theCommand)
	disp(mat2str(eval(theCommand)))
	return
end

if size(theText, 2) == 1, theText = theText.'; end
if size(theString, 2) == 1, theString = theString.'; end

result = [];

special = '\bfnrt';
for i = 1:length(special)
	s = ['\' special(i)];
	theString = strrep(theString, s, sprintf(s));
end

f = find(theString(1:end-1) == '*');
if any(length(f) > 1)
	theString(f(diff(f) == 1)) = '';
end

f = find(theString ~= '*');
if any(f)
	theString = theString(f(1):f(end));
end

theString = ['*' theString '*'];
stars = find(theString == '*');

if all(theString == '*')
	result = 1:length(theText);
	stars = [];
end

len = 0;

for i = 1:length(stars)-1
	s = theString(stars(i)+1:stars(i+1)-1);
	len = len + length(s);
	f = findstr(theText, s);
	if isempty(f)
		result = [];
	elseif i == 1
		result = f;
	elseif any(result)
		okay = find(result+len <= max(f)+length(s));   % Careful.
		result = result(okay);
	end
	if isempty(result), break, end
end

if nargout > 0
	theResult = result;
else
	disp(result)
end
