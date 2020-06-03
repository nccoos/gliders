
function [b] = unique(a)
%UNIQUE Set unique.
%   UNIQUE(A) for the vector A returns the same values as in A but
%   with no repetitions.  A will be also be sorted.  A can be a cell
%   array of strings.
%
%   Based on Matlab 5.0 compatible code, reworked by Catherine Edwards
%   for compatibility with Matlab v4
%

%   Cell array implementation in @cell/unique.m

if isempty(a), b = a; return, end


  rowvec = size(a,1)==1;
  [b,ndx] = sort(a(:));
  % d indicates the location of matching entries
  n=length(b);
  d = b((1:n-1)')==b((2:n)');
  n = length(a);

test=find(d==0);
b=[b(test); b(length(b))];

if rowvec, 
  b = b.';
  ndx = ndx.'; 
end

end
