function [hy2l,ax,pl]=splotyy(arg1,arg2,arg3,arg4,arg5,arg6,arg7)
% SPLOTYY  Plot graphs with Y tick labels on left and right side.
%         SPLOTYY(x1,y1,x2,y2) plots y1 vs. x1 with y-axis labeling
%         on left, and plots y2 vs. x2 with y-axis labeling on right.
%
%         SPLOTYY(x1,y1,linopts1,x2,y2,linopts2) draws lines according
%         to (optionally) specified line types.  LINOPTS* is a string
%         specified according the line options for PLOT.
%
%         [hy2l] = SPLOTYY(x1,y1,x2,y2) returns the handle of the text
%         object used for y2label.
%
%         [hy2l,ax,pl] = SPLOTYY(x1,y1,x2,y2) additionally returns the
%         handles of the two axes created by plotyy in ax and the
%         handles of the lines created by plotyy in pl.
%
%         SPLOTYY(x1,y1,x2,y2,options) allows for an options
%         vector as follows:
%
%               OPTIONS(1) : 0 for linear x-axis, 1 for log x-axis
%               OPTIONS(2) : 0 for linear y1-axis, 1 for log y1-axis
%               OPTIONS(3) : 0 for linear y2-axis, 1 for log y2-axis
%               OPTIONS(4:5) : x-axis limits, in form [xmin xmax]
%               OPTIONS(6:7) : y1-axis limits, in form [y1min y1max]
%               OPTIONS(8:9) : y2-axis limits, in form [y2min y2max]
%
%               Specify NaN for any option to use default value.
%
%         For example,
%
%               splotyy(x1,y1,'r-',x2,y2,'g:',[0 1 0 1.5 3 nan nan 0 10])
%
%         plots y1 vs. x1 using a red solid line and y2 vs. x2 using
%         a green dotted line, with log y1-axis scaling an x-axis range
%         of 1.5 to 3, the default y1-axis range, and a y2-axis yange
%         of 0 to 10.
%
%         Note:  Using PLOT to replace axes created by SPLOTYY will not
%         replace the second y-axis.  Use SPLOTYY with empty x2 and y2
%         vectors, i.e., plotyy(x1,y1,[],[]).
%
% Calls: none
%
%         See also TITLE, XLABEL, YLABEL, Y2LABEL, SUBPLOT.

% Version:  2.1.1 (March 23, 1995)

%Known bugs:
% Due to a bug in 4.0a on Sun and SGI (and perhaps others)
% setting the ylabels units to normalized (so they stick with the
% axis as the figure is resized) does not work correctly.  In
% this case, the ylabel is still drawn, but it won't follow the axis
% around on the screen if the figure is resized.

% Modified by Samson H. Lee (shl0@lehigh.edu)
% 02/02/93
% Use actual ylabel position determined by plot(x2,y2) for second
% ylabel position.  Position is grabbed before plot is rotated using
% view function.
% 02/03/94
% Added linetype and linecolor specifications.
% Moved y2label to separate function.  Ylabel is all set up except for
% specifying the string.  A separate function y2label uses the given
% handle and sets the string.
% 03/07/94
% Store handles in UserData so Y2LABEL no longer requires handle
% passing.
% 03/21/95 version 2.1
% Added drawnow before getting typ_ylabel_pos because of a suspected
% bug in get()
% 03/23/95 version 2.1.1
% Tag axes as plotyy-axes
% If replacing plotyy axes, delete axes2 and expand axes 5%
% Do not plot axes2 if x2 is empty

% constants:
NUMOPTS  = 9;  % Maximum number of arguments in OPTIONS vector
OI_XLOG  = 1;  % Index of Options vector for x-axis scaling
OI_Y1LOG = 2;  % Index of Options vector for y1-axis scaling
OI_Y2LOG = 3;  % Index of Options vector for y2-axis scaling
OI_XMIN  = 4;  % Index of Options vector for x-axis min limit
OI_XMAX  = 5;  % Index of Options vector for x-axis max limit
OI_Y1MIN = 6;  % Index of Options vector for y1-axis min limit
OI_Y1MAX = 7;  % Index of Options vector for y1-axis max limit
OI_Y2MIN = 8;  % Index of Options vector for y2-axis min limit
OI_Y2MAX = 9;  % Index of Options vector for y2-axis max limit

% error checking:
if nargin<4,
  error('PLOTYY requires at least 4 input arguments.');
elseif nargin>7,
  error('PLOTYY accepts no more than 7 input arguments.');
elseif nargout>3,
  error('PLOTYY returns a maximum of 3 output arguments.');
end

% parse arguments
linopt1=[];
linopt2=[];
options=[];
x1=arg1;
y1=arg2;
if isstr(arg3),
  if nargin<5,
    error('improper syntax');
  end
  linopt1=arg3;
  x2=arg4;
  y2=arg5;
  if nargin>5,
    if isstr(arg6),
      linopt2=arg6;
      if nargin>6,
	options=arg7;
      end
    else
      options=arg6;
    end
  end
else
  x2=arg3;
  y2=arg4;
  if nargin>4,
    if isstr(arg5),
      linopt2=arg5;
      if nargin>5,
	options=arg6;
      end
    else
      options=arg5;
    end
  end
end

% color matrix and mapping matrix
colmat=[1 1 0; 1 0 1; 0 1 1; 1 0 0; 0 1 0; 0 0 1; 1 1 1; 0 0 0];
for i=1:8,
  colmap(i,i)=i;
end

% parse linopt1
lincolstr1=[];
linsty1=[];
if ~isempty(linopt1)
  if sum(linopt1(1)=='ymcrgbwk'), 	% See if first char in argument
    lincolstr1=linopt1(1); 		% is a linetype or a color
    if length(linopt1)>1,
      if sum(linopt1(2)=='.ox+-*:'),
	linsty1(1)=linopt1(2);
	if (length(linopt1)==3) & (linsty1(1)=='-'),
	  if sum(linopt1(3)=='.-'),
	    linsty1(2)=linopt1(3);
	  else,
	    error('invalid linetype specified in LINOPT1');
	  end;
	elseif length(linopt1)~=2,
	  error('invalid linetype specified in LINOPT1');
	end;
      else,
	error('invalid linetype specified in LINOPT1');
      end;
    end;
  elseif sum(linopt1(1)=='.ox+-*:'),
    linsty1(1)=linopt1(1);
    if length(linopt1)>1,
      if sum(linopt1(2)=='-.ymcrgbwk'),
	if (linsty1(1)=='-') & (sum(linopt1(2)=='.-')),
	  linsty1(2)=linopt1(2);
	elseif length(linopt1)==2,
	  if sum(linopt1(2)=='ymcrgbwk'),
	    lincolstr1=linopt1(2);
	  else,
	    error('invalid line color specified in LINOPT1');
	  end;
	else,
	  error('invalid linetype specified in LINOPT1');
	end;
	if length(linopt1)==3,
	  if sum(linopt1(3)=='ymcrgbwk'),
	    lincolstr1=linopt1(3);
	  else;
	    error('invalid linecolor specified in LINOPT1');
	  end;
	end;
      else,
	error('invalid LINOPT1 specified');
      end;
    end;
  else,
    error('invalid LINOPT1 specified');
  end;
end;

% parse linopt2
lincolstr2=[];
linsty2=[];
if ~isempty(linopt2)
  if sum(linopt2(1)=='ymcrgbwk'), 	% See if first char in argument
    lincolstr2=linopt2(1); 		% is a linetype or a color
    if length(linopt2)>1,
      if sum(linopt2(2)=='.ox+-*:'),
	linsty2(1)=linopt2(2);
	if (length(linopt2)==3) & (linsty2(1)=='-'),
	  if sum(linopt2(3)=='.-'),
	    linsty2(2)=linopt2(3);
	  else,
	    error('invalid linetype specified in LINOPT2');
	  end;
	elseif length(linopt2)~=2,
	  error('invalid linetype specified in LINOPT2');
	end;
      else,
	error('invalid linetype specified in LINOPT2');
      end;
    end;
  elseif sum(linopt2(1)=='.ox+-*:'),
    linsty2(1)=linopt2(1);
    if length(linopt2)>1,
      if sum(linopt2(2)=='-.ymcrgbwk'),
	if (linsty2(1)=='-') & (sum(linopt2(2)=='.-')),
	  linsty2(2)=linopt2(2);
	elseif length(linopt2)==2,
	  if sum(linopt2(2)=='ymcrgbwk'),
	    lincolstr2=linopt2(2);
	  else,
	    error('invalid line color specified in LINOPT2');
	  end;
	else,
	  error('invalid linetype specified in LINOPT2');
	end;
	if length(linopt2)==3,
	  if sum(linopt2(3)=='ymcrgbwk'),
	    lincolstr2=linopt2(3);
	  else;
	    error('invalid linecolor specified in LINOPT2');
	  end;
	end;
      else,
	error('invalid LINOPT2 specified');
      end;
    end;
  else,
    error('invalid LINOPT2 specified');
  end;
end;

% map color string to color number
lincol1=0;
lincol2=0;
if ~isempty(lincolstr1),
  lincol1=sum((lincolstr1=='ymcrgbwk')*colmap);
end
if ~isempty(lincolstr2),
  lincol2=sum((lincolstr2=='ymcrgbwk')*colmap);
end

% check for options vector:
if ~isempty(options),
 options(length(options)+1:NUMOPTS)=nan*ones(NUMOPTS-length(options),1);
else
 options=nan*ones(NUMOPTS,1);  % use all default values
end

% first calculate overall x-axis range:
x1min=min(x1(~isnan(x1)));
x2min=min(x2(~isnan(x2)));
x1max=max(x1(~isnan(x1)));
x2max=max(x2(~isnan(x2)));
xrange=[min(x1min,x2min) max(x1max,x2max)];
if ~isnan(options(OI_XMIN)),
 xrange=[options(OI_XMIN) xrange(2)];
end
if ~isnan(options(OI_XMAX)),
 xrange=[xrange(1) options(OI_XMAX)];
end

% If replacing old plotyy plot, delete axes2 and expand axis 5%
if get(gca,'Tag')=='plotyy-axes1',
  axes2 = get(gca,'UserData');
  delete(axes2);
  axespos = get(gca,'Position');
  set(gca,'Position',axespos+[0 0 .05 0]);
end

% If x2 and y2 are empty, then only plot one axis
if isempty(x2),
  plot(x1,y1)
  return
end

% Set up (x2,y2) plot first:
axes2=gca;
p2=plot(x2,y2);
drawnow;
typ_ylabel_pos = get(get(axes2,'YLabel'),'Position');
ylaboffset=-1*typ_ylabel_pos(1);
set(gca,'YDir','rev');  % This line and the next are the guts of plotyy.
view(360-200*eps,-90);  % They allow the function to display y tick
                        % labels on the right hand side of the plot.

% set up (x1,y1) plot now:

% create a new axis in same location as the old axis:
axes1=axes('Position',get(axes2,'Pos'));

p1=plot(x1,y1);

% set both axes to have same x range:
set(axes1,'XLim',xrange);
set(axes2,'XLim',xrange);

% handle OPTIONS vector:
if options(OI_XLOG)==0,
 set(axes1,'XScale','linear');
 set(axes2,'XScale','linear');
elseif options(OI_XLOG)==1,
 set(axes1,'XScale','log');
 set(axes2,'XScale','log');
end
if options(OI_Y1LOG)==0,
 set(axes1,'YScale','linear');
elseif options(OI_Y1LOG)==1,
 set(axes1,'YScale','log');
end
if options(OI_Y2LOG)==0,
 set(axes2,'YScale','linear');
elseif options(OI_Y2LOG)==1,
 set(axes2,'YScale','log');
end
if ~isnan(options(OI_Y1MIN));
 set(axes1,'YLim',get(axes1,'YLim').*[0 1]+[options(OI_Y1MIN) 0]);
end
if ~isnan(options(OI_Y1MAX));
 set(axes1,'YLim',get(axes1,'YLim').*[1 0]+[0 options(OI_Y1MAX)]);
end
if ~isnan(options(OI_Y2MIN));
 set(axes2,'YLim',get(axes2,'YLim').*[0 1]+[options(OI_Y2MIN) 0]);
end
if ~isnan(options(OI_Y2MAX));
 set(axes2,'YLim',get(axes2,'YLim').*[1 0]+[0 options(OI_Y2MAX)]);
end

% now tidy the plot up a bit:
ticklen=get(axes1,'TickLength');
set(axes2,'TickLength',[ticklen(1) ticklen(1)]);
set(axes2,'TickDir',get(axes1,'TickDir'));
set(axes2,'XTickLabels','');
set(axes1,'Box','off');

% If both y1 and y2 are vectors (not matrices) make
% the color of y2 be the second color in the ColorOrder.
% (This is to make the plot aesthetic.)
[m1,n1]=size(y1);
[m2,n2]=size(y2);
if (m1==1 | n1==1) & (m2==1 | n2==1),
 ColorOrd=get(axes1,'ColorOrder');
 if size(ColorOrd,1)~=1, % in case ColorOrder only has 1 color in it
  set(p2,'Color',ColorOrd(2,:));
 end
end

% Set line options if specified
if min([m1 n1])~=1,
  nlin1=n1;
else,
  nlin1=1;
end;
if lincol1>0,
  for i=1:nlin1,
    set(p1(i),'Color',colmat(lincol1,:));
  end;
end;
if ~isempty(linsty1)
  for i=1:nlin1,
    set(p1(i),'LineStyle',linsty1);
  end;
end;
if min([m2 n2])~=1,
  nlin2=n2;
else,
  nlin2=1;
end;
if lincol2>0
  for i=1:nlin2,
    set(p2(i),'Color',colmat(lincol2,:));
  end;
end;
if ~isempty(linsty2)
  for i=1:nlin2,
    set(p2(i),'LineStyle',linsty2);
  end;
end;

% create y2label position:
ylab=text(0,0,'');
save_axes1_units=get(axes1,'Units'); 	% save current state
set(ylab,'Units','pixels'); 		% convert everything to
set(axes1,'Units','pixels'); 		% same units
axes1pos=get(axes1,'Position');
ylabxcoordinate=ylaboffset+axes1pos(3);
ylabycoordinate=typ_ylabel_pos(2);
set(ylab,'Position',[ylabxcoordinate ylabycoordinate]);
set(ylab,'HorizontalAlignment','center');
set(ylab,'VerticalAlignment','top');
set(ylab,'Rotation',90);
set(ylab,'FontSize',get(axes1,'FontSize'));
% Due to a bug in 4.0a on Sun and SGI (and perhaps others)
% setting the ylabels units to normalized (so they stick with the
% axis as the figure is resized) does not work correctly.  In
% this case, draw the ylabel, but set it so it won't stick to axis
% position:
if ~strcmp(version,'4.0a'),
  set(ylab,'Units','normalized');
end

% restore old 'units' settings:
set(axes1,'Units',save_axes1_units);

% y2 label is usually clipped if using default axes position.
% Therefore shrink axes width by 5% to leave room for it:
axespos=get(axes1,'Position');
set([axes1,axes2],'Position',axespos-[0 0 .05 0]);

% set 'nextplot' properties to 'new'
%set(axes1,'NextPlot','new');
%set(axes2,'NextPlot','new');

% set Tags
set(axes1,'Tag','plotyy-axes1');
set(axes2,'Tag','plotyy-axes2');

% store handles
set(axes1,'UserData',axes2);
set(axes2,'UserData',ylab);

% return handles to axes and lines:
if nargout>0,hy2l=ylab;end
if nargout>1,ax=[axes1;axes2];end
if nargout>2,pl=[p1;p2];end
