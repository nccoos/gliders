function outstr = substr( str, offset, len )
%SUBSTR Extract a substring out of a string.
%
%   SUBSTR( STRING, OFFSET, LENGTH ) extracts a substring out of STRING
%   with given LENGTH starting at the given OFFSET.  First character is
%   at offset 0.  If OFFSET is negative, starts that far from the end of
%   the string.  If LENGTH is omitted, returns everything to the end of
%   the string.  If LENGTH is negative, removes that many characters
%   from the end of the string.
%
%   Examples:
%
%      Get first character:              substr( string,  0, 1 )
%      Get last character:               substr( string, -1, 1 )
%      Remove first character:           substr( string,  1 )
%      Remove last character:            substr( string,  0, -1 )
%      Remove first and last character:  substr( string,  1, -1 )
%
%   SUBSTR is a Matlab version of the Perl operator with the same name.
%   However, unlike Perl's SUBSTR, no warning is produced if the
%   substring is totally outside the string.
%
% Calls: none

%   Author:      Peter J. Acklam
%   Time-stamp:  2000-02-29 01:38:52
%   E-mail:      jacklam@math.uio.no
%   WWW URL:     http://www.math.uio.no/~jacklam

   % Check number of input arguments.
   error( nargchk( 2, 3, nargin ) );

   n = length(str);

   % Get lower index.
   lb = offset+1;               % From beginning of string.
   if offset < 0
      lb = lb+n;                % From end of string.
   end
   lb = max( lb, 1 );

   % Get upper index
   if nargin == 2               % SUBSTR( STR, OFFSET )
      ub = n;
   elseif nargin == 3           % SUBSTR( STR, OFFSET, LEN )
      if len < 0
         ub = n+len;
      else
         ub = lb+len-1;
      end
      ub = min( ub, n );
   end

   % Extract substring.
   outstr = str( lb : ub );
