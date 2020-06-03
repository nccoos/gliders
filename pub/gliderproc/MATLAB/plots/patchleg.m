function [leghandle,labelhandles]=patchleg(varargin)
%LEGEND Graph legend.
%   LEGEND(string1,string2,string3, ...) puts a legend on the current plot
%   using the specified strings as labels. LEGEND works on line graphs,
%   bar graphs, pie graphs, ribbon plots, etc.  You can label any
%   solid-colored patch or surface object.  The fontsize and fontname for
%   the legend strings matches the axes fontsize and fontname.
%
%   LEGEND(H,string1,string2,string3, ...) puts a legend on the plot
%   containing the handles in the vector H using the specified strings as
%   labels for the corresponding handles.
%
%   LEGEND(M), where M is a string matrix or cell array of strings, and
%   LEGEND(H,M) where H is a vector of handles to lines and patches also
%   works.
%
%   LEGEND(AX,...) puts a legend on the axes with handle AX.
%
%   LEGEND OFF removes the legend from the current axes.
%   LEGEND(AX,'off') removes the legend from the axis AX.
%
%   LEGH = LEGEND returns the handle to legend on the current axes or
%   empty if none exists.
%
%   LEGEND with no arguments refreshes all the legends in the current
%   figure (if any).  LEGEND(LEGH) refreshes the specified legend.
%
%   LEGEND(...,Pos) places the legend in the specified
%   location:
%       0 = Automatic "best" placement (least conflict with data)
%       1 = Upper right-hand corner (default)
%       2 = Upper left-hand corner
%       3 = Lower left-hand corner
%       4 = Lower right-hand corner
%      -1 = To the right of the plot
%
%   To move the legend, press the left mouse button on the legend and drag
%   to the desired location. Double clicking on a label allows you to edit
%   the label.
%
%   [LEGH,OBJH] = LEGEND(...) returns a handle LEGH to the legend axes and
%   vector OBJH containing the text, line, and patch handles.
%
%   LEGEND will try to install a ResizeFcn on the figure if it hasn't been
%   defined before.  This resize function will try to keep the legend the
%   same size.
%
%   Examples:
%       x = 0:.2:12;
%       plot(x,bessel(1,x),x,bessel(2,x),x,bessel(3,x));
%       legend('First','Second','Third');
%       legend('First','Second','Third',-1)
%
%       b = bar(rand(10,5),'stacked'); colormap(summer); hold on
%       x = plot(1:10,5*rand(10,1),'marker','square','markersize',12,...
%                'markeredgecolor','y','markerfacecolor',[.6 0 .6],...
%                'linestyle','-','color','r','linewidth',2); hold off
%       legend([b,x],'Carrots','Peas','Peppers','Green Beans',...
%                 'Cucumbers','Eggplant')       
%
%   See also PLOT.
%
% Calls: none

%   D. Thomas 5/6/93
%             9/6/95  
%   Rich Radke 6/17/96 Latest Update
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.53 $  $Date: 1998/12/10 22:07:24 $

%   Private syntax:
%
%     LEGEND('DeleteLegend') is called from the deleteFcn to remove the legend.
%     LEGEND('EditLegend',h) is called from MOVEAXIS to edit the legend labels.
%     LEGEND('ShowLegendPlot') is called from MOVEAXIS to set the gco to
%     the plot the legend goes with.
%     LEGEND('ResizeLegend') is called from the resizeFcn to resize the legend.
%
%   Obsolete syntax:
%
%     LEGEND(linetype1,string1,linetype2,string2, ...) specifies
%     the line types/colors for each label.
%     Linetypes can be any valid PLOT linetype specifying color,
%     marker type, and linestyle, such as 'g:o'.  

narg = nargin;
isresize(0);

%--------------------------
% Parse inputs
%--------------------------

% Determine the legend parent axes (ha) is specified
if narg > 0 & ~isempty(varargin{1}) & ishandle(varargin{1}) & ...
	strcmp(get(varargin{1}(1),'type'),'axes') % legend(ax,...)
    ha = varargin{1}(1);
    varargin(1) = []; % Remove from list
    narg = narg - 1;
    if strcmp(get(ha,'Tag'),'legend') % Use the parent
      ud = get(ha,'userdata');
      if isfield(ud,'PlotHandle')
         ha = ud.PlotHandle;
      else
        warning('Can''t put a legend on a legend.')
        if nargout>0, leghandle = []; labelhandles = []; end
        return
      end
    end
else
  ha = [];
end

if narg==0 % legend
  if nargout==1, % h = legend
    if isempty(ha)
      leghandle = find_legend(find_gca);
    else
      leghandle = find_legend(ha);
    end
  elseif nargout==0 % legend
    if isempty(ha)
      update_all_legends
    else
      update_legend(find_legend(ha));
    end
  else % [h,objh] = legend
    if isempty(ha)
      [leghandle,labelhandles] = find_legend(find_gca);
    else
      [leghandle,labelhandles] = find_legend(ha);
    end
  end
  return
elseif narg==1 & strcmp(varargin{1},'DeleteLegend'), % legend('DeleteLegend')
  % Should only be called by the deleteFcn
  delete_legend(gcbo)
  if nargout>0, error('Too many outputs.'); end
  return
elseif narg==1 & strcmp(varargin{1},'ResizeLegend'), % legend('ResizeLegend')
  isresize(1);
  resize_all_legends(gcbf)
  isresize(0);
  if nargout>0, error('Too many outputs.'); end
  return
elseif narg==1 & strcmp(varargin{1},'off'), % legend('off') or legend(AX,'off')
  if isempty(ha)
    delete_legend(find_legend(find_gca))
  else
    delete_legend(find_legend(ha))
  end   
  if nargout>0, error('Too many outputs.'); end
  return
elseif narg==1 & strcmp(varargin{1},'ShowLegendPlot')
  show_plot
  return
elseif narg==2 & strcmp(varargin{1},'EditLegend')
  edit_legend(varargin{2})
  return
elseif narg==1 & islegend(varargin{1}) % legend(legh)
  [hl,labelhandles] = update_legend(varargin{1});
  if nargout>0, leghandle = hl; end
  return
end

% Look for legendpos code
if isa(varargin{end},'double')
  legendpos = varargin{end};
  varargin(end) = [];
else
  legendpos = [];
end

% Determine the active children (kids) and the strings (lstrings)
if narg < 1
  error('Not enough input arguments.');
elseif ishandle(varargin{1}) % legend(h,strings,...)
  kids = varargin{1};
  if isempty(ha)
    ha=get(varargin{1}(1),'Parent');
    if ~strcmp(get(ha,'type'),'axes'),
      error('Handle must be an axes or child of an axes.');
    end
  end
  if narg==1, error('A string must be supplied for each handle.'); end
  lstrings = getstrings(varargin(2:end));
else % legend(strings,...) or legend(linetype,string,...)
  if isempty(ha), ha=find_gca; end
  kids = getchildren(ha);
  lstrings = getstrings(varargin);
end

% Set default legendpos
if isempty(legendpos)
  if ~isequal(get(ha,'view'),[0 90])
    legendpos = -1;  % To the right of axis is default for 3-D
  else
    legendpos = 1;   % Upper right is default for 2-D
  end
end

% Remove any existing legend on this plot 
hl = find_legend;
if ~isempty(hl),
  ud = get(hl,{'userdata'});
  for i=1:length(ud)
    if isfield(ud{i},'PlotHandle') & ud{i}.PlotHandle == ha
      delete_legend(hl)
    end
  end
end

if length(kids)==0,
  warning('Plot empty.')
  if nargout>0
    leghandle = []; labelhandles = [];
  end
  return
end

[hl,labelhandles] = make_legend(ha,kids,lstrings,legendpos);

if nargout > 0,
    leghandle=hl;
end


%--------------------------------
function [hl,hobjs] = find_legend(ha)
%FIND_LEGEND Return current legend handle or error out if none.
if nargin==0
  hl = findobj(allchild(find_gcf),'Tag','legend');
else
  hl = findobj(allchild(find_gcf(ha)),'Tag','legend');
end
hobjs = [];
if nargin>0
  if length(ha)~=1
    error('Requires a single axis handle.');
  end
  ud = get(hl,{'userdata'});
  for i=1:length(ud)
    if isfield(ud{i},'PlotHandle') & ud{i}.PlotHandle == ha
      hl = hl(i);
      hobjs = ud{i}.LabelHandles;
      return
    end
  end
  hl = []; % None found
  hobjs = [];
end

%-------------------------------
function tf = isresize(setting)
persistent s
if nargin==1
  s = setting;
else
  tf = s;
end

%--------------------------------
function hf = find_gcf(ha)
%FIND_GCF Find gcf.
%   FIND_GCF Returns the callback figure if there is one otherwise
%   it returns the current figure.
if nargin==1 & strcmp(get(ha,'type'),'axes')
  hf = get(ha,'parent');
else
  if isresize
    hf = gcbf;
    if isempty(hf),
      hf = gcf;
    end
  else
    hf = gcf;
  end 
end

%---------------------------------
function ha = find_gca(ha)
%FIND_GCA Find gca (skipping legend)
if nargin==0
fig = find_gcf;
else
fig = find_gcf(ha);
end
ha = get(fig,'currentaxes');
if isempty(ha), ha = gca; end
if strcmp(get(ha,'tag'),'legend')
  ud = get(ha,'userdata');
  if isfield(ud,'PlotHandle')
    ha = ud.PlotHandle;
    % Make sure legend isn't isn't the gca
    set(fig,'currentaxes',ud.PlotHandle)
  end
end

%----------------------------------
function tf = islegend(h)
%ISLEGEND Return true if input is a legend handle
if length(h)==1,
  tf = ishandle(h) & strcmp(get(h,'tag'),'legend');
else
  tf = logical(0);
end


%-------------------------------
function [hl,labelhandles] = make_legend(ha,Kids,lstrings,legendpos,ud)
%MAKE_LEGEND Make legend given parent axes, kids, and strings
%
%   MAKE_LEGEND(...,ud) is called from the resizeFcn.  In this case
%   just update the position of the legend pieces instead of recreating
%   it from scratch.

hf = get(ha,'parent'); % Parent figure

% Get the legend info structure from the inputs
info = legend_info(ha,hf,Kids,lstrings);

% Remember current state
hfold = find_gcf(ha);
haold = find_gca(ha);
punits=get(hf,'units');
aunits=get(ha,'units');
if strncmp(get(hf,'NextPlot'),'replace',7),
  set(hf,'NextPlot','add')
  oldNextPlot = get(hf,'NextPlot');
else
  oldNextPlot = '';
end
set(ha,'units','points');
set(hf,'units','points');

% Determine size of legend in figure points
fontn = get(ha,'fontname');
fonts = get(ha,'fontsize');
fonta = get(ha,'fontangle');
fontw = get(ha,'fontweight');
cap = get(ha,'Position');

% Symbols are the size of 3 numbers
h = text(0,0,'123','fontname',fontn,'fontsize',fonts,...
         'fontangle',fonta,'fontweight',fontw);
set(h,'units','points','visible','off');
ext = get(h,'extent');
lsym = ext(3);
loffset = lsym/3;
delete(h);

% Make box big enough to handle longest string
h=text(0,0,{info.label},'fontname',fontn,'fontsize',fonts,...
       'fontangle',fonta,'fontweight',fontw);
set(h,'units','points','visible','off');
ext = get(h,'extent');
width = ext(3);
height = ext(4)/size(get(h,'string'),1);
margin = height*0.075;
delete(h);

llen = width + loffset*3 + lsym; 
lhgt = ext(4) + 2*margin;

% Reset axis if it had be resized to that getposition works
if nargin==5,
  set(ha,'units','normalized','position',ud.PlotPosition)
  set(ha,'units','points')
end
  
[lpos,axpos] = getposition(ha,legendpos,llen,lhgt);

% Shrink axes if necessary
ud.PlotHandle = ha;
set(ha,'units','normalized')
ud.PlotPosition = get(ha,'position'); % Remember old axes position
set(ha,'units','points')
ud.legendpos = legendpos;
if ~isempty(axpos)
  set(ha,'Position',axpos)
end
set(ha,'units','normalized')
ud.AxesPosition = get(ha,'position');

% Create legend object
if find_gcf ~= hf & nargin<5, figure(hf); end
if strcmp(get(ha,'color'),'none')
  acolor = get(hf,'color');
else
  acolor = get(ha,'color');
end

if nargin<5
  % Create legend axes and DeleteProxy object (an
  % invisible text object in target axes) so that the 
  % legend will get deleted correctly.
  ud.DeleteProxy = text('parent',ha,'visible','off', ...
                        'tag','LegendDeleteProxy',...
                        'handlevisibility','off');
  hl=axes('units','points','position',lpos,'box','on','drawmode', ...
        'fast','nextplot','add','xtick',[-1],'ytick',[-1], ...
        'xticklabel','','yticklabel','','xlim',[0 1],'ylim',[0 1], ...
        'clipping','on','color',acolor,'tag','legend','view',[0 90],...
        'climmode',get(ha,'climmode'),'clim',get(ha,'clim'),...
        'deletefcn','legend(''DeleteLegend'')');
  set(hl,'units','normalized')
  setappdata(hl,'NonDataObject',[]); % Used by DATACHILDREN.M
  ud.LegendPosition = get(hl,'position');
  set(ud.DeleteProxy,'deletefcn','eval(''delete(get(gcbo,''''userdata''''))'','''')');
  set(ud.DeleteProxy,'userdata',hl);
else
  hl = ud.LegendHandle;
  labelhandles = ud.LabelHandles;
  set(hl,'units','points','position',lpos);
  set(hl,'units','normalized')
  ud.LegendPosition = get(hl,'position');
end
  
texthandles = [];
objhandles = [];

nstack = length(info);
nrows = size(char(info.label),1);

% draw text one on chunk so that the text spacing is good
label = char(info.label);
top = (1-max(1,size(label,1)))/2;
if nargin<5
  texthandles = text('parent',hl,'units','data',...
       'position',[1-(width+loffset)/llen,1-(1-top)/(nrows+1)],...
       'string',char(info.label),...
       'fontname',fontn,'fontweight',fontw,...
       'fontsize',fonts,'fontangle',fonta,...
       'ButtonDownFcn','moveaxis');
else
  texthandles = ud.LabelHandles(1);
  set(texthandles,'units','data',...
      'position',[1-(width+loffset)/llen,1-(1-top)/(nrows+1)],...
      'fontname',fontn,'fontsize',fonts);
end
     
ext = get(texthandles,'extent');
centers = linspace(ext(4)-ext(4)/nrows,0,nrows)+ext(4)/nrows/2 + 0.4*(1-ext(4));
edges = linspace(ext(4),0,nrows+1) + 0.4*(1-ext(4));
indent = [1 1 -1 -1 1] * ext(4)/nrows/7.5;

hpos = 2;
r = 1;
for i=1:nstack
  % draw lines with markers like this: --*--
  if strcmp(info(i).objtype,'line')
     if ~strcmp(info(i).linetype,'none')
        if nargin<5
          p = line('parent',hl,'xdata',(loffset+[0 lsym])/llen,...
                   'ydata',[centers(r) centers(r)],...
                   'linestyle',info(i).linetype,...
                   'marker','none',...
                   'color',info(i).edgecol, ...
                   'linewidth',info(i).lnwidth,...
                   'ButtonDownFcn','moveaxis');
        else
          p = ud.LabelHandles(hpos);
          set(p,'xdata',(loffset+[0 lsym])/llen,...
                'ydata',[centers(r) centers(r)]);
          hpos = hpos+1;
        end
     else
       p = [];
     end
     if ~strcmp(info(i).marker,'none')
       if nargin<5
         p = [p;line('parent',hl,'xdata',(loffset+lsym/2)/llen,...
                    'ydata',centers(r),...
                    'color',info(i).edgecol, ...
                    'linestyle','none',...
                    'linewidth',info(i).lnwidth,...
                    'marker',info(i).marker,...
                    'markeredgecolor',info(i).markedge,...
                    'markerfacecolor',info(i).markface,...
                    'markersize',info(i).marksize,...
                    'ButtonDownFcn','moveaxis')];
       else
         p2 = ud.LabelHandles(hpos);
         set(p2,'xdata',(loffset+lsym/2)/llen,...
               'ydata',centers(r));
         hpos = hpos+1;
         p = [p;p2];
       end
     end

  % draw patches
  elseif strcmp(info(i).objtype,'patch')  | strcmp(info(i).objtype,'surface')
     % Adjusting ydata to make a thinner box will produce nicer
     % results if you use patches with markers.
     if nargin<5
       p = patch('parent',hl,'xdata',(loffset+[0 lsym lsym 0 0])/llen,...
                  'ydata',[edges(r) edges(r) edges(r+1) edges(r+1) edges(r)]-indent,...
                  'linestyle',info(i).linetype,...
                  'edgecolor',info(i).edgecol, ...
                  'facecolor',info(i).facecol,...
                  'linewidth',info(i).lnwidth,...
                  'marker',info(i).marker,...
                  'markeredgecolor',info(i).markedge,...
                  'markerfacecolor',info(i).markface,...
                  'markersize',info(i).marksize,...
                  'ButtonDownFcn','moveaxis');
     else
       p = ud.LabelHandles(hpos);
       set(p,'xdata',(loffset+[0 lsym lsym 0 0])/llen,...
             'ydata',[edges(r) edges(r) edges(r+1) edges(r+1) edges(r)]-indent);
       hpos = hpos+1;
     end
     if strcmp(info(i).facecol,'flat') | strcmp(info(i).edgecol,'flat')
        c = get(Kids(i),'cdata');
        k = min(find(finite(c)));
        if ~isempty(k)
          set(p,'cdata',c(k)*ones(1,5),...
                'cdatamapping',get(Kids(i),'cdatamapping'));
        end
     end
  end
  objhandles = [objhandles;p];
  r = r + max(1,size(info(i).label,1));
end

labelhandles = [texthandles;objhandles];

% Clean up a bit

set(hf,'currentaxes',haold)
set(hf,'units',punits)
set(ha,'units',aunits)
if (hfold ~= hf) & nargin<5, figure(hfold); end
if ~isempty(oldNextPlot)
  set(hf,'nextplot',oldNextPlot)
end
ud.handles = Kids;
ud.lstrings = {info.label};
ud.LabelHandles = labelhandles;
ud.LegendHandle = hl;
set(hl,'ButtonDownFcn','moveaxis','interruptible','on', ...
       'busyaction','queue','userdata',ud);

% Make legend resize itself
if isempty(get(hf,'resizefcn')),
  set(hf,'resizefcn','legend(''ResizeLegend'')')
end

if nargin<5
  PlaceLegendOnTop(hf,hl,ha)
end

%------------------------------
function PlaceLegendOnTop(hf,hl,ha)
%PlaceLengendOpTop  Make sure the legend is on top of its axes.
ord = findobj(allchild(hf),'flat','type','axes');
axpos = find(ord==ha);
legpos = find(ord==hl);
if legpos ~= axpos-1
  axes(ord(axpos))
  axes(ord(legpos))
  for i=axpos-1:-1:1
    if i ~= legpos
      axes(ord(i)); 
    end
  end
end


%------------------------------
function info = legend_info(ha,hf,Kids,lstrings);
%LEGEND_INFO Get legend info from parent axes, Kids, and strings
%   INFO = LEGEND_INFO(HA,KIDS,STRINGS) returns a structure array containing
%      objtype  -- Type of object 'line', 'patch', or 'surface'
%      label    -- label string
%      linetype -- linetype;
%      edgecol  -- edge color
%      facecol  -- face color
%      lnwidth  -- line width
%      marker   -- marker
%      marksize -- markersize
%      markedge -- marker edge color
%      markface -- marker face color (not used for 'line')

defaultlinestyle = get(hf,'defaultlinelinestyle');
defaultlinecolor = get(hf,'defaultlinecolor');
defaultlinewidth = get(hf,'defaultlinelinewidth');
defaultlinemarker = get(hf,'defaultlinemarker');
defaultlinemarkersize = get(hf,'defaultlinemarkersize');
defaultlinemarkerfacecolor = get(hf,'defaultlinemarkerfacecolor');
defaultlinemarkeredgecolor = get(hf,'defaultlinemarkeredgecolor');
defaultpatchfacecolor = get(hf,'defaultpatchfacecolor');

linetype = {};
edgecol = {};
facecol = {};
lnwidth = {};
marker = {};
marksize = {};
markedge = {};
markface = {};

% These 8 variables are the important ones.  The only ambiguity is
% edgecol/facecol.  For lines, edgecol is the line color and facecol
% is unused.  For patches, edgecol/facecol mean the logical thing.

Kids = Kids(:);  %  Reshape so that we have a column vector of handles.
lstrings = lstrings(:);

% Check for valid handles
nonhandles = ~ishandle(Kids);
if any(nonhandles)
%  warning('Some invalid handles were ignored.')
  Kids(nonhandles) = [];
end
if ~isempty(Kids)
badhandles = ~(strcmp(get(Kids,'type'),'patch') | ...
               strcmp(get(Kids,'type'),'line')  | ...
               strcmp(get(Kids,'type'),'surface'));
if any(badhandles)
  warning(['Some handles to non-lines and/or non-solid color',...
           ' objects were ignored.'])
  Kids(badhandles) = [];
end
end

% Look for obsolete syntax label(...,LineSpec,Label,LineSpec,Label)
% To reduce the number of false hits, we require at least one
% line type in the list
obsolete = 0;
if rem(length(lstrings),2)==0,
  for i=1:2:length(lstrings)
    if isempty(lstrings{i}), % Empty lineSpec isn't obsolete syntax 
      obsolete = 0;
      break
    end
    [L,C,M,msg] = colstyle(lstrings{i});
    if ~isempty(msg), % If any error parsing LineSpec 
       obsolete = 0;
       break
     end
    if ~isempty(L), obsolete = 1; end
  end
end

if obsolete
  warning(sprintf(['The syntax LEGEND(linetype1,string1,linetype2,',...
           'string2, ...) \n is obsolete.  Use LEGEND(H,string1,',...
           'string2, ...) instead, \n where H is a vector of handles ',...
           'to the objects you wish to label.']))

  % Every other argument is a linespec

  % Right now we don't check to see if a corresponding linespec is
  % actually present on the graph, we just draw it anyway as a 
  % simple line with properties color, linestyle, 1-char markertype.
  % No frills like markersize, marker colors, etc.  Exception: if
  % a patch is present with facecolor = 'rybcgkwm' and the syntax
  % legend('g','label') is used, a patch shows up in the legend
  % instead.  Since this whole functionality is being phased out and
  % you can do better things using handles, the legend may not look
  % as nice using this option.
  
  objtype = {};

  % Check for an even number of strings
  if rem(length(lstrings),2)~=0
    error('Invalid legend syntax.')
  end

  for i=1:2:length(lstrings)        
    lnstr=lstrings{i};
    [lnt,lnc,lnm,msg] = colstyle(lnstr);

    if (isempty(msg) & ~isempty(lnstr)) % Valid linespec
      % Check for line style
      if (isempty(lnt))
        linetype=[linetype,{defaultlinestyle}];
      else
        linetype=[linetype,{lnt}];
      end
      % Check for line color
      if (isempty(lnc))
        edgecol=[edgecol,{defaultlinecolor}];
        facecol=[facecol,{defaultpatchfacecolor}];
        objtype = [objtype,{'line'}];
      else   
        colspec = ctorgb(lnc);
        edgecol=[edgecol,{colspec}];
        facecol=[facecol,{colspec}];
        if ~isempty(findobj('type','patch','facecolor',colspec)) | ...
           ~isempty(findobj('type','surface','facecolor',colspec))
          objtype = [objtype,{'patch'}];
        else
          objtype = [objtype,{'line'}];
        end
      end
      % Check for marker
      if (isempty(lnm)),
          marker=[marker,{defaultlinemarker}];
      else
          marker=[marker,{lnm}];
      end
      % Set remaining properties
      lnwidth = [lnwidth,{defaultlinewidth}];
      marksize = [marksize,{defaultlinemarkersize}];
      markedge = [markedge,{defaultlinemarkeredgecolor}];
      markface = [markface,{defaultlinemarkerfacecolor}];
    else
      % Set everything to defaults
      linetype=[linetype,{defaultlinestyle}];
      edgecol=[edgecol,{defaultlinecolor}];
      facecol=[facecol,{defaultpatchfacecolor}];
      marker=[marker,{defaultlinemarker}];
      lnwidth = [lnwidth,{defaultlinewidth}];
      marksize = [marksize,{defaultlinemarkersize}];
      markedge = [markedge,{defaultlinemarkeredgecolor}];
      markface = [markface,{defaultlinemarkerfacecolor}];
      objtype = [objtype,{'line'}];
    end
  end
  lstrings = lstrings(2:2:end);

else % Normal syntax
  objtype = get(Kids,{'type'});
  nk = length(Kids);
  nstack = length(lstrings);
  n = min(nstack,nk);

  % Treat empty strings as a single space
  for i=1:nstack
    if isempty(lstrings{i})
      lstrings{i} = ' ';
    end
  end
  
  % Truncate kids if necessary to match the number of strings
  objtype = objtype(1:n);
  Kids = Kids(1:n);

  for i=1:n
    linetype = [linetype,get(Kids(i),{'LineStyle'})];
    if strcmp(objtype{i},'line')
      edgecol = [edgecol,get(Kids(i),{'Color'})];            
      facecol = [facecol,{'none'}];
    elseif strcmp(objtype{i},'patch') | strcmp(objtype{i},'surface')
      [e,f] = patchcol(Kids(i));
      edgecol = [edgecol,{e}];
      facecol = [facecol,{f}];
    end
    lnwidth = [lnwidth,get(Kids(i),{'LineWidth'})];
    marker = [marker,get(Kids(i),{'Marker'})];
    marksize = [marksize,get(Kids(i),{'MarkerSize'})];
    markedge = [markedge,get(Kids(i),{'MarkerEdgeColor'})];
    markface = [markface,get(Kids(i),{'MarkerFaceColor'})];
  end

  if n < nstack,     % More strings than handles
    objtype(end+1:nstack) = {'none'};
    linetype(end+1:nstack) = {'none'};
    edgecol(end+1:nstack) = {'none'};
    facecol(end+1:nstack) = {'none'};
    lnwidth(end+1:nstack) = {defaultlinewidth};
    marker(end+1:nstack) = {'none'};
    marksize(end+1:nstack) = {defaultlinemarkersize};
    markedge(end+1:nstack) = {'auto'};
    markface(end+1:nstack) = {'auto'};
  end
end

% Limit markersize to axes fontsize
fonts = get(ha,'fontsize');
marksize([marksize{:}]' > fonts & strcmp(objtype(:),'line')) = {fonts};  
marksize([marksize{:}]' > fonts/2 & strcmp(objtype(:),'patch')) = {fonts/2};  

% Package everything into the info structure
info = struct('objtype',objtype(:),'label',lstrings(:),...
              'linetype',linetype(:),'edgecol',edgecol(:),...
             'facecol',facecol(:),'lnwidth',lnwidth(:),'marker',marker(:),...
             'marksize',marksize(:),'markedge',markedge(:),'markface',markface(:));
 

%-----------------------------
function update_all_legends
%UPDATE_ALL_LEGENDS Update all legends on this figure
legh = find_legend;
for i=1:length(legh)
   update_legend(legh(i));
end

%-------------------------------
function [hl,objh] = update_legend(legh)
%UPDATE_LEGEND Update an existing legend
if isempty(legh),
  hl = [];
  objh = [];
  return
end
if length(legh)~=1,
  error('Can only update one legend at a time.')
end

ud = get(legh,'userdata');
if ~isfield(ud,'LegendPosition')
  warning('No legend to update.')
  hl = []; objh = [];
  return
end

moved = DidLegendMove(legh);

units = get(legh,'units');
set(legh,'units','points')
oldpos = get(legh,'position');

% Delete old legend
delete_legend(legh)

% Make a new one
if moved | length(ud.legendpos)==4
  [hl,objh] = make_legend(ud.PlotHandle,ud.handles,ud.lstrings,oldpos);
else
  [hl,objh] = make_legend(ud.PlotHandle,ud.handles,ud.lstrings,ud.legendpos);
end
set(hl,'units',units)

%----------------------------------------------
function moved = DidLegendMove(legh)
% Check to see if the legend has been moved
ud = get(legh,'userdata');
units = get(legh,'units');
set(legh,'units','normalized')
pos = get(legh,'position');
set(legh,'units','pixels')
tol = pos ./ get(legh,'position')/2;
if any(abs(ud.LegendPosition - pos) > max(tol(3:4)))
  moved = 1;
else
  moved = 0;
end
set(legh,'units',units)

%----------------------------------------------
function moved = DidAxesMove(legh)
% Check to see if the axes has been moved
ud = get(legh,'userdata');
ax = ud.PlotHandle;
if isfield(ud,'AxesPosition')
  units = get(ax,'units');
  set(ax,'units','normalized')
  pos = get(ax,'position');
  set(ax,'units','pixels')
  tol = pos ./ get(ax,'position')/2;
  if any(abs(ud.AxesPosition - pos) > max(tol(3:4)))
    moved = 1;
  else
    moved = 0;
  end
  set(ax,'units',units)
else
  moved = 0;
end

%----------------------------
function resize_all_legends(fig)
%RESIZE_ALL_LEGENDS Resize all legends in this figure
legh = findobj(allchild(fig),'Tag','legend');
for i=1:length(legh)
   resize_legend(legh(i));
end

%----------------------------
function resize_legend(legh)
%RESIZE_LEGEND Resize all legend in this figure

ud = get(legh,'userdata');
units = get(legh,'units');
set(legh,'units','normalized')

if ~isfield(ud,'LegendPosition')
  warning('No legend to update.')
  hl = []; objh = [];
  return
end

moved = DidLegendMove(legh);

set(legh,'units','points')
oldpos = get(legh,'position');

% Update the legend
if moved | length(ud.legendpos)==4
  [hl,objh] = make_legend(ud.PlotHandle,ud.handles,ud.lstrings,oldpos,ud);
else
  [hl,objh] = make_legend(ud.PlotHandle,ud.handles,ud.lstrings,ud.legendpos,ud);
end
set(hl,'units',units)


%----------------------------
function delete_legend(ax)
%DELETE_LEGEND Remove legend from plot
if isempty(ax), return, end
ax = ax(1);
hf = get(ax,'parent');

% Remove auto-resize
resizefcn = get(hf,'resizefcn');
if strcmp(resizefcn,'legend(''ResizeLegend'')')
  set(hf,'resizefcn','')
end

ud = get(ax,'userdata');
if isfield(ud,'PlotHandle') & ishandle(ud.PlotHandle) & ...
   isfield(ud,'PlotPosition') & ~isempty(ud.PlotPosition) & ...
   ~DidAxesMove(ax)
  units = get(ud.PlotHandle,'units');
  set(ud.PlotHandle,'units','normalized','position',ud.PlotPosition)
  set(ud.PlotHandle,'units',units)
end
if isfield(ud,'DeleteProxy') & ishandle(ud.DeleteProxy)
  delete(ud.DeleteProxy)
end

%-------------------------------
function [lpos,axpos] = getposition(ha,legendpos,llen,lhgt)
%GETPOS Get position vector from legendpos code
stickytol=1;
cap=get(ha,'position');
edge = 5; % 5 Point edge

if length(legendpos)==4,
  % Keep the top at the same place
  Pos = [legendpos(1) legendpos(2)+legendpos(4)-lhgt];
else
  switch legendpos,
    case 0,
       Pos = lscan(ha,llen,lhgt,0,stickytol,-1);
    case 1,
       Pos = [cap(1)+cap(3)-llen-edge cap(2)+cap(4)-lhgt-edge];
    case 2,
       Pos = [cap(1)+edge cap(2)+cap(4)-lhgt-edge];
    case 3,
       Pos = [cap(1)+edge cap(2)+edge];
    case 4,
       Pos = [cap(1)+cap(3)-llen-edge cap(2)+edge];
    otherwise
       Pos = -1;
  end
end
if isequal(Pos,-1)
  axpos=[cap(1) cap(2) cap(3)-llen-.03 cap(4)];
  lpos=[cap(1)+cap(3)-llen+edge cap(4)+cap(2)-lhgt llen lhgt];
  if any(axpos<0) | any(lpos<0),
    warning('Insufficient space to draw legend.')
    if any(axpos<0), axpos = []; end
  end
else
  axpos=[];
  lpos=[Pos(1) Pos(2) llen lhgt];
end

%--------------------------------------------
function Pos = lscan(ha,wdt,hgt,tol,stickytol,hl)
%LSCAN  Scan for good legend location.

debug = 0; % Set to 1 for debugging

if nargin==6 & hl>0,
  moved = DidLegendMove(legh);
  if moved, sticky = 1; else sticky = 0; end
else
  moved = 0;
end

% Calculate tile size
cap=get(ha,'Position'); % In Point coordinates
xlim=get(ha,'Xlim');
ylim=get(ha,'Ylim');
H=ylim(2)-ylim(1);
W=xlim(2)-xlim(1);

dh = 0.03*H;
dw = 0.03*W;
Hgt = hgt*H/cap(4);
Wdt = wdt*W/cap(3);
Thgt = H/max(1,floor(H/(Hgt+dh)));
Twdt = W/max(1,floor(W/(Wdt+dw)));
dh = (Thgt - Hgt)/2;
dw = (Twdt - Wdt)/2;

% Get data, points and text

Kids=get(ha,'children');
Xdata=[];Ydata=[];
for i=1:length(Kids),
  type = get(Kids(i),'type');
  if strcmp(type,'line')
    xk = get(Kids(i),'Xdata');
    yk = get(Kids(i),'Ydata');
    n = length(xk);
    if n < 100 & n > 1
      xk = interp1(xk,linspace(1,n,200));
      yk = interp1(yk,linspace(1,n,200));
    end
    Xdata=[Xdata,xk];
    Ydata=[Ydata,yk];
  elseif strcmp(type,'patch') | strcmp(type,'surface')
    xk = get(Kids(i),'Xdata');
    yk = get(Kids(i),'Ydata');
    Xdata=[Xdata,xk(:)'];
    Ydata=[Ydata,yk(:)'];
  elseif strcmp(get(Kids(i),'type'),'text'),
    tmpunits = get(Kids(i),'units');
    set(Kids(i),'units','data')
    tmp=get(Kids(i),'Position');
    ext=get(Kids(i),'Extent');
    set(Kids(i),'units',tmpunits);
    Xdata=[Xdata,[tmp(1) tmp(1)+ext(3)]];
    Ydata=[Ydata,[tmp(2) tmp(2)+ext(4)]];
  end
end
in = finite(Xdata) & finite(Ydata);
Xdata = Xdata(in);
Ydata = Ydata(in);

% Determine # of data points under each "tile"
xp = (0:Twdt:W-Twdt) + xlim(1);
yp = (0:Thgt:H-Thgt) + ylim(1);
wtol = Twdt / 100;
htol = Thgt / 100;
for j=1:length(yp)
  if debug, line([xlim(1) xlim(2)],[yp(j) yp(j)],'handlevisibility','off'); end
  for i=1:length(xp)
    if debug, line([xp(i) xp(i)],[ylim(1) ylim(2)],'handlevisibility','off'); end
    pop(j,i) = sum(sum((Xdata > xp(i)-wtol) & (Xdata < xp(i)+Twdt+wtol) & ...
                       (Ydata > yp(j)-htol) & (Ydata < yp(j)+Thgt+htol)));    
  end
end

if all(pop(:) == 0), pop(1) = 1; end

% Cover up fewest points.  After this while loop, pop will
% be lowest furthest away from the data
while any(pop(:) == 0)
  newpop = filter2(ones(3),pop);
  if all(newpop(:) ~= 0)
    break;
  end
  pop = newpop;
end
if debug, 
  figure, 
  surface('xdata',[xp xp(end)+Twdt],'ydata', [yp yp(end)+Thgt],...
          'zdata',zeros(length(yp)+1,length(xp)+1),...
          'cdata',pop)
  figure(gpf)
end
[j,i] = find(pop == min(pop(:)));
xp =  xp - xlim(1) + dw;
yp =  yp - ylim(1) + dh;
Pos = [cap(1)+xp(i(end))*cap(3)/W
       cap(2)+yp(j(end))*cap(4)/H];

%--------------------------------
function Kids = getchildren(ha)
%GETCHILDREN Get children that can have legends
%   Note: by default, lines get labeled before patches;
%   patches get labeled before surfaces.
Kids = flipud([findobj(ha,'type','surface') ;...
       findobj(ha,'type','patch') ; findobj(ha,'type','line')]);


%----------------------------
function s = getstrings(c)
%GETSTRINGS Get strings from legend input
%   S = GETSTRINGS(C) where C is a cell array containing the legend
%   input arguments.  Handles three cases:
%      (1) legend(M) -- string matrix
%      (2) legend(C) -- cell array of strings
%      (3) legend(string1,string2,string3,...)
%   Returns a cell array of strings
if length(c)==1 % legend(M) or legend(C)
  s = cellstr(c{1});
elseif iscellstr(c)
  s = c;
else
  error('Legend labels must be strings.');
end


%-----------------------------------
function  out=ctorgb(arg)
%CTORGB Convert color string to rgb value
switch arg
  case 'y', out=[1 1 0];
  case 'm', out=[1 0 1];
  case 'c', out=[0 1 1];
  case 'r', out=[1 0 0];
  case 'g', out=[0 1 0];
  case 'b', out=[0 0 1];
  case 'w', out=[1 1 1];
  otherwise, out=[0 0 0];
end


%----------------------------------
function  [edgecol,facecol] = patchcol(h)
%PATCHCOL Return edge and facecolor from patch handle
cdat = get(h,'Cdata');
facecol = get(h,'FaceColor');
if strcmp(facecol,'interp') | strcmp(facecol,'texturemap') 
  if ~all(cdat == cdat(1))
     warning(['Legend not supported for patches with FaceColor = ''',facecol,''''])
  end
  facecol = 'flat';
end
if strcmp(facecol,'flat')
  if size(cdat,3) == 1       % Indexed Color
    k = find(finite(cdat));
    if isempty(k)
      facecol = 'none';
    end
  else                       % RGB values
    facecol = reshape(cdat(1,1,:),1,3);
  end
end

edgecol = get(h,'EdgeColor');
if strcmp(edgecol,'interp')
  if ~all(cdat == cdat(1))
     warning('Legend not supported for patches with EdgeColor = ''interp''.')
  end  
  edgecol = 'flat';
end
if strcmp(edgecol,'flat')
  if size(cdat,3) == 1      % Indexed Color
    k = find(finite(cdat));
    if isempty(k)
      edgecol = 'none';
    end
  else                      % RGB values
    edgecol = reshape(cdat(1,1,:),1,3);
  end
end


%------------------------
function edit_legend(gco)
%Edit a legend

if ~strcmp(get(gco,'type'),'text'), return, end

% Determine which string was clicked on
units = get(gco,'units');
set(gco,'units','data')
cp = get(gca,'currentpoint');
ext = get(gco,'extent');
nstrings = size(get(gco,'string'),1);

% The k-th string (from the top) was clicked on
k = floor((ext(4) - cp(1,2))/ext(4)*nstrings) + 1;
legh = get(gco,'parent');
ud = get(legh,'userdata');
nrows = cellfun('size',ud.lstrings,1);
crows = cumsum(nrows);

% Determine which string in the cell array was clicked on
active_string = floor( ...
            interp1([0 cumsum(nrows)+1],[1:length(nrows) length(nrows)],k));
if isnan(active_string), return, end

% Disable legend buttondownfcn's
savehandle = findobj('buttondownfcn','moveaxis');
set(savehandle,'buttondownfcn','')

% Make a editable string on top of the legend string
pos = get(gco,'position');
y = ext(4) - (crows(active_string)-nrows(active_string)/2)*ext(4)/nstrings;
pos(2) = ext(2) + y;
TextHandle = copyobj(gco,gca);
set(TextHandle,'string',char(ud.lstrings{active_string}),'position',pos, ...
               'Editing','on')
waitfor(TextHandle,'Editing');

% Protect against the handles being destroyed during the waitfor
if ishandle(TextHandle) & ishandle(legh) & ishandle(savehandle)
  ud.lstrings{active_string} = get(TextHandle,'String');
  delete(TextHandle)
  set(legh,'UserData',ud)
  set(gco,'units',units)

  % Enable legend buttondfcn's
  set(savehandle,'buttondownfcn','moveaxis')
  update_legend(legh);
end

%-----------------------------
function show_plot
%Set the axes this legend goes with to the current axes

if strcmp(get(gca,'tag'),'legend')
  ud = get(gca,'userdata');
  if isfield(ud,'PlotHandle')
    set(find_gcf,'currentaxes',ud.PlotHandle)
  end
end

