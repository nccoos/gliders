function theResult = identical(varargin)

% identical -- Nan-safe "isequal".
%  identical(x, y, ...) returns TRUE if all the
%   arguments are identical in shape and value,
%   even with respect to NaNs.  No distinction
%   is made between the number-like classes.
 
% Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 05-Sep-2001 01:48:57.
% Updated    05-Sep-2001 02:32:14.

if nargout > 0, theResult = []; end
if nargin < 2, help(mfilename), return, end

% Check "isequal" first.

yes = isequal(varargin{:});
if yes
	if nargout > 0
		theResult = yes;
	else
		disp(yes)
	end
	return
end

% Not exactly equal.  Decompose the arguments,
%  checking for equality of the pieces.

x = varargin{1};

for k = 2:length(varargin)
	y = varargin{k};
	yes = isequal(x, y);
	if ~yes
		switch class(x)
		case 'cell'
			if isequal(class(y), 'cell')
				if isequal(size(x), size(y))
					for i = 1:prod(size(x))
						yes = feval(mfilename, x{i}, y{i});
						if ~yes, break, end
					end
				end
			end
		case 'struct'
			if isequal(class(y), 'struct')
				fx = fieldnames(x);
				if isequal(fx, fieldnames(y))
					for i = 1:length(fx)
						gx = getfield(x, fx{i});
						gy = getfield(y, fx{i});
						yes = feval(mfilename, gx, gy);
						if yes, break, end
					end
				end
			end
		case {'char', 'double', 'sparse', 'uint8', 'uint32'}
			nx = isnan(x);
			if isequal(size(x), size(y)) & any(nx(:))
				ny = isnan(y);
				if isequal(nx, ny)
					yes = isequal(x(~nx), y(~ny));
				end
			end
		otherwise
		end
	end
	if ~yes, break, end
end

if nargout > 0
	theResult = yes;
else
	disp(yes)
end
