function longstr = vec2str(inputarr)
% longstr = vec2str(inputarr)
% 
% changes a 1d floating point vector into a vector array of strings
% useful for putting into editable uicontrol
%
%
% Calls: none

% verify vector is 1d and not a matrix
M = size(inputarr, 1);
N = size(inputarr, 2);

if (M ~= 1 & N ~= 1)
  disp('input array must be a 1 dimensional array');
  return
end

for i=1:length(inputarr)
  lilstr = deblank(mat2str(inputarr(i)));
  longstr = str2mat(longstr, lilstr);
end

% remove first string, since it is blank
longstr(1,:)=[];
