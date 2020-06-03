function vec = str2vec(inputstr)
% vec = str2vec(inputstr)
% 
% changes a 2d array of strings (vector array of strings) to
% 1d row-wise vector of floating point values.
%
%
% Calls: none

% verify vector is 1d and not a matrix
M = size(inputstr, 1);
N = size(inputstr, 2);


for i=1:M
  vec = [vec; str2num(deblank(inputstr(i,:)))];
end

% remove first value, since it is null
% vec(1)=[];
