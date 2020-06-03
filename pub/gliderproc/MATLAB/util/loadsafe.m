function [theResult, theLineNo] = loadsafe(theFilename)

% loadsafe -- Load an ascii file.
%  loadsafe('theFilename') loads the data from
%   'theFilename', an ascii file, alloting one
%   row of the result for each line of the file.
%   Warnings about questionable lines are posted.
%   No-data entries are marked by NaN.  Matlab
%   comments and blank-lines are ignored.  If
%   no output argument is given, the result is
%   assigned to the root-name of the file, as
%   with regular Matlab "load".
%  [theResult, theLineNo] = ... also returns the
%   original line-numbers corresponding to the
%   rows of theResult.
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 19-Oct-1998 22:36:04.
% Updated    20-Oct-1998 13:38:57.

if nargout > 0, theResult = []; end

if nargin < 1
	help(mfilename)
	theFilename = '*';
end

if any(theFilename == '*')
	[theFile, thePath] = uigetfile(theFilename, 'Select a File:');
	if ~any(theFile), return, end
	if thePath(length(thePath) ~= filesep)
		thePath = [thePath filesep];
	end
	theFilename = [thePath theFile];
end

fp = fopen(theFilename, 'r');

count = 0;
bad = 0;
len = 0;
max_len = 0;
while 1
	s = fgetl(fp);
	if isequal(s, -1), break, end
	f = find(s == '%');
	if any(f), s(f(1):length(s)) = ''; end
	while(length(s) > 0 & s(1) == ' ')
		s(1) = '';
	end
	if length(s) > 0 & s(1) ~= '%'
		count = count+1;
		t = ['[' s ']'];
		bad_line = 0;
		data = [];
		eval('data = eval(t);', 'bad_line = 1;');
		if ~bad_line
			max_len = max(max_len, length(data));
		else
			bad = bad + 1;
			disp([' ## ??? line ' int2str(count) ': ' s])
		end
	end
end

if bad > 0
	disp(' ')
	disp([' ## Number of questionable lines: ' int2str(bad)])
	disp(' ')
end

frewind(fp)

result = nan * zeros(count, max_len);

lineno = zeros(count, 1);
line = 0;

count = 0;

while (1)
	s = fgetl(fp);
	if isequal(s, -1), break, end
	line = line + 1;
	while(length(s) > 0 & s(1) == ' ')
		s(1) = '';
	end
	if length(s) > 0 & s(1) ~= '%'
		count = count+1;
		lineno(count) = line;
		t = ['[' s ']'];
		bad_line = 0;
		data = [];
		eval('data = eval(t);', 'bad_line = 1;');
		if ~bad_line & length(data) > 0
			result(count, 1:length(data)) = data;
		end
	end
end

fclose(fp);

if nargout > 0
	theResult = result;
	theLineNo = lineno;
else
	theName = theFilename;
	f = find(theName == filesep);
	if any(f), theName(1:f(length(f))) = ''; end
	f = find(theName == '.');
	if any(f), theName(f(1):length(theName)) = ''; end
	assignin('caller', theName, result)
end
