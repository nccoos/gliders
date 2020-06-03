function PrintSetup(command,subcommand,comnum);
%
% PRINTSETUP creates an interactive printed-page layout editor.
%
%             Creates a dialog box which allows the user
%             to customize the printing options for the
%             current figure.  Most of the items should
%             be self explanatory. A picture is drawn at
%             the bottom of the figure showing the page
%             and the positioning of the figure's contents
%             on it.  Click and drag on the edges of the
%             inner rectangle to resize, and in the center
%             to reposition the figure on the printed page.
%
% Call as: >> PrintSetup
%
% Keith Rogers 12/94
% Minor Mods by Brian Blanton, Mar 95.

%Copyright (c) 1995 by Keith Rogers
figs=get(0,'Children');
Pfig=findobj(figs,'flat','Type','figure','Tag','FEDAR Plot F');
Pax=findobj(Pfig,'Type','axes','Tag','FEDAR Plot A');
Ofig=findobj(figs,'flat','Type','figure','Tag','FEDAR Opt F');
Oax=findobj(Ofig,'Type','axes','Tag','FEDAR Opt A');   

PSFigure=findobj(figs,'flat','Type','figure','Tag','PrintSetup');
if ~isempty(PSFigure)&nargin<1,return,end

if(nargin<1)
	ShrinkFactor = 3.7;					
	Background = 'b';
	Foreground = 'w';
        if isempty(Pfig)
 	   fig = gcf;
 	else
	   fig = Pfig;
	end
	PSFigure = figure('Name','Print Setup',...
	                  'NumberTitle','off',...
			  'Position',[100 40 380 420],...
			  'NextPlot','Add',...
			  'Color',Background,...
			  'Tag','PrintSetup');
	PaperPosition = get(fig,'PaperPosition');
	PaperSize = get(fig,'PaperSize');
	uicontrol(PSFigure,'Style','Text',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String','Margins',...
			   'Position',[25 400 60 20]);
	uicontrol(PSFigure,'Style','Text',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String','Bottom',...
			   'HorizontalAlignment','Right',...
			   'Position',[5 380 60 20]);
	uicontrol(PSFigure,'Style','Edit',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String',num2str(PaperPosition(2)),...
			   'Position',[70 380 60 20],...
			   'Tag','Bottom',...
			   'Callback','PrintSetup(''Margins'',''Bottom'')');
	uicontrol(PSFigure,'Style','Text',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String','Left',...
			   'HorizontalAlignment','Right',...
			   'Position',[5 355 60 20]);
	uicontrol(PSFigure,'Style','Edit',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String',num2str(PaperPosition(1)),...
			   'Position',[70 355 60 20],...
			   'Tag','Left',...
			   'Callback','PrintSetup(''Margins'',''Left'')');
	uicontrol(PSFigure,'Style','Text',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String','Top',...
			   'HorizontalAlignment','Right',...
			   'Position',[5 330 60 20]);
	uicontrol(PSFigure,'Style','Edit',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String',num2str(PaperSize(2)-PaperPosition(2)-PaperPosition(4)),...
			   'Position',[70 330 60 20],...
			   'Tag','Top',...
			   'Callback','PrintSetup(''Margins'',''Top'')');
	uicontrol(PSFigure,'Style','Text',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String','Right',...
			   'HorizontalAlignment','Right',...
			   'Position',[5 305 60 20]);
	uicontrol(PSFigure,'Style','Edit',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String',num2str(PaperSize(1)-PaperPosition(1)-PaperPosition(3)),...
			   'Position',[70 305 60 20],...
			   'Tag','Right',...
			   'Callback','PrintSetup(''Margins'',''Right'')');	
	uicontrol(PSFigure,'Style','Text',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String','Paper Type',...
			   'HorizontalAlignment','Left',...
			   'Position',[150 400 100 20]);
	PaperType = get(fig,'PaperType');
	if(strcmp(PaperType,'usletter'))
		val = 1;
	elseif(strcmp(PaperType,'uslegal'))
		val = 2;
	elseif(strcmp(PaperType,'a3'))
		val = 3;
	elseif(strcmp(PaperType,'a4letter'))
		val = 4;
	elseif(strcmp(PaperType,'a5'))
		val = 5;
	elseif(strcmp(PaperType,'b4'))
		val = 6;
	else
		val = 7;
	end
	uicontrol(PSFigure,'Style','popupmenu',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String','usletter|uslegal|a3|a4letter|a5|b4|tabloid',...
			   'Value',val,...
			   'Tag','PaperType',...
			   'Callback','PrintSetup(''PaperType'')',...
			   'Position',[150 380 120 20]);
	uicontrol(PSFigure,'Style','Text',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'HorizontalAlignment','left',...
			   'String','Paper Orientation',...
			   'Position',[150 355 120 20]);
	Orient = get(fig,'PaperOrientation');
	if(strcmp(Orient,'portrait'))
		val = 1;
	elseif(strcmp(Orient,'landscape'))
		val = 2;
	else
		val = 3;
	end
	uicontrol(PSFigure,'Style','popupmenu',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String','Portrait|Landscape|Tall',...
			   'Tag','Orient',...
			   'Value',val,...
			   'Callback','PrintSetup(''Orient'')',...
			   'Position',[150 335 120 20]);
	uicontrol(PSFigure,'Style','checkbox',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String','Invert Hardcopy',...
			   'Tag','Invert',...
			   'Value',strcmp(get(fig,'InvertHardCopy'),'on'),...
			   'Callback','PrintSetup(''Invert'')',...
			   'Position',[150 305 130 20]);
	uicontrol(PSFigure,'Style','Text',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String','PaperUnits',...
			   'HorizontalAlignment','Left',...
			   'Position',[270 400 90 20]);
						
	PaperUnits = get(fig,'PaperUnits');
	if(strcmp(PaperUnits,'inches'))
		val = 1;
	elseif(strcmp(PaperUnits,'centimeters'))
		val = 2;
	elseif(strcmp(PaperUnits,'normalized'))
		val = 3;
	else
		val = 4;
	end
	
	uicontrol(PSFigure,'Style','popupmenu',...
			   'BackGr',Background,...
			   'ForeGr',Foreground,...
			   'String','inches|centimeters|normalized|points',...
			   'Tag','PaperUnits',...
			   'Value',val,...
			   'Callback','PrintSetup(''PaperUnits'')',...
			   'Position',[280 380 90 20]);
	uicontrol(PSFigure,'Style','pushbutton',...
			   'BackGr','g',...
			   'ForeGr','k',...
			   'String','APPLY',...
			   'Tag','APPLY',...
			   'Callback','PrintSetup(''APPLY'')',...
			   'Position',[290 340 80 25]);
	uicontrol(PSFigure,'Style','pushbutton',...
			   'BackGr','r',...
			   'ForeGr','k',...
			   'String','Cancel',...
			   'Tag','Cancel',...
			   'Callback','PrintSetup(''Cancel'')',...
			   'Position',[290 305 80 25]);
	
	axes('Units',PaperUnits,...
		 'Position',[.7 .25 PaperSize(1)/ShrinkFactor PaperSize(2)/ShrinkFactor],...
		 'box','on')
	axis('equal');
	axis([0 PaperSize(1) 0 PaperSize(2)]);
	PlotRect = [PaperPosition(1) PaperPosition(2);
	            PaperPosition(1)+PaperPosition(3) PaperPosition(2);
				PaperPosition(1)+PaperPosition(3) PaperPosition(2)+PaperPosition(4);			  
				PaperPosition(1) PaperPosition(2)+PaperPosition(4)];
	PatchObj = patch('XData',PlotRect(:,1),...
						 'YData',PlotRect(:,2),...
						 'EdgeColor','w',...
						 'FaceColor',Background);
	set(PatchObj,'ButtonDownFcn','PrintSetup(''Resize'')');
	UserData = [fig;PatchObj;ShrinkFactor];
	set(gcf,'UserData',UserData);
	set(gcf,'PaperPosition',PaperPosition,...
			'PaperType',PaperType,...
			'PaperOrientation',Orient,...
			'PaperUnits',PaperUnits);
	axis(axis);
	hold on;

elseif(strcmp(command,'DrawPage'))

	UserData = get(gcf,'UserData');
	fig = UserData(1);
	PatchObj = UserData(2);
	ShrinkFactor = UserData(3);
	
	PaperPosition = get(gcf,'PaperPosition');
	PaperUnits = get(gcf,'PaperUnits');
	if(strcmp(get(gca,'Units'),'normalized'))
		set(gca,'units',PaperUnits);	
	else
		set(gcf,'PaperUnits',get(gca,'Units'));
		set(fig,'PaperUnits',get(gca,'Units'));
	end
	PaperSize = get(gcf,'PaperSize');
	set(gcf,'PaperUnits',PaperUnits);
	AxPos = get(gca,'Position');
	set(gca,'Position',[AxPos(1) AxPos(2) PaperSize(1)/ShrinkFactor PaperSize(2)/ShrinkFactor]);
	set(gca,'Units',PaperUnits);
	if(strcmp(PaperUnits,'normalized'))
		axis('normal');
		axis([0 1 0 1]);
	else
		axis('equal');
		PaperSize = get(gcf,'PaperSize');
		axis([0 PaperSize(1) 0 PaperSize(2)]);
	end
	PlotRect = [PaperPosition(1) PaperPosition(2);
	            PaperPosition(1)+PaperPosition(3) PaperPosition(2);
				PaperPosition(1)+PaperPosition(3) PaperPosition(2)+PaperPosition(4);			  
				PaperPosition(1) PaperPosition(2)+PaperPosition(4)];
	
	set(PatchObj,'EraseMode','Xor',...
				'XData',PlotRect(:,1),...
				'YData',PlotRect(:,2));
	set(PatchObj,'EraseMode','Normal');
	axis(axis);
	hold on;
elseif(strcmp(command,'Resize'))
	UserData = get(gcf,'UserData');
	PatchObj = UserData(2);
	if(nargin<2)
		cp = get(gca,'CurrentPoint');
		XData = get(PatchObj,'XData');
		YData = get(PatchObj,'YData');
		minx = min(XData);
		miny = min(YData);
		ext = [minx miny max(XData)-minx max(YData)-miny];
		set(PatchObj,'UserData',ext);
		if(cp(1,1)<ext(1)+.2*ext(3))
			if(cp(1,2)<ext(2)+.2*ext(4)) 		% Lower Left Corner
				set(gcf,'WindowButtonMotionFcn','PrintSetup(''Resize'',''Corner'',1)');
			elseif(cp(1,2)>ext(2)+.8*ext(4)) 	% Upper Left Corner
				set(gcf,'WindowButtonMotionFcn','PrintSetup(''Resize'',''Corner'',2)');
			else								% Left Side
				set(gcf,'WindowButtonMotionFcn','PrintSetup(''Resize'',''Side'',1)');
			end
		elseif(cp(1,1)>ext(1)+.8*ext(3))
			if(cp(1,2)<ext(2)+.2*ext(4)) 		% Lower Right Corner
				set(gcf,'WindowButtonMotionFcn','PrintSetup(''Resize'',''Corner'',4)');
			elseif(cp(1,2)>ext(2)+.8*ext(4)) 	% Upper Right Corner
				set(gcf,'WindowButtonMotionFcn','PrintSetup(''Resize'',''Corner'',3)');
			else								% Right Side
				set(gcf,'WindowButtonMotionFcn','PrintSetup(''Resize'',''Side'',3)');
			end
		elseif(cp(1,2)>ext(2)+.8*ext(4))		% Top Side
				set(gcf,'WindowButtonMotionFcn','PrintSetup(''Resize'',''Side'',2)')
		elseif(cp(1,2)<ext(2)+.2*ext(4))		% Bottom Side
				set(gcf,'WindowButtonMotionFcn','PrintSetup(''Resize'',''Side'',4)')
		else									% Center
			set(gca,'UserData',cp);
			set(gcf,'WindowButtonMotionFcn','PrintSetup(''Resize'',''Move'')');
		end
		set(PatchObj,'erasemode','xor');
		set(gcf,'WindowButtonUpFcn','PrintSetup(''Resize'',''Up'')');
	elseif(strcmp(subcommand,'Corner'))
		cp = get(gca,'CurrentPoint');
		ext = get(PatchObj,'UserData');
		if(comnum == 1)
			ext = [cp(1,1:2) ext(1:2)+ext(3:4)-cp(1,1:2)];
		elseif(comnum == 2)
			ext = [cp(1,1) ext(2) ext(1)+ext(3)-cp(1,1) cp(1,2)-ext(2)];
		elseif(comnum == 3)
			ext(3:4) = cp(1,1:2)-ext(1:2);
		else
			ext(2:4) = [cp(1,2) cp(1,1)-ext(1) ext(2)+ext(4)-cp(1,2)];
		end
		XData = ext(1)+[0 ext(3) ext(3) 0];
		YData = ext(2)+[0 0 ext(4) ext(4)];
		set(PatchObj,'XData',XData,'YData',YData);
	elseif(strcmp(subcommand,'Side'))
		cp = get(gca,'CurrentPoint');
		ext = get(PatchObj,'UserData');
		if(comnum == 1)
			ext = [cp(1,1) ext(2) ext(1)+ext(3)-cp(1,1) ext(4)];
		elseif(comnum == 2)
			ext = [ext(1) ext(2) ext(3) cp(1,2)-ext(2)];
		elseif(comnum == 3)
			ext = [ext(1) ext(2) cp(1,1)-ext(1) ext(4)];
		else
			ext = [ext(1) cp(1,2) ext(3) ext(2)+ext(4)-cp(1,2)];
		end
		XData = ext(1)+[0 ext(3) ext(3) 0];
		YData = ext(2)+[0 0 ext(4) ext(4)];
		set(PatchObj,'XData',XData,'YData',YData);
	elseif(strcmp(subcommand,'Move'))
		startpoint = get(gca,'UserData');
		cp = get(gca,'CurrentPoint');
		XData = get(PatchObj,'XData');
		YData = get(PatchObj,'YData');
		XData = XData+cp(1,1)-startpoint(1,1);
		YData = YData+cp(1,2)-startpoint(1,2);
		set(PatchObj,'XData',XData,'YData',YData);
		set(gca,'UserData',cp);
	else
		PaperSize = get(gcf,'PaperSize');
		set(PatchObj,'EraseMode','normal');
		set(gcf,'WindowButtonMotionFcn','',...
				'WindowButtonUpFcn','');
		XData = get(PatchObj,'XData');
		YData = get(PatchObj,'YData');
		ext = [XData(1) YData(1) XData(2)-XData(1) YData(3)-YData(2)];
		set(gcf,'PaperPosition',ext);
		set(findobj(gcf,'Tag','Bottom'),'String',num2str(ext(1)));
		set(findobj(gcf,'Tag','Left'),'String',num2str(ext(2)));
		set(findobj(gcf,'Tag','Top'),'String',num2str(PaperSize(2)-ext(2)-ext(4)));
		set(findobj(gcf,'Tag','Right'),'String',num2str(PaperSize(1)-ext(1)-ext(3)));
		set(PatchObj,'UserData',ext);
	end
elseif(strcmp(command,'Margins'))
	PaperPosition = get(gcf,'PaperPosition');
	PaperSize = get(gcf,'PaperSize');
	Bottom = str2num(get(findobj(gcf,'Tag','Bottom'),'String'));
	Left = str2num(get(findobj(gcf,'Tag','Left'),'String'));
	Top = str2num(get(findobj(gcf,'Tag','Top'),'String'));
	Right = str2num(get(findobj(gcf,'Tag','Right'),'String'));
	set(gcf,'PaperPosition',[Left ...
				 Bottom ...
				 PaperSize(1)-Left-Right ...
				 PaperSize(2)-Bottom-Top]);
	PrintSetup('DrawPage');
elseif(strcmp(command,'Invert'))
	if(get(findobj(gcf,'Tag','Invert'),'Value'))
		set(gcf,'InvertHardCopy','on');
	else
		set(gcf,'InvertHardCopy','off');
	end
elseif(strcmp(command,'PaperUnits'))
	units = get(findobj(gcf,'Tag','PaperUnits'),'Value');
	if(units == 1)
		set(gcf,'PaperUnits','Inches');
	elseif(units == 2)
		set(gcf,'PaperUnits','Centimeters');
	elseif(units == 3)
		set(gcf,'PaperUnits','Normalized');
	elseif(units == 4)
		set(gcf,'PaperUnits','Points');
	end
	PaperSize = get(gcf,'PaperSize');
	PaperPosition = get(gcf,'PaperPosition');
	set(findobj(gcf,'Tag','Left'),'String',...
		num2str(PaperPosition(1)));
	set(findobj(gcf,'Tag','Right'),'String',...
		num2str(PaperSize(1)-PaperPosition(1)-PaperPosition(3)));
	set(findobj(gcf,'Tag','Top'),'String',...
		num2str(PaperSize(2)-PaperPosition(2)-PaperPosition(4)));
	set(findobj(gcf,'Tag','Bottom'),'String',...
		num2str(PaperPosition(2)));
	PrintSetup('DrawPage');
elseif(strcmp(command,'PaperType'))
	UserData = get(gcf,'UserData');
	val = get(findobj(gcf,'Tag','PaperType'),'Value');
	if(val == 1)
		set(gcf,'PaperType','usletter');
		UserData(3) = 3.5;
		set(gcf,'UserData',UserData);
	elseif(val == 2)
		set(gcf,'PaperType','uslegal');
		UserData(3) = 4;
		set(gcf,'UserData',UserData);
	elseif(val == 3)
		set(gcf,'PaperType','a3');
		UserData(3) = 5;
		set(gcf,'UserData',UserData);
	elseif(val == 4)
		set(gcf,'PaperType','a4letter');
		UserData(3) = 3.5;
		set(gcf,'UserData',UserData);
	elseif(val == 5)
		set(gcf,'PaperType','a5');
		UserData(3) = 2.5;
		set(gcf,'UserData',UserData);
	elseif(val == 6)
		set(gcf,'PaperType','b4');
		UserData(3) = 4;
		set(gcf,'UserData',UserData);
	else
		set(gcf,'PaperType','tabloid');
		UserData(3) = 5;
		set(gcf,'UserData',UserData);
	end
	PrintSetup('Margins');
elseif(strcmp(command,'Orient'))
	val = get(findobj(gcf,'Tag','Orient'),'Value');
	if(val == 1)
		orient portrait;
	elseif(val == 2)
		orient landscape;
	else
		orient tall;
	end
	ext = get(gcf,'PaperPosition');
	PaperSize = get(gcf,'PaperSize');
	set(findobj(gcf,'Tag','Bottom'),'String',num2str(ext(1)));
	set(findobj(gcf,'Tag','Left'),'String',num2str(ext(2)));
	set(findobj(gcf,'Tag','Top'),'String',num2str(PaperSize(2)-ext(2)-ext(4)));
	set(findobj(gcf,'Tag','Right'),'String',num2str(PaperSize(1)-ext(1)-ext(3)));
	PrintSetup('DrawPage');
elseif(strcmp(command,'APPLY'))
	UserData = get(gcf,'UserData');
	fig = UserData(1);
	set(fig,'PaperUnits',get(gcf,'PaperUnits'));
	set(fig,'PaperType',get(gcf,'PaperType'));
	set(fig,'PaperOrientation',get(gcf,'PaperOrientation'));
	set(fig,'PaperPosition',get(gcf,'PaperPosition'));
	set(fig,'InvertHardCopy',get(gcf,'InvertHardCopy'));
%	delete(gcf);
elseif(strcmp(command,'Cancel'))
	delete(gcf);		
end
