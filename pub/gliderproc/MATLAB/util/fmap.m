function array = fmap(fun, array, varargin)
%FMAP   Evaluate a function for each element of an array.
%
%   ARRAY2 = FMAP(FUN, ARRAY1) evaluates the function FUN on all
%   elements of ARRAY.  FUN must be a string and ARRAY1 must be numeric
%   array, a character array or a cell array.
%
%   ARRAY2 = FMAP(FUN, ARRAY1, X1, X2, ...) passes extra arguments to
%   FUN.
%
%   Examples:
%
%     fmap('sqrt', [ 4 9 ])               returns  [ 2 3 ]
%
%     fmap('sqrt', { 4 9 })               returns  { 2 3 }
%
%     fmap('power', { 4 9 }, 3)           returns  { 64 729 }
%
%     fmap('all', { [ 1 1 0 ] [ 1 1 ] })  returns  { 0 1 }

%   Author:      Peter J. Acklam
%   Time-stamp:  2000-02-29 23:58:28
%   E-mail:      jacklam@math.uio.no
%   WWW URL:     http://www.math.uio.no/~jacklam

   error(nargchk(2, Inf, nargin));

   if isnumeric(array) | ischar(array)

      eval(sprintf([ ...
         'for i = 1 : prod(size(array))\n' ...
         '   array(i) = %s(array(i), varargin{:});\n' ...
         'end\n' ], fun));

   elseif isa(array, 'cell')

      eval(sprintf([ ...
         'for i = 1 : prod(size(array))\n' ...
         '   array{i} = %s(array{i}, varargin{:});\n' ...
         'end\n' ], fun));

   else

      error([ mfilename ' does not support the class ' ...
               '"' class(array) '".' ]);

   end
