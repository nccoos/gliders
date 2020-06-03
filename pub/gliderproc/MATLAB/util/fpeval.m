function [varargout] = fpeval(theFcn, varargin)

% fpeval -- FEVAL by full-path name.
%  [...] = fpeval('theFcn', ...) performs FEVAL with
%   'theFcn' function, given by its full-path name,
%   exclusive of extension.  Use this routine to
%   execute functions that lie outside the Matlab
%   path, including those hidden in "private"
%   areas.
%  [...] = fpeval({theFcnParts}, ...) will use the
%   Matlab "fullfile" function to construct theFcn
%   from a list of its part-names.  For example,
%   {matlabroot, 'toolbox', 'signal', 'private',
%   'chi2conf'} will reach the private chi-square
%   confidence routine in the "signal" toolbox.
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 02-Nov-1998 09:43:22.

if nargin < 1, help(mfilename), return, end

if iscell(theFcn)
	theFcn = fullfile(theFcn{:});
end

% Separate directory and function names.

originalFcn = theFcn;

thePWD = pwd;
theDir = '';
f = find(theFcn == filesep);
if any(f)
	theDir = theFcn(1:f(end));
	theFcn(1:f(end)) = '';
end

% Trim extension, if any.

f = find(theFcn == '.');
if any(f), theFcn(f(1):end) = ''; end

% Change directory, then execute.

try
	if ~isempty(theDir), cd(theDir), end
	if nargout > 0
		varargout = cell(1, nargout);
		[varargout{:}] = feval(theFcn, varargin{:});
	else
		feval(theFcn, varargin{:});
	end
catch
	disp([' ## ' mfilename ' -- An error occurred while attempting:'])
	disp([' ## "' originalFcn '"'])
	disp([' ## ' lasterr])
end

% Restore directory, no matter what.

if ~isempty(theDir), cd(thePWD), end
