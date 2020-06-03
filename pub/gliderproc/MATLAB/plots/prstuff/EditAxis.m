function EditAxis(command, subcommand)
%
% function EditAxis(command, subcommand)
%
% Abstract:
%   Edit axis limits and tick marks.  Use with Prmenu
%
% Commands and subcommands
%   initialize
%   editlim
%      whichaxis
%      editvalues
%      editmode
%      editmark
%      editlabel
%   aspect
%      data
%      axes
%      default
%   reset
%      done
%      reset
%      cancel
%      newaxestouched
%   info
%
% The following commands and subcommands are used for changes
% to the curaxes but not as part of the Edit Limits Figure
%   axis
%      equal
%      square
%      normal
%      auto
%      image
%   scale
%      linear
%      semilogx
%      semilogy
%      loglog
%   grid
%      majgrid
%      minortick
%      minorgrid
%
% History:
% o Original concepts, template, and design from Brian Blanton
%   and Keith Rogers
% o 13 April, 1995 re-create figure window with edit limits,
%   aspect ratio, and tick marks, and tick labels.  
% 
%

% get needed globals and define variable used throughout
global LASTAXIS LASTFIGURE
axestr = ['XYZ'];

curfig=LASTFIGURE;
set(curfig,'Pointer','watch')

if isempty(LASTAXIS)
  curaxes=gca;
else 
  curaxes=LASTAXIS;
end

if nargin < 1
  command = 'initialize';
end

if strcmp(command, 'initialize')
  
  EditAxisFig=findobj(0,'Type','figure','Tag','EditAxisFig');
  if ~isempty(EditAxisFig),return,end
     
  EditAxisFig = figure('Position',[150 350 435 303],...
      'NumberTitle','off',...
      'Name','Edit Axis Limits',...
      'NextPlot','new',...
      'Tag','EditAxisFig');

  % choose axis to edit 
  ChooseFrame=uicontrol('Parent',EditAxisFig, ...
      'CallBack','', ... 	  
      'Style','frame',...
      'String','Axes Limits', ...
      'Horiz', 'center', ...
      'Position',[13 170 90 120], ...
      'Tag','ChooseFrame');
  
  ChooseText=uicontrol('Parent',EditAxisFig, ...
      'CallBack','', ... 	  
      'Style','text',...
      'String','Choose an axis', ...
      'Horiz', 'center', ...
      'Position',[13 155+110 90 20], ...
      'Tag','ChooseText');
  
  ChooseMenu=uicontrol('Parent',EditAxisFig, ...
      'CallBack','EditAxis(''editlim'')', ... 	  
      'Style','popupmenu',...
      'String',' X | Y | Z ', ...
      'Horiz', 'center', ...
      'Position',[13+10 155+80 70 20], ...
      'Tag','ChooseMenu');
  

  %   edit limits 
  LimFrame=uicontrol('Parent',EditAxisFig, ...
      'CallBack','', ... 	  
      'Style','frame',...
      'String','Axes Limits', ...
      'Horiz', 'center', ...
      'Position',[13+105 170 95 120], ...
      'Tag','LimFrame');
  
  LimText=uicontrol('Parent',EditAxisFig, ...
      'CallBack','', ... 	  
      'Style','text',...
      'String','Axes Limits', ...
      'Horiz', 'center', ...
      'Position',[13+105 155+110 95 20], ...
      'Tag','LimText');
    
  xl=get(curaxes,'Xlim');  
  
  LimEdit=uicontrol('Parent',EditAxisFig, ...
      'CallBack','EditAxis(''editlim'',''editvalues'')', ... 	  
      'Style','edit',...
      'Background', 'w', ...
      'Foreground', 'r', ...
      'Max', 2, ...
      'String',vec2str(xl), ...
      'HorizontalAlignment', 'center', ...
      'Position',[13+115 155+30 70 30], ...
      'Tag','LimEdit');
  
  LimMode=uicontrol('Parent',EditAxisFig, ...
      'CallBack','EditAxis(''editlim'',''editmode'')', ... 	  
      'Style','checkbox',...
      'String','Auto', ...
      'Horiz', 'center', ...
      'Position',[13+115 155+80 70 20], ...
      'Tag','LimMode');

  if (strcmp('auto',get(curaxes,'XLimMode')) )
    set(LimMode, ...
	'Value', 1, ...
	'String', 'Auto=on');
  else
    set(LimMode, ...
	'Value', 0, ...
	'String', 'Auto=off');
  end
  

  
  % edit ticks
  TicFrame=uicontrol('Parent',EditAxisFig, ...
      'CallBack','', ... 	  
      'Style','frame',...
      'String','Tick Marks & Labels', ...
      'Horiz', 'center', ...
      'Position',[226 10 190 280], ...
      'Tag','TicFrame');
  
  TicText1=uicontrol('Parent',EditAxisFig, ...
      'CallBack','', ... 	  
      'Style','text',...
      'String','Tick Marks', ...
      'Horiz', 'center', ...
      'Position',[226+10 10+230 80 20], ...
      'Tag','TicText1');  
  
  TicText2=uicontrol('Parent',EditAxisFig, ...
      'CallBack','', ... 	  
      'Style','text',...
      'String','Labels', ...
      'Horiz', 'center', ...
      'Position',[226+100 10+230 80 20], ...
      'Tag','TicText2');  

  TicText3=uicontrol('Parent',EditAxisFig, ...
      'CallBack','', ... 	  
      'Style','text',...
      'String','Press ''Cntl-Return'' ', ...
      'Horiz', 'center', ...
      'Position',[226 10+10 190 20], ...
      'Tag','TicText3');  

  xticmarks = get(curaxes,'XTick');
  xticlabels = get(curaxes,'XTickLabels');
  TicMarkEdit=uicontrol('Parent',EditAxisFig, ...
      'CallBack','EditAxis(''editlim'',''editmark'')', ... 	  
      'Style','edit',...
      'Background', 'w', ...
      'Foreground', 'r', ...
      'Max', 2, ...
      'String',vec2str(xticmarks), ...
      'HorizontalAlignment', 'center', ...
      'Position',[226+10 10+30 80 200], ...
      'Tag','TicMarkEdit');

  TicLabelEdit=uicontrol('Parent',EditAxisFig, ...
      'CallBack','EditAxis(''editlim'',''editlabel'')', ... 	  
      'Style','edit',...
      'Background', 'w', ...
      'Foreground', 'r', ...
      'Max', 2, ...
      'String',xticlabels, ...
      'HorizontalAlignment', 'center', ...
      'Position',[226+100 10+30 80 200], ...
      'Tag','TicLabelEdit');
  
  
  % edit aspect
  AspFrame=uicontrol('Parent',EditAxisFig, ...
      'CallBack','', ... 	  
      'Style','frame',...
      'String','Aspect', ...
      'Horiz', 'center', ...
      'Position',[13 63 200 95], ...
      'Tag','AspFrame');
  
  AspText1=uicontrol('Parent',EditAxisFig, ...
      'CallBack','', ... 	  
      'Style','text',...
      'String','Aspect Ratio (H/W)', ...
      'Horiz', 'center', ...
      'Position',[13+2 63+75 196 20], ...
      'Tag','AspText1');  

  AspText2=uicontrol('Parent',EditAxisFig, ...
      'CallBack','', ... 	  
      'Style','text',...
      'String','Data: ', ...
      'Horiz', 'right', ...
      'Position',[13+5 63+50 40 20], ...
      'Tag','AspText2');  

  AspText3=uicontrol('Parent',EditAxisFig, ...
      'CallBack','', ... 	  
      'Style','text',...
      'String','Axes: ', ...
      'Horiz', 'right', ...
      'Position',[13+5 63+25 40 20], ...
      'Tag','AspText3');  

  asp = get(curaxes, 'Aspect');
  AspDataEdit=uicontrol('Parent',EditAxisFig, ...
      'CallBack','EditAxis(''aspect'',''data'')', ... 	  
      'Background', 'w', ...
      'Foreground', 'r', ...
      'Style','edit',...
      'String',num2str(asp(2)), ...
      'Horiz', 'center', ...
      'Position',[13+5+40 63+50 70 20], ...
      'Tag','AspDataEdit');  

  AspAxesEdit=uicontrol('Parent',EditAxisFig, ...
      'CallBack','EditAxis(''aspect'',''axes'')', ... 	  
      'Background', 'w', ...
      'Foreground', 'r', ...
      'Style','edit',...
      'String',num2str(asp(1)), ...
      'Horiz', 'center', ...
      'Position',[13+5+40 63+25 70 20], ...
      'Tag','AspAxesEdit');  

  AspDefault = uicontrol('Parent',EditAxisFig,...   
      'Style','pushbutton',...
      'String','Default',...
      'Position',[13+5+125 63+38 50 20],...
      'Callback','EditAxis(''aspect'',''default'')',...
      'Tag','AspDefault');

  
  % Done, cancel, and reset buttons
  DoneButton = uicontrol('Parent',EditAxisFig,...   
      'BackgroundColor',[0;1;0],...
      'Style','pushbutton',...
      'String','Done',...
      'Position',[23 35 50 20],...
      'Callback','EditAxis(''reset'',''done'')',...
      'Tag','DoneButton');

  ResetButton = uicontrol('Parent',EditAxisFig,...   
      'BackgroundColor',[1;1;0],...
      'Style','pushbutton',...
      'String','Reset',...
      'Position',[23+63 35 50 20],...
      'Callback','EditAxis(''reset'',''reset'')',...
      'Tag','ResetButton');
  
  CancelButton = uicontrol('Parent',EditAxisFig,...   
      'BackgroundColor',[1;0;0],...
      'Style','pushbutton',...
      'String','Cancel',...
      'Position',[23+63+63 35 50 20],...
      'Callback','EditAxis(''reset'',''cancel'')',...
      'Tag','CancelButton');

  HelpButton = uicontrol('Parent',EditAxisFig,...   
      'BackgroundColor',[1;1;1],...
      'ForegroundColor',[0;0;0],...
      'Style','pushbutton',...
      'String','HELP',...
      'Position',[23+63 10 50 20],...
      'Callback','EditAxis(''info'')',...
      'Tag','HelpButton');
  
  % Use hidden axes (non-visible) to store original data about the limits
  % so that original limits can be restored by user if it is desired
  HiddenAxes = axes('Parent',EditAxisFig,...
      'Visible', 'off', ...
      'Tag', 'HiddenAxes');
    
  % get aspect data and set to in HiddenAxes
  set(HiddenAxes, 'Aspect', get(curaxes, 'Aspect'));
  
  % for each axiss get limits, ticks, labels, and modes (auto or manual)
  % of limits, ticks, and labels  and set these to the HiddenAxes
  for i=1:3
    set(HiddenAxes, [axestr(i) 'Lim'], get(curaxes, [axestr(i) 'Lim']));
    set(HiddenAxes, [axestr(i) 'LimMode'], ...
	get(curaxes, [axestr(i) 'LimMode']));
    set(HiddenAxes, [axestr(i) 'Tick'], get(curaxes, [axestr(i) 'Tick']));
    set(HiddenAxes, [axestr(i) 'TickMode'], ...
	get(curaxes, [axestr(i) 'TickMode']));
    newlabel = get(curaxes, [axestr(i) 'TickLabels']);
    if ~isempty(newlabel)
      set(HiddenAxes, [axestr(i) 'TickLabels'], newlabel);
    end
    set(HiddenAxes, [axestr(i) 'TickLabelMode'], ...
	get(curaxes, [axestr(i) 'TickLabelMode']));
  end 					% for each axis
  
elseif strcmp(command, 'editlim')
  
  % keeps track of user changes to limits, marks and labels

  if nargin < 2
    subcommand = 'whichaxis';
  end
  
  ChooseMenu=findobj(0,'Type','uicontrol','Tag','ChooseMenu');
  LimEdit=findobj(0,'Type','uicontrol','Tag','LimEdit');
  LimMode=findobj(0,'Type','uicontrol','Tag','LimMode');
  TicMarkEdit=findobj(0,'Type','uicontrol','Tag','TicMarkEdit');
  TicLabelEdit=findobj(0,'Type','uicontrol','Tag','TicLabelEdit');
    
  whichaxis = get(ChooseMenu,'Value');	% 1=X,2=Y,3=Z

  if strcmp(subcommand,'whichaxis')
    
    % depending on which axis user is concerned with get
    % limits and limit mode from curraxes and then show them on
    % uicontrols for editing limits, tick marks, and labels
    
    %show limits
    lim = get(curaxes, [axestr(whichaxis),'lim']);
    set(LimEdit, 'String', vec2str(lim));
    
    % show limit mode
    if ( strcmp('auto',get(curaxes,[axestr(whichaxis),'LimMode'])) )
      set(LimMode, ...
	  'Value', 1, ...
	  'String', 'Auto=on');
    else
      set(LimMode, ...
	  'Value', 0, ...
	  'String', 'Auto=off');
    end
    
    % show tick marks and tick labels
    marks = get(curaxes, [axestr(whichaxis),'Tick']);
    set(TicMarkEdit, 'String', vec2str(marks));
    labels = get(curaxes, [axestr(whichaxis),'TickLabels']);
    set(TicLabelEdit, 'String', labels);
    
  elseif strcmp(subcommand, 'editvalues')
    
    % set current axes to limits specified by user after
    % 'enter' or 'cntrl-return' is hit
    newlim = str2vec(get(LimEdit,'String'));
    set(curaxes, [axestr(whichaxis),'lim'], newlim);
    
    % if set by user then auto limit mode is manual
    if ( strcmp('auto',get(curaxes,[axestr(whichaxis),'LimMode'])) )
      set(LimMode, ...
	  'Value', 1, ...
	  'String', 'Auto=on');
    else
      set(LimMode, ...
	  'Value', 0, ...
	  'String', 'Auto=off');
    end
    
    % show new tick marks and tick labels
    set(curaxes, [axestr(whichaxis),'TickMode'], 'auto');
    set(curaxes, [axestr(whichaxis),'TickLabelMode'], 'auto');
    marks = get(curaxes, [axestr(whichaxis),'Tick']);
    set(TicMarkEdit, 'String', vec2str(marks));
    labels = get(curaxes, [axestr(whichaxis),'TickLabels']);
    set(TicLabelEdit, 'String', labels);
    
    
  elseif strcmp(subcommand, 'editmode')

    % set auto or manual mode if chosen
    if ( get(LimMode, 'Value')==1 )
      set(LimMode, ...
	  'String', 'Auto=on');
      set(curaxes, [axestr(whichaxis),'LimMode'], 'auto')

      % now get auto limits and show them in LimEdit
      lim = get(curaxes, [axestr(whichaxis),'lim']);
      set(LimEdit, 'String', vec2str(lim));

      % show new tick marks and tick labels
      set(curaxes, [axestr(whichaxis),'TickMode'], 'auto');
      set(curaxes, [axestr(whichaxis),'TickLabelMode'], 'auto');
      marks = get(curaxes, [axestr(whichaxis),'Tick']);
      set(TicMarkEdit, 'String', vec2str(marks));
      labels = get(curaxes, [axestr(whichaxis),'TickLabels']);
      set(TicLabelEdit, 'String', labels);
    else
      set(LimMode, ...
	  'String', 'Auto=off');
      set(curaxes, [axestr(whichaxis),'LimMode'], 'manual')      
    end
    
  elseif strcmp(subcommand, 'editmark')

    % set current axes to tick marks specified by user after
    % 'enter' or 'cntrl-return' is hit
    newmarks = str2vec(get(TicMarkEdit,'String'));
    set(curaxes, [axestr(whichaxis),'Tick'], newmarks);
    labels = get(curaxes, [axestr(whichaxis),'TickLabels']);
    set(TicLabelEdit, 'String', labels);

  elseif strcmp(subcommand, 'editlabel')

    % set current axes to tick marks specified by user after
    % 'enter' or 'cntrl-return' is hit
    newlabels = get(TicLabelEdit,'String');
    set(curaxes, [axestr(whichaxis),'TickLabels'], newlabels);
    
  end 					% editlim subcommands

elseif strcmp(command, 'aspect')
  
  % find Edit Axis Figure and hidden axes of original axes data
  EditAxisFig=findobj(0,'Type','figure','Tag','EditAxisFig');

  AspDataEdit=findobj(0,'Type','uicontrol','Tag','AspDataEdit');
  AspAxesEdit=findobj(0,'Type','uicontrol','Tag','AspAxesEdit');

  aspData = str2num(get(AspDataEdit, 'String'));
  aspAxes = str2num(get(AspAxesEdit, 'String'));

  if strcmp(subcommand, 'data')
    set(curaxes, 'Aspect', [aspAxes, aspData]);
  elseif strcmp(subcommand, 'axes')
    set(curaxes, 'Aspect', [aspAxes, aspData]);
  elseif strcmp(subcommand, 'default')
    set(curaxes, 'Aspect', [NaN, NaN]);
    set(AspDataEdit, 'String', num2str(NaN));
    set(AspAxesEdit, 'String', num2str(NaN));
  end

elseif strcmp(command, 'reset')

  % find Edit Axis Figure and hidden axes of original axes data
  EditAxisFig=findobj(0,'Type','figure','Tag','EditAxisFig');
  
  ChooseMenu=findobj(0,'Type','uicontrol','Tag','ChooseMenu');
  LimEdit=findobj(0,'Type','uicontrol','Tag','LimEdit');
  LimMode=findobj(0,'Type','uicontrol','Tag','LimMode');
  TicMarkEdit=findobj(0,'Type','uicontrol','Tag','TicMarkEdit');
  TicLabelEdit=findobj(0,'Type','uicontrol','Tag','TicLabelEdit');

  AspDataEdit=findobj(0,'Type','uicontrol','Tag','AspDataEdit');
  AspAxesEdit=findobj(0,'Type','uicontrol','Tag','AspAxesEdit');

  HiddenAxes=findobj(0,'Type','axes','Tag','HiddenAxes');
  
  whichaxis = get(ChooseMenu,'Value');	% 1=X,2=Y,3=Z
  
  
  if strcmp(subcommand, 'done')
  
    % close Edit Axis Figure window and retain all changes to curaxes
  
    % close Edit Axis Figure (hidden axes is child of this figure
    % so it deleted as well
    delete(EditAxisFig)
    
  elseif strcmp(subcommand, 'show')
    
    % show data of curaxes in uicontrols
    set(ChooseMenu, 'Value', 1);
    whichaxis=1;			% reset to X

    % set lim
    lim = get(curaxes, [axestr(whichaxis),'Lim']);
    set(LimEdit, 'String', vec2str(lim));
    
    % if set by user then auto limit mode is manual
    if ( strcmp('auto',get(curaxes,[axestr(whichaxis),'LimMode'])) )
      set(LimMode, ...
	  'Value', 1, ...
	  'String', 'Auto=on');
    else
      set(LimMode, ...
	  'Value', 0, ...
	  'String', 'Auto=off');
    end
    
    % show new tick marks and tick labels
    marks = get(curaxes, [axestr(whichaxis),'Tick']);
    set(TicMarkEdit, 'String', vec2str(marks));
    labels = get(curaxes, [axestr(whichaxis),'TickLabels']);
    set(TicLabelEdit, 'String', labels);
    
    % aspect 
    asp = get(curaxes, 'Aspect');
    set(AspDataEdit, 'String', num2str(asp(2)));
    set(AspAxesEdit, 'String', num2str(asp(1)));
  
  elseif strcmp(subcommand, 'reset')
  
    % get original axes data from hidden axes and reset current axes 
    % data to this data
    
    set(curaxes, 'Aspect', get(HiddenAxes, 'Aspect'));
    
    % for each axis get limits, ticks, labels, and modes (auto or manual)
    % of limits, ticks, and labels  and set these to the HiddenAxes
    for i=1:3
      set(curaxes, [axestr(i) 'Lim'], get(HiddenAxes, [axestr(i) 'Lim']));
      set(curaxes, [axestr(i) 'LimMode'], ...
	  get(HiddenAxes, [axestr(i) 'LimMode']));
      set(curaxes, [axestr(i) 'Tick'], get(HiddenAxes, [axestr(i) 'Tick']));
      set(curaxes, [axestr(i) 'TickMode'], ...
	  get(HiddenAxes, [axestr(i) 'TickMode']));
      newlabel = get(HiddenAxes, [axestr(i) 'TickLabels']);
      if ~isempty(newlabel)
	set(curaxes, [axestr(i) 'TickLabels'], newlabel);
      end
      set(curaxes, [axestr(i) 'TickLabelMode'], ...
	  get(HiddenAxes, [axestr(i) 'TickLabelMode']));
    end 				% for each axis
    
    % reset data in uicontrols of Edit Axes to reflect this
    % show all new axes related data in Edit Axis Figure
    EditAxis('reset', 'show');
    
  elseif strcmp(subcommand, 'cancel')
    
    % get original axes data from hidden axes and reset current axes
    % to this data

    set(curaxes, 'Aspect', get(HiddenAxes, 'Aspect'));
    
    % for each axis get limits, ticks, labels, and modes (auto or manual)
    % of limits, ticks, and labels  and set these to the HiddenAxes
    for i=1:3
      set(curaxes, [axestr(i) 'Lim'], get(HiddenAxes, [axestr(i) 'Lim']));
      set(curaxes, [axestr(i) 'LimMode'], ...
	  get(HiddenAxes, [axestr(i) 'LimMode']));
      set(curaxes, [axestr(i) 'Tick'], get(HiddenAxes, [axestr(i) 'Tick']));
      set(curaxes, [axestr(i) 'TickMode'], ...
	  get(HiddenAxes, [axestr(i) 'TickMode']));
      newlabel = get(HiddenAxes, [axestr(i) 'TickLabels']);
      if ~isempty(newlabel)
	set(curaxes, [axestr(i) 'TickLabels'], newlabel);
      end
      set(curaxes, [axestr(i) 'TickLabelMode'], ...
	  get(HiddenAxes, [axestr(i) 'TickLabelMode']));
    end 				% for each axis
    
    % close Edit Axis Figure
    delete(EditAxisFig)
  
  elseif strcmp(subcommand, 'newaxestouched')
    
    % reset hidden axes to hold new data of last axes touched
    set(HiddenAxes, 'Aspect', get(curaxes, 'Aspect'));
    
    % for each axis
    for i=1:3
      set(HiddenAxes, [axestr(i) 'Lim'], get(curaxes, [axestr(i) 'Lim']));
      set(HiddenAxes, [axestr(i) 'LimMode'], ...
	  get(curaxes, [axestr(i) 'LimMode']));
      set(HiddenAxes, [axestr(i) 'Tick'], get(curaxes, [axestr(i) 'Tick']));
      set(HiddenAxes, [axestr(i) 'TickMode'], ...
	  get(curaxes, [axestr(i) 'TickMode']));
      newlabel = get(curaxes, [axestr(i) 'TickLabels']);
      if ~isempty(newlabel)
	set(HiddenAxes, [axestr(i) 'TickLabels'], newlabel);
      end
      set(HiddenAxes, [axestr(i) 'TickLabelMode'], ...
	  get(curaxes, [axestr(i) 'TickLabelMode']));
    end 				% for each axis
    
    % show all new axes related data in Edit Axis Figure
    EditAxis('reset', 'show');
    
  end 					% reset subcommands
  
elseif strcmp(command,'info');
  ttlStr='Edit Axis Help';
  hlpStr= ...                                            
      ['                                              '  
       '                                              '  
       '                                              '];
  PrHelp(ttlStr,hlpStr);     
  
elseif strcmp(command, 'axis')
  
  EditAxisFig=findobj(0,'Type','figure','Tag','EditAxisFig');

  gca=curaxes;
  axis(subcommand)
  if ~isempty(EditAxisFig)
    EditAxis('reset', 'show')
  end
   
elseif strcmp(command, 'scale')
  
  EditAxisFig=findobj(0,'Type','figure','Tag','EditAxisFig');

  if strcmp(subcommand, 'linear')
    set(curaxes, 'xscale', 'linear', 'yscale', 'linear');

  elseif strcmp(subcommand, 'semilogx')
    set(curaxes, 'xscale', 'log', 'yscale', 'linear');
    
  elseif strcmp(subcommand, 'semilogy')
    set(curaxes, 'xscale', 'linear', 'yscale', 'log');
    
  elseif strcmp(subcommand, 'loglog')
    set(curaxes, 'xscale', 'log', 'yscale', 'log');
  
  end

  if ~isempty(EditAxisFig)
    EditAxis('reset', 'show')
  end

elseif strcmp(command, 'grid')

  EditAxisFig=findobj(0,'Type','figure','Tag','EditAxisFig');

  if strcmp(subcommand, 'majgrid')
    
    PrMajGrid = findobj(0,'Type','uimenu','Tag','PrMajGrid');
    if strcmp(get(curaxes, 'XGrid'), 'off')
      set(curaxes, 'XGrid','on','YGrid','on', 'ZGrid', 'on');
      %set(PrMajGrid, 'checked', 'on');
    else
      set(curaxes, 'XGrid','off','YGrid','off', 'ZGrid', 'off');
      %set(PrMajGrid, 'checked', 'off');
    end
    
    
    
  elseif strcmp(subcommand, 'minortick')

    if strcmp(get(curaxes, 'XMinorTicks'), 'off')
      set(curaxes, 'XMinorTicks','on','YMinorTicks','on',...
	  'ZMinorTicks', 'on');
    else
      set(curaxes, 'XMinorTicks','off','YMinorTicks','off', ...
	  'ZMinorTicks', 'off');
    end
    
  elseif strcmp(subcommand, 'minorgrid')
   
    if strcmp(get(curaxes, 'XMinorGrid'), 'off')
      set(curaxes, 'XMinorGrid','on','YMinorGrid','on', 'ZMinorGrid', 'on');
    else
      set(curaxes, 'XMinorGrid','off','YMinorGrid','off', 'ZMinorGrid', 'off');
    end
    
  end

elseif strcmp(command, 'box')

  EditAxisFig=findobj(0,'Type','figure','Tag','EditAxisFig');
  if strcmp(get(curaxes, 'box'), 'off')
    set(curaxes, 'box', 'on');
  else
    set(curaxes, 'box', 'off')
  end
  
end 					% EditAxis commands

if ~isnan(curfig),
    set(curfig,'Pointer','arrow');
end
