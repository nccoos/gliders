function theResult = undoc(theHandle)

% undoc -- Undocumented properties of a handle.
%  undoc(theHandle) returns or lists the names of the
%   undocumented properties of theHandle (default = 0).
%
% Calls: none
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 20-Oct-1999 00:45:25.
% Updated    20-Oct-1999 08:04:08.

if nargout > 0, theResult = {}; end
if nargin < 1, theHandle = 0; end
if ischar(theHandle), theHandle = eval(theHandle); end

if isempty(theHandle), return, end

theWarningState = warning;
warning('off')

theUndocState = get(0, 'hideundocumented');

set(0, 'hideundocumented', 'on')

a = get(theHandle);   % Documented properties.

set(0, 'hideundocumented', 'off')

b = get(theHandle);   % All properties.

set(0, 'hideundocumented', theUndocState)   % Restore.

warning(theWarningState)   % Restore.

theNames = fieldnames(b);

for i = length(theNames):-1:1
	if isfield(a, theNames{i})
		theNames(i) = [];
	end
end

if nargout > 0
	theResult = theNames;
else
	disp(theNames)
end
