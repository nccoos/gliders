function uidelete

% uidelete -- Delete files via dialog.
%  uidelete (no argument) deletes one or more
%   files selected with the "uigetfile" dialog.
%   *** Not for the faint of heart. ***
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 19-Jun-1998 15:17:32.

help(mfilename)

oldPWD = pwd;

thePrompt = 'Delete Which File?';

while (1)
	[theFile, thePath] = uigetfile('*', thePrompt);
	if ~any(theFile), return, end
	if thePath(length(thePath)) ~= filesep
		thePath = [thePath filesep];
	end
	cd(thePath)
	delete([thePath theFile])
	thePrompt = 'Delete Another File?';
end

cd(oldPWD)
