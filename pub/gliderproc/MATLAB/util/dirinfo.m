function result = dirinfo

% dirinfo -- Information about current-directory.
%  dirinfo (no argument) returns information about
%   the current-directory: number of files, directories,
%   and bytes.  The tally works recursively through all
%   the embedded directories.
 
% Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 25-Sep-2001 15:15:24.
% Updated    25-Sep-2001 15:20:54.

files = 0;
dirs = 0;
bytes = 0;

d = dir;

for i = 1:length(d)
	if d(i).isdir
		cd(d(i).name)
		y = feval(mfilename);
		files = files + y.files;
		dirs = dirs + 1;
		bytes = bytes + y.bytes;
		cd ..
	else
		files = files + 1;
		bytes = bytes + d(i).bytes;
	end
end

x.files = files;
x.dirs = dirs;
x.bytes = bytes;

if nargout > 0
	result = x;
else
	disp(x)
end
