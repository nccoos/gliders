function b = distinct(a,flag)
%DISTINCT Set unique.
%   DISTINCT(A) for the array A returns the same values as in A but
%   with no repetitions. This is a scaled down version of the
%   Matlab program UNIQUE. If you do not want sorted rows and other 
%   unnecessary stuff, welcome!
%
%   DISTINCT(A,'rows') for the matrix A returns the unique rows of A.
%
  
if nargin==1 | isempty(flag),
  % Convert matrices and rectangular empties into columns
  if length(a) ~= prod(size(a)) | (isempty(a) & any(size(a)))
     a = a(:);
  end
  % d indicates the location of matching entries
  b=a;
  d = b((1:end-1)')==b((2:end)');
  b(find(d)) = [];
  if nargout==2, % Create position mapping vector
    pos = zeros(size(a));
  end
else
  if ~isstr(flag) | ~strcmp(flag,'rows'), error('Unknown flag.'); end
  b = a;
  [m,n] = size(a);
  if m > 1 & n ~= 0
    % d indicates the location of matching entries
    d = b(1:end-1,:)==b(2:end,:);
  else
    d = zeros(m-1,n);
  end
  d = all(d,2);
  b(find(d),:) = [];
  if nargout==3, % Create position mapping vector
    pos(ndx) = cumsum([1;~d]);
    pos = pos';
  end
end
