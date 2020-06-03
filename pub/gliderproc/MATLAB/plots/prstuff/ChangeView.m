function ChangeView(command)
% function ChangeView(command)
%
% Abstract:
%    reduce or enlarge view of the figure window by 10%.
%
% Usage:
%    >> ChangeView([command])
%       where command = 'reduce' (default) or 'enlarge'

global LASTFIGURE
if isempty(LASTFIGURE)
  curfig=gcf;
else 
  curfig=LASTFIGURE;
end

if nargin < 1
  command = 'reduce';
end

pos = get(curfig,'position');
top = pos(2)+pos(4);

if strcmp(command, 'reduce')
  newW = pos(3) - pos(3)*0.10;
  newH = pos(4) - pos(4)*0.10;
  newpos = [pos(1) top-newH newW newH];
else
  newW = pos(3) + pos(3)*0.10;
  newH = pos(4) + pos(4)*0.10;
  newpos = [pos(1) top-newH newW newH];
end

set(curfig,'position',newpos);
