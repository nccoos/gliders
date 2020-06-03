% [array]=loadname(filename)
% load filename and save data back with name array.
function [array]=loadname(filename)
%
load(filename);
%
slashes=find(filename(1,:)=='/');
if isempty(slashes)==1;
   is=1;
else
   is=slashes(length(slashes))+1;
end
%
dots=find(filename(1,is:length(filename))=='.');
if isempty(dots)==1;
   ie=length(filename);
else
   ie=is+dots(1)-2;
end
%
%filename(is)
if(~isempty(str2num(filename(is))))
array=eval([filename(is+1:ie)]);
else
array=eval(filename(is:ie),filename(is+1:ie));
end
