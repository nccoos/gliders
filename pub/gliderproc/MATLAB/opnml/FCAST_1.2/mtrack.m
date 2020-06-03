function mtrack(X,Y,navTimes,varargin);
%MTRACK Draw a trackline on a figure
%
%   MTRACK draws navigation tracklines on a figure. The trackline
%   itself is optionally annontated with tick marks, time labels, and
%   date labels.
%
%   MTRACK is a modification of M_MAP's M_TRACK, that does not 
%   project the lon/lat coordinates into the map projection coordinate
%   system.  It draws directly in (x,y), which may of course be (lo,la).
%   MTRACK tags objects with 'mtrack*' instead of 'm_track*'.  
%   See M_MAP's M_TRACK for options, and DATENUM (part of the timefun
%   toolbox from RPS) for computing navigation times.
%
%   MTRACK (lon,lat) draws just a plain line. lon&lat are in decimal
%   degrees, +N, -S, +E, -W.
%
%   MTRACK (lon,lat,navtimes) draws a line, with tick marks every
%   hour, time labels every four hours, and date labels every twelve
%   hours. navtimes is in MatLab "serial date numbers," representing the
%   number of days since January 1, 0000. By convention, ticks and 
%   time labels are drawn on the starboard side, dates on the port.
%
%   MTRACK (lon,lat,navtime, 'string', property/value pairs) can be
%   used to change tick marks, time and date label properties. Allowable
%   combinations are:
%
%   'ticks'		tickmark interval in minutes, default=60
%   'times'		time label interval in minutes, default=240
%   'dates'		date label interval in hours, default=12
%   'timef[ormat]'	format of time string, see datestr(), default=15
%   'datef[ormat]'	format of date string, see datestr(), default=2
%   'color'		color of track/labels, default is black
%   'linew[idth]'	width of trackline, default is current
%   'lines[tyle]'	style of line, default is solid line
%   'fonts[ize]'	size of font, default is current
%   'fontn[ame]'	name of font, default is current
%   'fontw[eight]'	weight of font, default is current
%      'clip',         'on' or 'off' (clipping to map)
%
%   time labels need to be whole multiples of tick intervals. date
%   labels need to be whole multiples of time labels. using '0' for
%   any value will tick/label all points. using a negative number
%   will suppress tick/label.

% m_track.m, Peter Lemmond, peter@whoi.edu 13/Nov/98
% RP - 14/Nov/98 - corrected angle for first label, added tags, added CLIP
%                  options, made labels always face upwards
% This is a modification of m_track.m that does not need the projection
% specifications.  It draws directly in data coordinates, be it meters
% or Lo/La/.  BOB 19 Apr, 99.



numinputs = nargin;			% save this

TICKS = 60;				% default of 60 minute ticks
TIMES = 240;				% default of 4 hour times
DATES = 720;				% default of 12 hour dates
TIMEF = 15;				% default of HH:MM
DATEF = 2;				% default of mm/dd/yy
COLOR = 'k';				% default is black
LINES = '-';				% default is solid line
LINEW = get(gca,'linewidth');		% default is current width
FONTS = get(gca,'fontsize');		% default is current fontsize
FONTN = get(gca,'fontname');		% default is current fontname
FONTW = get(gca,'fontweight');		% default is current fontname
CLIP='on';

MINSPERDAY = 1440;

% need at least X & Y vectors

if numinputs < 2
  disp ('Need at least X & Y vectors!');
  return;
else
  l=length(Y);
  m=length(X);
  if (l ~= m)
    disp ('long and lat vectors must be the same length!');
    return;
  end;
end;


% look at any options

k=1;
while k<length(varargin),
  optn=[lower(varargin{k}) '   '];
  switch optn(1:5),
    case 'ticks',
      TICKS=varargin{k+1};
    case 'times',
      TIMES=varargin{k+1};
    case 'dates',
      DATES=varargin{k+1};
    case 'timef',
      TIMEF=varargin{k+1};
    case 'datef',
      DATEF=varargin{k+1};
    case 'color',
      COLOR=varargin{k+1};
    case 'linew',
      LINEW=varargin{k+1};
    case 'lines',
      LINES=varargin{k+1};
    case 'fontn',
      FONTN=varargin{k+1};
    case 'fontw',
      FONTW=varargin{k+1};
    case 'fonts',
      FONTS=varargin{k+1};
    case 'clip ',
      CLIP=varargin{k+1};
  end;
  k=k+2;
end;

DATES = DATES*60;			% want things in minutes

if (TICKS < 0 )
  numinputs = 2;			% w/o ticks, just do line
elseif (TIMES < 0)
  TIMES = realmax;
  DATES = realmax;
elseif (DATES < 0)
  DATES = realmax;
end


if TICKS == 0
  tickAll = 1;
  TICKS = eps;
else
  tickAll = 0;
end;

if TIMES == 0
  timeAll = 1;
  TIMES = eps;
else
  timeAll = 0;
end;

if DATES == 0
  dateAll = 1;
  DATES = eps;
else
  dateAll = 0;
end;

line(X,Y,'linest',LINES,'linewi',LINEW,'color',COLOR,'tag','mtrack_line','clip',CLIP);

% we're done if only lon/lat given

if (numinputs < 3)
  return;
end;

n=length(navTimes);
if (l ~= n)
  disp('X, Y, and navtimes vectors must be same length');
  return;
end;


% really don't want to loop, but ...

lastTick = -1;
lastTime = -1;
lastDate = -1;

lastLat = Y(1)-(Y(2)-Y(1));
lastLon = X(1)-(X(2)-X(1));

navMinutes = round(navTimes*MINSPERDAY);% convert to whole minutes
                                        % round instead of floor - RP 15/11/98
for i=1:n

  if (~(rem(navMinutes(i),TICKS)) | tickAll)
    dlat = Y(i) - lastLat;
    dlon = X(i) - lastLon;
    angle = atan2(dlat,dlon)*180/pi - 90;
    
    % Make sure labels always face up.
    if abs(angle)<90,
       leadstr=' ';tailstr='';ang_off=0;tmlab='left';datlab='right';
    else
       leadstr='';tailstr=' ';ang_off=180;tmlab='right';datlab='left';
    end;
    
    if ((navMinutes(i) ~= lastTick) | tickAll)
      text(X(i), Y(i), '-', 'vertical', 'middle', 'horizontal', 'left', ...
	  'color', COLOR, 'fontsize', FONTS, 'fontname', FONTN,...
          'fontweight', FONTW, 'rotation', angle,'tag','mtrack_tick');
      lastTick=navMinutes(i);
    end
    
    if (~(rem(navMinutes(i),TIMES)) | timeAll)
      if ((navMinutes(i) ~= lastTime) | timeAll)
	text(X(i), Y(i), [leadstr leadstr datestr(navTimes(i),TIMEF) tailstr tailstr], ...
	    'color', COLOR, 'fontsize', FONTS, 'fontname', FONTN, 'fontweight', FONTW, ...
	    'vertical', 'middle', 'horizontal', tmlab, 'rotation', angle+ang_off,...
	    'tag','mtrack_time');
	lastTime=navMinutes(i);
      end
      
      if (~(rem(navMinutes(i),DATES)) | dateAll)
	if ((navMinutes(i) ~= lastDate) | dateAll)
	  text(X(i), Y(i), [tailstr datestr(navTimes(i),DATEF) leadstr], ...
	      'color', COLOR, 'fontsize', FONTS, 'fontname', FONTN, 'fontweight', FONTW, ...
	      'vertical', 'middle', 'horizontal', datlab, 'rotation', angle-ang_off,...
	      'tag','mtrack_date');
	  lastDate=navMinutes(i);
	end
	
      end
    end
  end
  
  lastLat = Y(i);
  lastLon = X(i);
  
end



