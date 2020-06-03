function timestamp(mfile,adjusthrs)
%TIMESTAMP Add time stamp to the current plot.
%  TIMESTAMP(MFILE) writes the string MFILE and the actual date and time
%  to the lower left corner of the current plot.
%  Time stamps could be removed using the command:
%    delete(get(gca,'UserData'))

%  9-Nov-95, C. Mertens, IfM Kiel
% made comp. with MATLAB 5.2	G.K. Nov 1998
%  8-Aug-06, C. Edwards: changed inputs to allow for time zones, removed pwd

if nargin == 0
  mfile = '';
elseif(~isstr(mfile))
  adjusthrs=mfile;
%else
%  mfile = [pwd,'/',mfile];
end

a = gca;
h = axes('Units','normalized','Position',[0 0 1 1],'Visible','off');
time = fix(clock);

if(nargin>1)
  time=datevec(datestr(time+[0 0 0 adjusthrs 0 0]));
end
stime = sprintf('%s %4.4d/%2.2d/%2.2d %2.2d:%2.2d',mfile,time(1:5));
text(0.91,0.02,stime,'FontSize',6,'HorizontalAlignment','right', ...
     'VerticalAlignment','bottom')
%axes(a)
set(a,'UserData',h);

