	function handle=pcbar(loc,clim,begslot,endslot)

%  PCBAR Displays a partial color bar (color scale).  Works just
%	 like COLORBAR, but allows for partial display of the colorbar.
%
%  PCBAR requires the following arguments:
%	clim	 - the "restricted" contour limits (min, max
%		   of the data) -- important - not the new clims!
%	begslot	 - the beginning index of the part of the concatenated 
%		   colormap created (see NEWCLIM)
%	endslot  - the last index of the desired part of the concatenated
%		   colormap used
%       loc (not required) - the location ('horiz' or 'vert') for
%		   the colorbar (see COLORBAR)
%
%  output vars:
%	handle - the handle to which the partial colorbar corresponds
%
% Calls: none
%
%  See also NEWCLIM, a function to trick matlab into letting you use
%    multiple colormaps on the same figure.  
%
%  Last modified:  7 Oct 1999
%  Catherine R. Edwards
%  based on original COLORBAR.M created by
%   Clay M. Thompson 10-9-92
%
%

changeNextPlot = 1;

if nargin==3
  endslot=begslot;
  begslot=clim;
  clim=loc;
  loc = 'vert'; 
end

% Catch colorbar('delete') special case -- must be called by the deleteFcn.
if nargin==1 & strcmp(loc,'delete'),
  ax = gcbo;
  if strcmp(get(ax,'tag'),'TMW_COLORBAR'), ax=get(ax,'parent'); end
  ud = get(ax,'userdata');
  if isfield(ud,'PlotHandle') & ishandle(ud.PlotHandle) & ...
     isfield(ud,'origPos') & ~isempty(ud.origPos)
     units = get(ud.PlotHandle,'units');
     set(ud.PlotHandle,'units','normalized');
     set(ud.PlotHandle,'position',ud.origPos);
     set(ud.PlotHandle,'units',units);
  end
  if isfield(ud,'DeleteProxy') & ishandle(ud.DeleteProxy)
    delete(ud.DeleteProxy)
  end
  if ~isempty(legend)
    legend % Update legend
  end
  return
end

ax = [];
if nargin==1,
    if ishandle(loc)
        ax = loc;
        if ~strcmp(get(ax,'type'),'axes'),
            error('Requires axes handle.');
        end
        units = get(ax,'units'); set(ax,'units','pixels');
        rect = get(ax,'position'); set(ax,'units',units)
        if rect(3) > rect(4), loc = 'horiz'; else loc = 'vert'; end
        changeNextPlot = 0;
    end
end

% Determine color limits explicitly.  If any axes child is an image
% use scale based on size of colormap, otherwise use current CAXIS.

ch = get(gcda,'children');

  % Treat images and surfaces alike if cdatamapping == 'scaled'
  t = clim; 
  d = (t(2) - t(1))/(endslot-begslot+1);
  t = [t(1)+d/2  t(2)-d/2];

h = gcda;

if nargin==0,
    % Search for existing colorbar
    ch = get(findobj(gcf,'type','image','tag','TMW_COLORBAR'),{'parent'}); ax = [];
    for i=1:length(ch),
        ud = get(ch{i},'userdata');
        d = ud.PlotHandle;
        if prod(size(d))==1 & isequal(d,h), 
            ax = ch{i}; 
            pos = get(ch{i},'Position');
            if pos(3)<pos(4), loc = 'vert'; else loc = 'horiz'; end
            changeNextPlot = 0;
            % Make sure image deletefcn doesn't trigger a colorbar('delete')
            % for colorbar update
            set(get(ax,'children'),'deletefcn','')
            break; 
        end
    end
end

origNextPlot = get(gcf,'NextPlot');
if strcmp(origNextPlot,'replacechildren') | strcmp(origNextPlot,'replace'),
    set(gcf,'NextPlot','add')
end

if loc(1)=='v', % Append vertical scale to right of current plot
    
    if isempty(ax),
        units = get(h,'units'); set(h,'units','normalized')
        pos = get(h,'Position'); 
        [az,el] = view;
        stripe = 0.075; edge = 0.02; 
        if all([az,el]==[0 90]), space = 0.05; else space = .1; end
        set(h,'Position',[pos(1) pos(2) pos(3)*(1-stripe-edge-space) pos(4)])
        rect = [pos(1)+(1-stripe-edge)*pos(3) pos(2) stripe*pos(3) pos(4)];
        ud.origPos = pos;
        
        % Create axes for stripe and
        % create DeleteProxy object (an invisible text object in
        % the target axes) so that the colorbar will be deleted
        % properly.
        ud.DeleteProxy = text('parent',h,'visible','off',...
                              'tag','ColorbarDeleteProxy',...
                              'handlevisibility','off',...
             'deletefcn','eval(''delete(get(gcbo,''''userdata''''))'','''')');
        ax = axes('Position', rect);
        setappdata(ax,'NonDataObject',[]); % For DATACHILDREN.M
        set(ud.DeleteProxy,'userdata',ax)
        set(h,'units',units)
    else
        axes(ax);
        ud = get(ax,'userdata');
    end
    
    % Create color stripe
    n = size(colormap,1);
    image([0 1],t,(begslot:endslot)','Tag','TMW_COLORBAR','deletefcn','colorbar(''delete'')'); set(ax,'Ydir','normal')
    set(ax,'YAxisLocation','right')
    set(ax,'xtick',[])

    % set up axes deletefcn
    set(ax,'tag','Colorbar','deletefcn','colorbar(''delete'')')
    
elseif loc(1)=='h', % Append horizontal scale to top of current plot
    
    if isempty(ax),
        units = get(h,'units'); set(h,'units','normalized')
        pos = get(h,'Position');
        stripe = 0.075; space = 0.1;
        set(h,'Position',...
            [pos(1) pos(2)+(stripe+space)*pos(4) pos(3) (1-stripe-space)*pos(4)])
        rect = [pos(1) pos(2) pos(3) stripe*pos(4)];
        ud.origPos = pos;

        % Create axes for stripe and
        % create DeleteProxy object (an invisible text object in
        % the target axes) so that the colorbar will be deleted
        % properly.
        ud.DeleteProxy = text('parent',h,'visible','off',...
                              'tag','ColorbarDeleteProxy',...
                              'handlevisibility','off',...
             'deletefcn','eval(''delete(get(gcbo,''''userdata''''))'','''')');
        ax = axes('Position', rect);
        setappdata(ax,'NonDataObject',[]); % For DATACHILDREN.M
        set(ud.DeleteProxy,'userdata',ax)
        set(h,'units',units)
    else
        axes(ax);
        ud = get(ax,'userdata');
    end
    
    % Create color stripe
    image(t,[0 1],(begslot:endslot),'Tag','TMW_COLORBAR','deletefcn','colorbar(''delete'')'); set(ax,'Ydir','normal')
    set(ax,'ytick',[])

    % set up axes deletefcn
    set(ax,'tag','Colorbar','deletefcn','colorbar(''delete'')')
    
else
  error('COLORBAR expects a handle, ''vert'', or ''horiz'' as input.')
end

if ~isfield(ud,'DeleteProxy'), ud.DeleteProxy = []; end
if ~isfield(ud,'origPos'), ud.origPos = []; end
ud.PlotHandle = h;
set(ax,'userdata',ud)
axes(h)
set(gcf,'NextPlot',origNextPlot)
if ~isempty(legend)
  legend % Update legend
end
if nargout>0, handle = ax; end

%--------------------------------
function h = gcda
%GCDA Get current data axes

h = datachildren(gcf);
if isempty(h) | any(h == gca)
  h = gca;
else
  h = h(1);
end
