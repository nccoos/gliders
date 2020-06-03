function icq4struct=icq4info(command,option)
%ICQ4INFO
%   ICQ4INFO provides information on an input fem_icq4_struct
%   or an icq4 file.  It optionally returns the icq4 data in
%   a fem_icq4_struct, and can read only the header information.
%
%   Input:  arg1  -  fem_icq4_struct or icq4 filename
%           arg2  -  If arg1 is an icq4 filename, then
%                    arg2 can be either 0 (read only
%                    file headers) or 1 (read entire file).
%                    If arg1 is a fem_icq4_struct, then
%                    arg2 is ignored.
%           arg2 can also be a [1X2] vector; the first element
%           is the "read" option above, and the second element
%           is whether or not (0|1) to post the display figure.
%           This option is ignored if arg1 is a fem_icq4_struct.
%           The default is to display the figure.
% 
%  Output:  fem_icq4_struct - If arg1 was a filename, ICQ4INFO 
%           returns the fem_icq4_struct if an output argument 
%           is provided. icq4 file information is displayed to 
%           a new figure.
%
% Call as: >> icq4info(icq4filename)
%          >> icq4=icq4info(icq4filename);
%          >> icq4=icq4info(icq4filename,0|1);
%          >> icq4=icq4info(icq4filename,[0|1 0|1]);
%          etc...
%

% Written by: Brian Blanton, Spring 99
if nargin>2
   error('Too many arguments to ICQ4INFO')
elseif nargin==0
   disp('Call as: icq4info(icq4filename)')
   return
elseif nargin==1
   if isa(command,'char')
      option=1;  % default to read entire icq4 file
   else
      option='none';
   end
   nofig=0;
else
   nofig=0;
   if isa(command,'struct') & exist('option')
      disp('Option to ICQ4INFO ignored.')
   elseif isa(command,'char') &~(strcmp(command,'Initialize')|...
				 strcmp(command,'SetInfo')| ...
  	                         strcmp(command,'CloseFig'))
      if option~=0 & option ~=1
         error('Option to ICQ4INFO must be 0|1') 
      end   
      [m,n]=size(option);
      if m*n==1,
	 nofig=0;
      elseif m*n==2
	 nofig=option(2);
      else
	 error('Too many elements in options vector to ICQ4INFO.')
      end
   end

end

if isa(command,'struct')
   icq4=command;
   command='Initialize';
   if nargout==1
      error(['ICQ4INFO does not return a fem_icq4_struct if the input is' ...
	     ' a fem_icq4_struct.'])
   end
elseif isa(command,'char')
   % Check to see of command is a icq4filename
   if exist(command)==2
      icq4filename=command;
      command='Initialize';
      switch option(1)
      case 0, disp(['Reading ' icq4filename ' headers.'])
      case 1, disp(['Reading ' icq4filename])
      end
      icq4=read_icq4(icq4filename,option(1));
   elseif ~(strcmp(command,'Initialize')|strcmp(command,'SetInfo')| ...
	    strcmp(command,'CloseFig'))
      error([command ' does not exist.'])
   end
end

% Return if the nofig option is set.
if nofig
   icq4struct=icq4;
   return
else

switch command
   case 'Initialize'
      % Figure defaults
      fontsize=get(0,'DefaultTextFontSize');
      set(0,'DefaultTextFontWeight','bold')
      %%%%  Build ICQ4INFO Figure
      sfig=figure('Position',[300 100 350 600],...
                  'IntegerHandle','off',...
                  'NumberTitle','off',...
	          'MenuBar','none',...
	          'Name','Icq4 Info',...
	          'Resize','on',...
 	          'Units','pixels',...
                  'Tag','Icq4_Info_Fig',...
                  'CloseRequestFcn','closereq',...
	          'Visible','on');
      uicontrol(sfig,'Style','frame',...
                     'Units','normalized',...
                     'Position',[.01 .005 .98 .985],...
                     'BackgroundColor',[1 1 1]*.7);
      uicontrol(sfig,'Style','text',...
                     'Units','normalized',...
                     'Position',[.02 .94 .96 .04],...
	             'BackgroundColor',[1 1 1]*.7,...
    	             'FontSize',fontsize,...
	             'Units','pixels',...
	             'String','Icq4 File Information');
	       	       
      varlist={'codename :'
               'casename :'
            'inqfilename :'
           'initcondname :'
    	             'nn :'
                    'nnv :'
    	            'day :'
       	          'month :'
    	           'year :'
           'curr_seconds :'
    	           'ZMID :'
    	           'ZOLD :'
    	          'UZMID :'
    	          'VZMID :'
    	          'WZMID :'
    	          'Q2MID :'
    	         'Q2LMID :'
    	         'TMPMID :'
    	         'SALMID :'};
      xs1=.02;xs2=.51;dx=.45;
      ystart=.85;dy=.04;dyy=.035;
      for i=1:length(varlist)
         y=ystart-(i-1)*dy;
         uicontrol(sfig,'Style','text',...
   		        'Units','normalized',...
   		        'Position',[xs1 y dx dyy],...
   		        'Units','pixels',...
   		        'String',varlist{i},...
    		        'HorizontalAlignment','right');
         tag=['Icq4_Info_Line' int2str(i)];
         string=varlist{i};
         string=['<' string(1:length(string)-2) '>'];
         uicontrol(sfig,'Style','text',...
   	    	        'Units','normalized',...
   		        'Position',[xs2 y dx dyy],...
   		        'BackgroundColor','w',...
   		        'Tag',tag,...
   		        'String',string,...
                        'ForeGroundColor','r',...
   		        'HorizontalAlignment','left');
      end

      uicontrol(sfig,'Style','push',...
                     'Units','normalized',...
                     'Position',[.4 .05 .20 .05],...
	             'Units','pixels',...
	             'String','Close',...
	             'Callback','icq4info(''CloseFig'')',...
	             'ToolTipString','Close icq4info Popup')
      if ~isempty(icq4)
	 icq4info('SetInfo',icq4);
      end
 case 'SetInfo'
      icq4=option;
      if ~isa(icq4,'struct')
         error('icq4 to ICQ4INFO not a structure')
      end
      % Get the Icq4_Info_Line handles
      fig=findobj(0,'Type','figure','Tag','Icq4_Info_Fig');
      for i=1:19
         Icq4_Info_Line(i)=...
               findobj(fig,'Type','uicontrol','Tag',['Icq4_Info_Line' int2str(i)]);
      end
      nn=icq4.nn;nnv=icq4.nnv;
      set(Icq4_Info_Line(1),'String',icq4.codename)
      set(Icq4_Info_Line(2),'String',icq4.casename)
      set(Icq4_Info_Line(3),'String',icq4.inqfilename)
      set(Icq4_Info_Line(4),'String',icq4.initcondname)
      set(Icq4_Info_Line(5),'String',int2str(nn))
      set(Icq4_Info_Line(6),'String',int2str(nnv))
      set(Icq4_Info_Line(7),'String',int2str(icq4.day))
      set(Icq4_Info_Line(8),'String',int2str(icq4.month))
      set(Icq4_Info_Line(9),'String',int2str(icq4.year))
      set(Icq4_Info_Line(10),'String',int2str(icq4.curr_seconds))
      string2d=['[' int2str(nn)  ' double]'];
      string3d=['[' int2str(nn) 'x' int2str(nnv) ' double]'];
      if isempty(icq4.HMID)
         string2d='not read in';
         string3d=string2d;
     end	 
      set(Icq4_Info_Line(11),'String',string3d)
      set(Icq4_Info_Line(12),'String',string3d)
      set(Icq4_Info_Line(13),'String',string3d)
      set(Icq4_Info_Line(14),'String',string3d)
      set(Icq4_Info_Line(15),'String',string3d)
      set(Icq4_Info_Line(16),'String',string3d)
      set(Icq4_Info_Line(17),'String',string3d)
      set(Icq4_Info_Line(18),'String',string3d)
      set(Icq4_Info_Line(19),'String',string3d)
      
      % Attach the icq4 structure to the fig UD
      set(fig,'UserData',icq4)
      
   case 'CloseFig'
      delete(findobj(0,'Type','figure','Tag','Icq4_Info_Fig')) 
end    % end switch
end    % end nofig if

if nargout~=0
   fig=findobj(0,'Type','figure','Tag','Icq4_Info_Fig');
   icq4struct=get(fig,'UserData');
end
