%GENBEL4 Build a boundary element file (.bel) for QUODDY.
%
%         GENBEL4 is a MATLAB5-compatible mouse-driven  GUI
%         tool to build a .bel file, specifying boundary 
%         condition codes by clicking on node numbers and 
%         boundary types.
%
%         Currrently, GENBE4L can create a new .bel
%         from scratch, given only the .nod and .ele
%         files for a domain, or it can read an existing
%         one and edit the current codes. 
% 
%         GENBEL4 can also output a "node code" list for input
%         into a .nei file.  At this time, corner nodes cannot
%         be determined and must still be specified external to
%         MATLAB.
%
%         There is an "Info" line at the bottom of the
%         figure which prompts the user for the next step.
%         The "HELP" button provides more complete instructions.
%
% CALL as: >> genbel4
%
% GENBEL4 was written by: 
%         Brian O. Blanton
%         Department of Marine Sciences
%         Ocean Processes Numerical Modeling Laboratory
%         15-1A Venable Hall
%         CB# 3300
%         Uni. of North Carolina
%         Chapel Hill, NC
%                  27599-3300
% 
%         919-962-4466
%         blanton@marine.unc.edu
% 
%         Version 3.0 (M5.0.0) Summer 1997
%
function retval=genbel4(command,option)
colordef none

% make sure this is atleast MATLAB version5.0.0
%
vers=version;
if vers(1)<5
   disp('??? Error using ==>> GENBEL4 ');
   disp('This version of GENBEL4 REQUIRES!! MATLAB version 5.0.0 or later.');
   disp('Sorry, but this is terminal.');
   return
end     
if nargin==0
   command='initialize';
   option='no opt';
end
if strcmp(command,'debug')
   command='initialize';
   option='debug';
end
if ~exist('option'),option='no_opt';,end

GBfig=findobj(0,'Type','figure','Tag','GBMainFig');
GBaxes=findobj(0,'Type','axes','Tag','GBMainAx');
GBInfoLine=findobj(GBfig,'Type','uicontrol','Tag','GBInfoLine');

global GB_GRID GB_BND

% If a grid has been defined, extract it.
%
if ~isempty(GBfig)
   if GB_GRID
      griddata=get(GBfig,'UserData');
      nn=griddata(1,6);
      x=griddata(1:nn,1);
      y=griddata(1:nn,2);
      ne=griddata(3,6);
      e=griddata(1:ne,3:5);
   end
   if GB_BND
      nbnd=griddata(2,6);
      bnd=griddata(1:nbnd,7:8);
   end
else
   GB_GRID=0;
   GB_BND=0;
end
   

if strcmp(command,'initialize')           %%%  INITIALIZATION CALLS  
%%%
%%%  INITIALIZATION CALLS 
%%%
   GB_GRID=0;
   GB_BND=0;
   genbel4('SetUpFig');
   if strcmp(option,'debug')
      genbel4('LoadGrid','debug');
   end         
   
elseif strcmp(command,'LoadGrid')         %%%  LOAD A .nod & .ele DOMAIN
%%%
%%%  LOAD A .nod & .ele DOMAIN
%%%
   % Wipe existing grid, if it exists.
   %
   set(GBfig,'UserData',[]);     % Grid data
   set(GBaxes,'UserData',[]);    % Bel list
   cla
   axis('auto')
   
   oldpt=get(GBfig,'Pointer');
   set(GBfig,'Pointer','watch');  

   if ~strcmp(option,'debug') 
      % get node filename from user
      suffix='xxxx';
      while ~strcmp(suffix,'.nod')
         filefilt=[pwd '/*.nod'];
         [filename, pathname] = uigetfile(filefilt, 'Click on .nod filename');
         if filename==0
            set(GBfig,'Pointer',oldpt);
            return
         end 
         gname=filename(1:length(filename)-4);
         suffix=filename(length(filename)-3:length(filename));
      end
      nodename=[pathname filename];
      loadcom=['load ' nodename];
      infostring=[' Loading ' nodename ' ...'];
      set(GBInfoLine,'String',infostring);
      drawnow
      eval(loadcom)
      nodes=eval(filename(1:length(filename)-4));
      x=nodes(:,2);x=x(:);
      y=nodes(:,3);y=y(:);

      % get element filename from user
      suffix='xxxx';
      while ~strcmp(suffix,'.ele')
         filefilt=[pathname '/*.ele'];
         [filename, pathname] = uigetfile(filefilt, 'Click on .ele filename');
         if filename==0
            set(GBfig,'Pointer',oldpt);  
            return
         end
         checkname=filename(1:length(filename)-4); 
         suffix=filename(length(filename)-3:length(filename));
      end
      if ~strcmp(gname,checkname)
         disp('Domain names in .nod & .ele files do not match!');
         res=[];
         while ~strcmp(lower(res),'y') & ~strcmp(lower(res),'n')  
            res=input('Continue [y/N] ? ','s');
         end
         if strcmp(lower(res),'n')
            return
         else
            disp('Unless the .ele & .nod files are really from');
            disp('the same domain, GENBEL is going to bomb.')
            disp('Hit <RETURN> to continue.')
            pause
         end
      end
                    
      elename=[pathname filename];
      loadcom=['load ' elename];
      infostring=[' Loading ' elename ' ...'];
      set(GBInfoLine,'String',infostring);
      drawnow
      eval(loadcom)
      e=eval(filename(1:length(filename)-4));
      e=e(:,2:4);
   else
      if ~isdir('/homes/blanton/matlab/development')
         disp('Debug directory /homes/blanton/matlab/development');
         disp('does not exist.  Debug mode can only run here');
         disp('/homes/blanton/matlab/development');
         delete(GBfig);
         return
      end
      cwd=pwd;
      if ~strcmp(cwd,'/homes/blanton/matlab/development')&...
         ~strcmp(cwd,'/home5/blanton/matlab/development')
         disp('Not in Debug directory /homes/blanton/matlab/development');
         delete(GBfig);
         return
      end

      load lm.nod
      x=lm(:,2);x=x(:);
      y=lm(:,3);y=y(:);
      load lm.ele
      e=lm(:,2:4);
      
      GBLoadBelBut=findobj(GBfig,'Type','uicontrol','Tag','GBLoadBelBut');
      GBHashBndBut=findobj(GBfig,'Type','uicontrol','Tag','GBHashBndBut');
      GBOutputBelBut=findobj(GBfig,'Type','uicontrol','Tag','GBOutputBelBut');
      set([GBLoadBelBut GBHashBndBut GBOutputBelBut],'Enable','on');
   end
   
   % Store grid coordinates in figure UserData
   %
   alloc_len=(max(length(e),length(x)));
   temp=NaN*ones(alloc_len,7);
   temp(1:length(e),3:5)=e;
   temp(1:length(x),1)=x;
   temp(1:length(x),2)=y;
   temp(1,6)=length(x);
   temp(3,6)=length(e);
   set(GBfig,'UserData',temp);
   set(GBfig,'Pointer',oldpt); 
   GB_GRID=1; 
   
   GBLoadBelBut=findobj(GBfig,'Type','uicontrol','Tag','GBLoadBelBut');
   GBHashBndBut=findobj(GBfig,'Type','uicontrol','Tag','GBHashBndBut');
   set([GBLoadBelBut GBHashBndBut],'Enable','on');
   set(GBInfoLine,'String',' "Load Bel" (existing) or "New Bnd" (new bel)')
      
elseif strcmp(command,'LoadBel')          %%% LOAD AN EXISTING .bel FILE
%%%
%%% LOAD AN EXISTING .bel FILE
%%%   
   filefilt=[pwd '/*.bel'];
   [fname,fpath]=uigetfile(filefilt,'Which .bel ?');
   if fname==0,return,end

   % get filetype from tail of fname
   ftype=fname(length(fname)-2:length(fname));

   % make sure this is an allowed filetype
   if ~strcmp(ftype,'bel')
      disp('??? Error using ==>> GENBEL')
      disp(['GENBEL cannot accept ' ftype ' filetype'])
      return
   end

   % Remove bellist from main axes 'UserData'.
   %
   set(GBaxes,'UserData',[]);

   % open fname
   %
   [pfid,message]=fopen([fpath fname]);
   if pfid==-1
      error([fpath fname,' not found. ',message]);
   end

   % In all filetypes there is always a gridname and description line
   % as lines #1 and #2 of the file.
   % read grid name from top of file; header line #1
   %
   gridname=fgets(pfid);
   gridname=blank(gridname);
   % read description line from top of file; header line #2
   descline=fgets(pfid);
   % read data segment 
   bellist=fscanf(pfid,'%d %f %f %f %f',[5 inf])';
   fclose(pfid);
   
   % Need to set nbnd and bnd list in the main griddata array stored in the GBfig UserData
   %
   temp=get(GBfig,'UserData');
   nbnd=length(bellist);
   temp(2,6)=nbnd;
   temp(1:nbnd,7:8)=bellist(:,2:3);
   set(GBfig,'UserData',temp);
   
   set(GBaxes,'UserData',bellist);  
   genbel4('PlotBnd'); 
   GBOutputBelBut=findobj(GBfig,'Type','uicontrol','Tag','GBOutputBelBut');
   set(GBOutputBelBut,'Enable','on');
   
   set(GBInfoLine,'String',' Enter Starting and Ending NN to connect');
   GB_BND=1;
   
elseif strcmp(command,'SetAxis')          %%% AXIS EQUAL
%%%
%%% AXIS EQUAL
%%%
   if GB_GRID==0
      set(GBInfoLine,'String',' Grid not Loaded yet. Use "Load Grid".');
      return
   elseif GB_BND==0
      set(GBInfoLine,'String',' Boundary NOT parsed or .bel NOT loaded.');
      return
   end
   axis('equal')
   xrange=max(x)-min(x);
   yrange=max(y)-min(y);
   RenLim(1:2)=get(GBaxes,'XLim');
   RenLim(3:4)=get(GBaxes,'YLim');
   newxmin=RenLim(1)-xrange/20;
   newxmax=RenLim(2)+xrange/20;
   newymin=RenLim(3)-yrange/20;
   newymax=RenLim(4)+yrange/20;
   axis([newxmin newxmax newymin newymax])
      
elseif strcmp(command,'Def_buttons')      %%% DEFINE MOUSE BUTTON FUNCTIONS
%%%
%%% DEFINE MOUSE BUTTON FUNCTIONS
%%%
   set(GBfig,'WindowButtonDownFcn','genbel4(''Proc_mouse_event'')')
   
elseif strcmp(command,'Proc_mouse_event') %%% PROCESS MOUSE BUTTON EVENTS
%%%
%%% PROCESS MOUSE BUTTON EVENTS
%%%
   seltype=get(GBfig,'SelectionType');
   
   if strcmp(seltype,'open')
      GBStartingNN=findobj(GBfig,'Type','uicontrol','Tag','GBStartingNN');
      GBEndingNN=findobj(GBfig,'Type','uicontrol','Tag','GBEndingNN');
      set(GBStartingNN,'String','<enter>')
      set(GBEndingNN,'String','<enter>')
   end
   
   objtag=get(gco,'Tag');
   if ~strcmp(objtag,'Bnd Node #'),return,end
   nodenum=get(gco,'UserData');
   
   if strcmp(seltype,'normal')      
      GBStartingNN=findobj(GBfig,'Type','uicontrol','Tag','GBStartingNN');
      set(GBStartingNN,'String',nodenum);
      GBEndingNN=findobj(GBfig,'Type','uicontrol','Tag','GBEndingNN');
      set(GBEndingNN,'String','<enter>');   
   elseif strcmp(seltype,'extend')      
      GBEndingNN=findobj(GBfig,'Type','uicontrol','Tag','GBEndingNN');
      set(GBEndingNN,'String',nodenum);
      genbel4('Check2')
   end
            
elseif strcmp(command,'ClearCodes')       %%% CLEAR CURRENT BOUNDARY CODES
%%%
%%% CLEAR CURRENT BOUNDARY CODES
%%%
   if GB_GRID==0
      set(GBInfoLine,'String',' Grid not Loaded yet. Use "Load Grid".');
      return
   elseif GB_BND==0
      set(GBInfoLine,'String',' Boundary NOT parsed or .bel NOT loaded.');
      return
   end
   bellist=get(GBaxes,'UserData');
   bellist(:,5)=zeros(size(bellist(:,5)));
   set(GBaxes,'UserData',bellist);
   genbel4('PlotBnd')
   btb(1)=findobj(GBfig,'Type','uicontrol','Tag','GBLandBut');
   btb(2)=findobj(GBfig,'Type','uicontrol','Tag','GBIslandBut');
   btb(3)=findobj(GBfig,'Type','uicontrol','Tag','GBNon-0NormBut');
   btb(4)=findobj(GBfig,'Type','uicontrol','Tag','GBGeosT.OutBut');
   btb(5)=findobj(GBfig,'Type','uicontrol','Tag','GBElevationBut');
   set(btb,'Value',0)  
   GBOutPutBelFig=findobj(0,'Type','figure','Tag','GBOutPutBelFig');
   delete(GBOutPutBelFig);
   
elseif strcmp(command,'WhichBndType')     %%% DETERMINE BND TYPE SELECTION
%%%
%%% DETERMINE BND TYPE SELECTION
%%%
   btb(1)=findobj(GBfig,'Type','uicontrol','Tag','GBLandBut');
   btb(2)=findobj(GBfig,'Type','uicontrol','Tag','GBIslandBut');
   btb(3)=findobj(GBfig,'Type','uicontrol','Tag','GBNon-0NormBut');
   btb(4)=findobj(GBfig,'Type','uicontrol','Tag','GBGeosT.OutBut');
   btb(5)=findobj(GBfig,'Type','uicontrol','Tag','GBElevationBut');
   val(1)=get(btb(1),'Value');
   val(2)=get(btb(2),'Value');
   val(3)=get(btb(3),'Value');
   val(4)=get(btb(4),'Value');
   val(5)=get(btb(5),'Value');
   bndtype=find(val==1);
   if isempty(bndtype)
      retval=0; 
   else 
      retval=bndtype;  
   end  
   
elseif strcmp(command,'Check1')           %%% CHECK AFTER START_NN INPUT
%%%
%%% CHECK AFTER START_NN INPUT
%%%
   GBStartingNN=findobj(GBfig,'Type','uicontrol','Tag','GBStartingNN');
   if GB_GRID==0
      set(GBInfoLine,'String',' Grid not Loaded yet. Use "Load Grid".');
      set(GBStartingNN,'String','<enter>');      
   elseif GB_BND==0
      set(GBInfoLine,'String',' Boundary NOT parsed or .bel NOT loaded.');
      set(GBStartingNN,'String','<enter>');
   else   
      GBEndingNN=findobj(GBfig,'Type','uicontrol','Tag','GBEndingNN');
      set(GBEndingNN,'String','<enter>');   
      set(GBInfoLine,'String',' Make sure an ending nn and bnd type has been selected')
   end
   
elseif strcmp(command,'Check2')           %%% CHECK AFTER END_NN INPUT
%%%
%%% CHECK AFTER END_NN INPUT
%%%
   GBEndingNN=findobj(GBfig,'Type','uicontrol','Tag','GBEndingNN');
   if GB_GRID==0
      set(GBInfoLine,'String',' Grid not Loaded yet. Use "Load Grid".');
      set(GBEndingNN,'String','<enter>');
      return
   elseif GB_BND==0
      set(GBInfoLine,'String',' Boundary NOT parsed or .bel NOT loaded.');
      set(GBEndingNN,'String','<enter>');
      return
   end

   % Make sure starting and ending nodes have been defined
   %
   GBStartingNN=findobj(GBfig,'Type','uicontrol','Tag','GBStartingNN');
   GBEndingNN=findobj(GBfig,'Type','uicontrol','Tag','GBEndingNN');
   startingnn=get(GBStartingNN,'String');
   endingnn=get(GBEndingNN,'String');
   if strcmp(startingnn,'<enter>')
      set(GBInfoLine,'String',' Starting node number NOT entered.')
      return
   end
   if strcmp(endingnn,'<enter>')
      set(GBInfoLine,'String',' Ending node number NOT entered.')
      return
   end
   strnn=eval(startingnn);
   endnn=eval(endingnn);
   line([x(strnn) x(endnn)],[y(strnn) y(endnn)],'Marker','*',...
             'MarkerSize',25,'color','m','Tag','GBNodeMark');
   
   % Make sure a boundary type has been selected.
   %
   bndtype=genbel4('WhichBndType');
   if bndtype==0
      set(GBInfoLine,'String',' Boundary Type NOT selected.')
      return
   end  
   
   GBConnectBut=findobj(GBfig,'Type','uicontrol','Tag','GBConnectBut');
   set(GBConnectBut,'BackGroundColor','g','Enable','on');
   
   set(GBInfoLine,'String',' Ready to "Connect".')
  
elseif strcmp(command,'Pan')              %%% PAN FUNCTION
%%%
%%% PAN FUNCTION
%%%
   GBPanBut=findobj(GBfig,'type','uicontrol','Tag','GBPanBut');
   GBZoomBut=findobj(GBfig,'type','uicontrol','Tag','GBZoomBut');
   if GB_GRID==0
      set(GBInfoLine,'String',' Grid not Loaded yet. Use "Load Grid".');
      set(GBPanBut,'String','PAN OFF','Value',0);    
      set(GBZoomBut,'String','ZOOM OFF','Value',0);
   elseif GB_BND==0
      set(GBInfoLine,'String',' Boundary NOT parsed or .bel NOT loaded.');
      set(GBPanBut,'String','PAN OFF','Value',0);    
      set(GBZoomBut,'String','ZOOM OFF','Value',0);
   end

   % First check the state of ZOOM; turn off if "ON"
   %
   state=get(GBZoomBut,'String');
   if strcmp(state,'ZOOM ON')
      zoom off
      set(GBZoomBut,'String','ZOOM OFF','Value',0);
   end
   set(GBPanBut,'String','PAN ON');
   pan
   set(GBPanBut,'String','PAN OFF','Value',0);    
   genbel4('Def_buttons');
   
elseif strcmp(command,'Zoom')             %%% ZOOM IN/OUT FUNCTION
%%%
%%% ZOOM IN/OUT FUNCTION
%%%
   GBZoomBut=findobj(GBfig,'type','uicontrol','Tag','GBZoomBut');
   if GB_GRID==0
      set(GBInfoLine,'String',' Grid not Loaded yet. Use "Load Grid".');
      set(GBZoomBut,'String','ZOOM OFF');
      genbel4('Def_buttons');
      return
   elseif GB_BND==0
      set(GBInfoLine,'String',' Boundary NOT parsed or .bel NOT loaded.');
      set(GBZoomBut,'String','ZOOM OFF');
      genbel4('Def_buttons');
      return
   end
   
   state=get(GBZoomBut,'String');
   if strcmp(state,'ZOOM OFF')
      zoom on
      set(GBZoomBut,'String','ZOOM ON');
   else
      zoom off
      set(GBZoomBut,'String','ZOOM OFF');
      genbel4('Def_buttons');
   end  
       
elseif strcmp(command,'Numbnd')           %%% NUMBER BOUNDARY NODES
%%%
%%% NUMBER BOUNDARY NODES
%%%
   if GB_GRID==0
      set(GBInfoLine,'String',' Grid not Loaded yet. Use "Load Grid".');
      return
   elseif GB_BND==0
      set(GBInfoLine,'String',' Boundary NOT parsed or .bel NOT loaded.');
      return
   end
   
   % Delete previous node number text objs
   %
   texts=findobj(GBaxes,'Type','text','Tag','Bnd Node #');
   
   X=get(GBaxes,'XLim');
   Y=get(GBaxes,'YLim');

   ns=bnd(:,1);
   ne=bnd(:,2);
   x=x(ns);
   y=y(ns);
   nlist=bnd(:,1);

   % get indices of nodes within viewing window defined by X,Y
   filt=find(x>=X(1)&x<=X(2)&y>=Y(1)&y<=Y(2));

   % label only those nodes that lie within viewing window.
%   line(x(filt),y(filt),'Marker','o','Color','w','Tag','Bnd Node #')
   for i=1:length(filt)
      h(i)=text(x(filt(i)),y(filt(i)),1,int2str(nlist(filt(i))),...
           'FontSize',10,...
           'HorizontalAlignment','center',...
           'VerticalAlignment','middle',...
           'Color','w',...
           'UserData',int2str(nlist(filt(i))),...
           'Tag','Bnd Node #');
   end

elseif strcmp(command,'ClearNums')        %%% CLEAR BOUNDARY NUMBER TEXT AND MARKERS
%%%
%%% CLEAR BOUNDARY NUMBER TEXT AND MARKERS
%%%
   if GB_GRID==0
      set(GBInfoLine,'String',' Grid not Loaded yet. Use "Load Grid".');
      return
   elseif GB_BND==0
      set(GBInfoLine,'String',' Boundary NOT parsed or .bel NOT loaded.');
      return
   end
   delete(findobj(GBaxes,'Type','text','Tag','Bnd Node #'));
   delete(findobj(GBaxes,'Type','line','Tag','Bnd Node #'));
   delete(findobj(GBaxes,'Type','line','Tag','GBNodeMark'));
   
elseif strcmp(command,'KillGenbel')       %%% SHUTDOWN GENBEL
%%%
%%% SHUTDOWN GENBEL
%%%
   clear global AR 
   delete(GBfig);
   GBOutPutBelFig=findobj(0,'Type','figure','Tag','GBOutPutBelFig');
   delete(GBOutPutBelFig);
   GB_GRID=0;
   GB_BND=0;
   
elseif strcmp(command,'OutPutBel')        %%% OUTPUT CURRENT .bel FILE 
%%%
%%% OUTPUT CURRENT .bel FILE
%%%
   bellist=get(GBaxes,'UserData');
   codes=bellist(:,5);

   if strcmp(option,'SetUp')   
   
      GBOutPutBelFig = figure('Position',[150 350 500 120],...
                      'NumberTitle','off',...
		      'Name','Output Current .bel List',...
		      'HandleVisibility','on',...
		      'Tag','GBOutPutBelFig');

      GBOutPutBelAxes=axes('Units','normalized',...
                           'Position',[0 0 1 1],...
                           'Visible','off');


      no_codes=find(codes==0);
      if ~isempty(no_codes)
	 axes(GBOutPutBelAxes);
	 text('Position',[.05 .8],'HorizontalAlignment','Left',...
              'String','There are boundary segments with no codes assigned.');
	 text('Position',[.05 .55],'HorizontalAlignment','Left',...
              'String','Do you want GENBEL to assume island codes ?');
	 res=[];
	 BUTTONS(1)=uicontrol(GBOutPutBelFig,'Style','push',...
                                	     'Units','normalized',...
                                	     'Position',[.1 .1 .2 .2],...
                                	     'String','YES',...
                                	     'Tag','GBYesBut');
	 BUTTONS(2)=uicontrol(GBOutPutBelFig,'Style','push',...
                                	     'Units','normalized',...
                                	     'Position',[.4 .1 .2 .2],...
                                	     'String','NO',...
                                	     'Tag','GBNoBut');
	 for i=1:2
	    set(BUTTONS(i),'UserData',BUTTONS(:,[1:(i-1),(i+1):2]))
	 end
	 CALLBACK=['me=get(gcf,''CurrentObject'');',...
        	   'if(get(me,''Value'')==1),',...
        	       'set(get(me,''UserData''),''Value'',0),',...
        	    'else,',...
        	       'set(me,''Value'',1),',...
        	    'end'];
	 set(BUTTONS,'CallBack',CALLBACK);

         BUTTONS(3)=uicontrol(GBOutPutBelFig,'Style','push',...
                                	     'Units','normalized',...
                                	     'Position',[.7 .1 .2 .2],...
                                	     'String','CANCEL',...
                                	     'Tag','GBOutPutCancel');         
	 drawnow
         go=0;
	 while ~go
            waitforbuttonpress;  
            drawnow
            if (get(gcf,'CurrentObject')==BUTTONS(1)),res='y';go=1;,end
            if (get(gcf,'CurrentObject')==BUTTONS(2)),res='n';go=1;,end
            if (get(gcf,'CurrentObject')==BUTTONS(3)),res='c';go=1;,end
            if strcmp(res,'c')
               delete(get(get(gcf,'CurrentObject'),'Parent')) 
               return
            end
	 end
	 if strcmp(lower(res),'n')
            axes(GBOutPutBelAxes);deltext
            text('Position',[.05 .8],'HorizontalAlignment','Left',...
        	 'String','Do you STILL want to save [Y/n] ? ');
            res=[];
            go=0;
	    while ~go
               waitforbuttonpress;  
               drawnow
               if (get(gcf,'CurrentObject')==BUTTONS(1)),res='y';go=1;,end
               if (get(gcf,'CurrentObject')==BUTTONS(2)),res='n';go=1;,end
               if (get(gcf,'CurrentObject')==BUTTONS(3)),res='c';go=1;,end
               if strcmp(res,'c')
        	  delete(get(get(gcf,'CurrentObject'),'Parent')) 
        	  return
               end
	    end
            if strcmp(res,'n')
               axes(GBOutPutBelAxes);deltext
               text('Position',[.05 .80],'HorizontalAlignment','Left',...
        	    'String','NO SAVE!!');
               text('Position',[.05 .55],'HorizontalAlignment','Left',...
        	    'String','The boundary segments needing attention are in white.');
               delete(BUTTONS);
               CANCEL=uicontrol(GBOutPutBelFig,'Style','push',...
                                	       'Units','normalized',...
                                	       'Position',[.4 .1 .2 .2],...
                                	       'String','CANCEL',...
                                	       'Tag','GBOutPutCancel');
               CALLBACK=['me=get(gcf,''CurrentObject'');',...
                	 'if(strcmp(get(me,''Tag''),''GBOutPutCancel'')),',...
                	 'delete(get(me,''Parent''));,end'];
               set(CANCEL,'CallBack',CALLBACK);
               return;
            end
	 else
            bellist(no_codes,5)=2*ones(size(no_codes));
            genbel4('PlotBnd')
	 end 
      end
      set(GBaxes,'UserData',bellist);  

      figure(GBOutPutBelFig);clf

      uicontrol('Parent',GBOutPutBelFig,...
 		'BackgroundColor',[0;0;0],...
		'ForegroundColor',[1;1;1],...
		'Style','text',...
		'String','Enter Domain Name : ',...
		'Units','normalized',...
		'Position',[.025 .7 .3 .15],...
		'HorizontalAlignment','left');
      gnameUI=uicontrol('Parent',GBOutPutBelFig,...
			'ForegroundColor',[1;0;0],...
			'Style','edit',...
			'String','<gridname>',...
			'Units','normalized',...
			'Position',[.35 .7 .25 .15],...
			'Tag','GBOPgnameUI');
      uicontrol('Parent',GBOutPutBelFig,...
 		'BackgroundColor',[0;0;0],...
		'ForegroundColor',[1;1;1],...
		'Style','text',...
		'String','Enter Comment Line : ',...
		'Units','normalized',...
		'Position',[.025 .4 .3 .15],...
		'HorizontalAlignment','left');
      commentUI=uicontrol('Parent',GBOutPutBelFig,...
			'ForegroundColor',[1;0;0],...
			'Style','edit',...
			'String','<Comment Line>',...
			'Units','normalized',...
			'Position',[.35 .4 .55 .15],...
			'Tag','GBOPcommentUI');
      uicontrol('Parent',GBOutPutBelFig,...
 		'BackgroundColor',[0;0;0],...
		'ForegroundColor',[1;1;1],...
		'Style','text',...
		'String','Enter .bel Filename : ',...
		'Units','normalized',...
		'Position',[.025 .1 .3 .15],...
		'HorizontalAlignment','left');
      fnameUI=uicontrol('Parent',GBOutPutBelFig,...
			'ForegroundColor',[1;0;0],...
			'Style','edit',...
			'String','temp.bel',...
			'Units','normalized',...
			'Position',[.35 .1 .3 .15],...
			'CallBack','genbel4(''OutPutBel'',''write'')',...
			'Tag','GBOPfnameUI');
      uicontrol('Parent',GBOutPutBelFig,...
		'ForegroundColor',[0 1 0],...
		'Style','push',...
		'String','SUBMIT',...
		'Units','normalized',...
		'Position',[.77 .1 .19 .15],...
		'CallBack','genbel4(''OutPutBel'',''writebcs'')');
      temp=uicontrol('Parent',GBOutPutBelFig,...
		     'ForegroundColor',[1 0 0],...
		     'Style','push',...
		     'String','CANCEL',...
		     'Units','normalized',...
		     'Position',[.77 .7 .19 .15],...
		     'Tag','GBOutPutCancel');
      CALLBACK=['me=get(gcf,''CurrentObject'');',...
                'if(strcmp(get(me,''Tag''),''GBOutPutCancel'')),',...
                'delete(get(me,''Parent''));,end'];
      set(temp,'CallBack',CALLBACK);
           uicontrol('Parent',GBOutPutBelFig,...
		     'ForegroundColor',[1 1 0],...
		     'Style','push',...
		     'String','Quoddy',...
		     'Units','normalized',...
		     'Position',[.61 .7 .15 .15],...
		     'Tag','GBOutPutModType',...
		     'Callback','genbel4(''OutPutBel'',''modtype'')',...
		     'UserData','Quoddy');
		     
   elseif strcmp(option,'writebcs')   

      GBOutPutBelFig=findobj(0,'Type','figure','Tag','GBOutPutBelFig');

      % Determine model output type
      
      GBOutPutModType=findobj(GBOutPutBelFig,'Type','uicontrol','Tag','GBOutPutModType');
      modtype=get(GBOutPutModType,'UserData');

      GBOPgnameUI=findobj(GBOutPutBelFig,'Type','uicontrol','Tag','GBOPgnameUI');
      gname=get(GBOPgnameUI,'String');
      GBOPcommentUI=findobj(GBOutPutBelFig,'Type','uicontrol','Tag','GBOPcommentUI');
      comment=get(GBOPcommentUI,'String');
      GBOPfnameUI=findobj(GBOutPutBelFig,'Type','uicontrol','Tag','GBOPfnameUI');
      fname=get(GBOPfnameUI,'String');
      
      fid=fopen(fname,'w');
      
      % Output segment for Fundy model
      if strcmp(modtype,'Fundy')
         bcs=zeros(size(x));
         bcs(bellist(:,2))=bellist(:,5);
	 for i=1:length(x)
	    fprintf(fid,'%1d\n',bcs(i));
	 end
      else
         set(GBInfoLine,'String',' Sorting final .bel list by code...')
	 % Order boundary list, exterior, then islands
	 % Find western-most node number with non-island code

	 newbellist=NaN*ones(size(bellist));
	 tempbellist=bellist;                        % temp list to delete from
	 iland=find(bellist(:,5)~=2);                % get all non-island nodes
         ns=bnd(:,1);
         ne=bnd(:,2);
	 ie=[ns(:);ne(:)];
         x=x(ie);
 	 [minx,iminx]=min(x);
         iminx=iminx(1);    %  just in case there's more than one.
	 count=1;
	 newbellist(count,:)=tempbellist(iminx,:);
	 tempbellist(iminx,:)=[];
	 for i=1:length(iland)-1
	   idx=find(tempbellist(:,2)==newbellist(count,3));  % Gather up the 1 exterior bndy
	   count=count+1;                                   
	   newbellist(count,:)=tempbellist(idx,:);
	   tempbellist(idx,:)=[];
	 end
	 
	 if count<length(bellist)  %  No islands to find.
            % The remaining lines in tempbellist are island codes
	    itest=find(tempbellist(:,5)~=2);
	    if ~isempty(itest)
	       error('nonland code found in land bel section; fatal')
	    end
	    idx=1;
	    istart=tempbellist(idx,3);              % Beginning of first island
	    % insert first island code into new bel list, and delete it from tempbellist.
	    count=count+1;
	    newbellist(count,:)=tempbellist(idx,:);
	    tempbellist(idx,:)=[];
	    while length(tempbellist)          % AS long as there are still nodes 
	       itemp=find(tempbellist(:,2)==istart);   % tempbellist
	       if ~isempty(itemp)
		  count=count+1;
	          newbellist(count,:)=tempbellist(itemp,:);
		  tempbellist(itemp,:)=[];
		  istart=newbellist(count,3);
	       else
	          if count ==length(bellist)   %  We've accounted for all the bel nodes
		     break
		  end
		  istart=tempbellist(1,3);     %  Else, set the new first island node.
	       end
	    end  
	 end
	 
	 bellist=newbellist;
         fprintf(fid,'%s\n',gname);
         fprintf(fid,'%s\n',comment);
	 for i=1:length(bellist(:,1))
	    fprintf(fid,'%d %d %d  %1d  %1d\n',...
        	    bellist(i,1),bellist(i,2),...
        	    bellist(i,3),bellist(i,4),...
        	    bellist(i,5));
	 end
      end
      fclose(fid);
      set(GBInfoLine,'String',' Done!!')

      delete(GBOutPutBelFig);
   elseif strcmp(option,'modtype')
      GBOutPutBelFig=findobj(0,'Type','figure','Tag','GBOutPutBelFig');
      GBOutPutModType=findobj(GBOutPutBelFig,'Type','uicontrol','Tag','GBOutPutModType');
      modtype=get(GBOutPutModType,'UserData');
      if strcmp(modtype,'Quoddy')
         set(GBOutPutModType,'String','Fundy')
         set(GBOutPutModType,'UserData','Fundy')
      else
         set(GBOutPutModType,'String','Quoddy')
         set(GBOutPutModType,'UserData','Quoddy')
      end
   end

elseif strcmp(command,'Connect')          %%% CONNECT CURRENT BND END-POINTS
%%% 
%%% CONNECT CURRENT BND END-POINTS
%%%
   
   % Make sure starting and ending nodes have been defined
   %
   GBStartingNN=findobj(GBfig,'Type','uicontrol','Tag','GBStartingNN');
   GBEndingNN=findobj(GBfig,'Type','uicontrol','Tag','GBEndingNN');
   startingnn=get(GBStartingNN,'String');
   endingnn=get(GBEndingNN,'String');
   if strcmp(startingnn,'<enter>')|strcmp(endingnn,'<enter>'),return,end
   strnn=eval(startingnn);
   endnn=eval(endingnn);
   
   % Make sure chosen numbers are in the boundary list;  
   %
   if ~(find(bnd(:,1)==strnn))
      disp('Starting number not found in BND list')
   end
   if ~(find(bnd(:,1)==endnn))
      disp('Ending number not found in BND list')
   end
   
   code_string=str2mat('land',...
                       'nonzero_norm_vel',...
                       'geostrophic_outflow',...
                       'elevation');      
   code_color=['w','r','b','y','c','g'];
   
   % Determine boundary type selected
   %
   bndtype=genbel4('WhichBndType');
   if bndtype==0
      disp(' ');
      disp('No boundary type selected.')
      disp(' ');
      return
   end 
   
   % Get bellist from main axes 'UserData'; replace when done.
   %
   bellist=get(GBaxes,'UserData');
                              
   % Connect the Dots (Starting NN to Ending NN CCW!!)
   % Since the boundary is connected in CCW order, the list of boundary
   % segments must be oriented with the interior of the domain to the
   % left-hand side of the segment.  This is what 'HashBnd' does.
   %
   connected=0;
   nextnn=strnn;
   oldpt=get(GBfig,'Pointer');
   set(GBfig,'Pointer','watch');
   set(GBInfoLine,'String',' Connecting Start to End NN, CCW ...');
   drawnow
   plt_list=[];
   code_lst=[];
   while ~connected
      connr=bnd(find(bnd(:,1)==nextnn),2);
      plt_list=[plt_list 
               x(nextnn) x(connr) y(nextnn) y(connr)];
      % Insert new code into bellist
      idx=find(bnd(:,1)==nextnn);
      code_lst=[code_lst
                idx];
      if connr==endnn
         connected=1;         
      end
      nextnn=connr;
   end
   
   % Plot boundary segment in its corresponding color and
   % edit bellist accordingly.
   %
   line([plt_list(:,1) plt_list(:,2)],[plt_list(:,3) plt_list(:,4)],...
        'LineStyle','-',...
        'Color',code_color(bndtype+1));
   bellist(code_lst,5)=bndtype*ones(size(code_lst));
   set(GBfig,'Pointer',oldpt)
   
   % Replace bellist  
   %
   set(GBaxes,'UserData',bellist);
   
   % Reset connecting mode
   %
   genbel4('ClearNums'); 
   GBConnectBut=findobj(GBfig,'Type','uicontrol','Tag','GBConnectBut');
   set(GBConnectBut,'BackGroundColor','r','Enable','off');
   
   % Set Boundary Type buttons to 0
   %
   btb(1)=findobj(GBfig,'Type','uicontrol','Tag','GBLandBut');
   btb(2)=findobj(GBfig,'Type','uicontrol','Tag','GBIslandBut');
   btb(3)=findobj(GBfig,'Type','uicontrol','Tag','GBNon-0NormBut');
   btb(4)=findobj(GBfig,'Type','uicontrol','Tag','GBGeosT.OutBut');
   btb(5)=findobj(GBfig,'Type','uicontrol','Tag','GBElevationBut');
   set(btb,'Value',0)
   
   set(GBInfoLine,'String',' Enter Starting and Ending NN to connect')
   
elseif strcmp(command,'PlotBnd')          %%% PLOT BND IN COLORS ACC. BND TYPE
%%%
%%% PLOT BND IN COLORS ACCORDING TO BND TYPE
%%%
   griddata=get(GBfig,'UserData');
   nbnd=griddata(2,6);
   bnd=griddata(1:nbnd,7:8);
   
   bellist=get(GBaxes,'UserData');
   codes=bellist(:,5);
   
   % no code assigned
   type0=find(codes==0);
   % land
   type1=find(codes==1);
   %islands
   type2=find(codes==2);
   % non0norm
   type3=find(codes==3);
   % geostout
   type4=find(codes==4);
   % elevation
   type5=find(codes==5);

   code_color=['w','r','b','y','c','g'];
   
   % Delete Previous Boundary line objects
   %
   delete(findobj(GBaxes,'Type','line','Tag','boundary'));
   
   % loop over boundary types and plot by color
   for i=0:5
      subseq=eval(['type' int2str(i)]);
      if ~isempty(subseq)
         ns=bnd(subseq,1);
         ne=bnd(subseq,2);
         X=[x(ns) x(ne) NaN*ones(size(ns))]';
         Y=[y(ns) y(ne) NaN*ones(size(ns))]';
         X=X(:);
         Y=Y(:);
         
	 hboun=line(X,Y,...
        	    'Color',code_color(i+1),...
        	    'Linestyle','-',...
        	    'LineWidth',0.5,...
        	    'MarkerSize',6,...
        	    'Tag','boundary');
   
      end
   end
elseif strcmp(command,'SetUpFig')         %%% SET UP GENBEL FIGURE AND GUI
%%%
%%% SET UP GENBEL FIGURE AND GUI
%%%

   % Clobber existing GENBEL figure
   %
   if ~isempty(GBfig),close(GBfig),end  

   % Set up operations GUI Menus
   %
   GBfig=figure('Tag','GBMainFig',...
                'Resize','off',...
                'Position',[600 350 625 650],...
                'NumberTitle','off',...
                'Name','GENerate Boundary ELement file');
                
   % Create main Axes
   %
   GBaxes=axes('Tag','GBMainAx','Position',[.075 .10 .875 .55]);

   % Create small frame for info lines at bottom of figure
   %
   frmuinfo=uicontrol(GBfig,'Style','frame',...
                            'Units','normalized',...
                            'Position',[0.0 0.0 1. .05]);
   GBinfo=uicontrol(GBfig,'Style','text',...
                          'Units','normalized',...
                	  'Position',[.01 .005 .1 .04],...
                	  'String','GB Info:',...
                	  'Tag','GBInfoText',...
                	  'BackGroundColor','w');
   GBInfoLine=uicontrol(GBfig,'Style','text',...
                	      'Units','normalized',...
                	      'Position',[.12 .005 .84 .04],...
                	      'String',' Load a Grid with "Load Grid"',...
                	      'Tag','GBInfoLine',...
                	      'HorizontalAlignment','Left',...
                	      'BackGroundColor','w');
   GBHelpBut=uicontrol(GBfig,'Style','push',...
                	     'Units','normalized',...
                	     'Position',[.90 .005 .1 .04],...
                	     'String','HELP',...
                	     'Tag','GBHelpBut',...
                	     'HorizontalAlignment','center',...
                	     'Enable','on',...
                	     'CallBack','genbel4(''Help'')');

   % Create big frame for buttons
   %
   frmuimain=uicontrol(GBfig,'Style','frame',...
                             'Units','normalized',...
                             'Position',[0.0 0.7 1. .3]);

   % Create 'Boundary Type' label and Radio buttons
   %
   txtui(1)=uicontrol(GBfig,'Style','text',...
                            'Units','normalized',...
                            'Position',[.04 .95 .18 .04],...
                            'String','Click on');
   txtui(1)=uicontrol(GBfig,'Style','text',...
                            'Units','normalized',...
                            'Position',[.04 .91 .18 .04],...
                            'String','Boundary Type');
   btbpos=[.01 .87 .24 .04
           .01 .83 .24 .04
           .01 .79 .24 .04
           .01 .75 .24 .04
           .01 .71 .24 .04];

   code_color=['w','r','b','y','c','g'];
   
   btb(1)=uicontrol(GBfig,'Style','Radio',...
                          'Units','normalized',...                                      
                          'Position',btbpos(1,:),...
                          'String','Land (1)',...
                          'Value',0,...
                          'Tag','GBLandBut',...
                          'BackGroundColor','r',...
                          'HorizontalAlignment','left');
   btb(2)=uicontrol(GBfig,'Style','Radio',...
                          'Units','normalized',...                    
                          'Position',btbpos(2,:),...
                          'String','Island (2)',...
                          'Value',0,...
                          'Tag','GBIslandBut',...
                          'BackGroundColor','b',...
                          'ForeGroundColor','w',...
                          'HorizontalAlignment','left');
   btb(3)=uicontrol(GBfig,'Style','Radio',...
                          'Units','normalized',...                    
                          'Position',btbpos(3,:),...
                          'String','Non-0 Norm (3)',...
                          'Value',0,...
                          'Tag','GBNon-0NormBut',...
                          'BackGroundColor','y',...
                          'HorizontalAlignment','left');
   btb(4)=uicontrol(GBfig,'Style','Radio',...
                          'Units','normalized',...                                
                          'Position',btbpos(4,:),...
                          'String','GeosT. Out (4)',...
                          'Value',0,...
                          'Tag','GBGeosT.OutBut',...
                          'BackGroundColor','c',...
                          'HorizontalAlignment','left');
   btb(5)=uicontrol(GBfig,'Style','Radio',...
                          'Units','normalized',...  
                          'Position',btbpos(5,:),...
                          'String','Elevation (5)',...
                          'Value',0,...
                          'Tag','GBElevationBut',...
                          'BackGroundColor','g',...
                          'HorizontalAlignment','left');

   for i=1:5
      set(btb(i),'UserData',btb(:,[1:(i-1),(i+1):5]))
   end
   CALL1=['me=get(gcf,''CurrentObject'');',...
          'if(get(me,''Value'')==1),',...
              'set(get(me,''UserData''),''Value'',0),',...
              'genbel4(''Check2''),',...
           'else,',...
              'set(me,''Value'',1),',...
           'end'];
   set(btb,'CallBack',CALL1);

   % UI for Starting node number
   %
   txtui(2)=uicontrol(GBfig,'Style','text',...
                            'Units','normalized',...
                            'Position',[.25 .95 .15 .04],...
                            'String','Starting N#');
   stnnui=uicontrol(GBfig,'Style','edit',...
                          'Units','normalized',...  
                          'Position',[.40 .95 .1 .04],...
                          'String','<enter>',...
                          'Tag','GBStartingNN',...
                          'CallBack','genbel4(''Check1'')');
   % UI for ending node number
   %
   txtui(3)=uicontrol(GBfig,'Style','text',...
                            'Units','normalized',...
                            'Position',[.25 .90 .15 .04],...
                            'String','Ending N#');
   endnnui=uicontrol(GBfig,'Style','edit',...
                           'Units','normalized',...  
                           'Position',[.40 .90 .1 .04],...
                           'String','<enter>',...
                           'Tag','GBEndingNN',...
                           'CallBack','genbel4(''Check2'')');
   switchui=uicontrol(GBfig,'Style','push',...
                            'Units','normalized',...  
                            'Position',[.40 .850 .1 .04],...
                            'String','SWITCH',...
                            'Tag','GBSWITCHNN',...
                            'CallBack','genbel4(''Switch'')');

   % Place buttons on UI FRAME
   %
   ConnectBut=uicontrol(GBfig,'Style','Push',...
                              'Units','normalized',...  
                              'Position',[.6 .94 .15 .04],...
                              'String','Connect',...
                              'Callback','genbel4(''Connect'')',...
                              'BackGroundColor','r',...
                              'Tag','GBConnectBut','Enable','off');
                              
   MarkBndBut=uicontrol(GBfig,'Style','Push',...
                             'Units','normalized',...  
                             'Position',[.6 .83 .15 .04],...
                             'String','Mark Bnd',...
                             'Callback','genbel4(''Markbnd'')',...
                             'Tag','GBMarkBndBut');
   NumBndBut=uicontrol(GBfig,'Style','Push',...
                             'Units','normalized',...  
                             'Position',[.6 .79 .15 .04],...
                             'String','Number Bnd',...
                             'Callback','genbel4(''Numbnd'')',...
                             'Tag','GBNumBndBut');
   ClrNumBut=uicontrol(GBfig,'Style','Push',...
                             'Units','normalized',...  
                             'Position',[.6 .75 .15 .04],...
                             'String','Clr Marks',...
                             'Callback','genbel4(''ClearNums'')',...
                             'Tag','GBClrNumBut');
   ClrCodesBut=uicontrol(GBfig,'Style','Push',...
                               'Units','normalized',...  
                               'Position',[.6 .71 .15 .04],...
                               'String','Clr Codes',...
                               'Callback','genbel4(''ClearCodes'')',...
                               'Tag','GBClrCodesBut');
                               
   LoadGridBut=uicontrol(GBfig,'Style','Push',...
                               'Units','normalized',...  
                               'Position',[.835 .94 .15 .04],...
                               'String','Load Grid',...
                               'Callback','genbel4(''LoadGrid'',''no_opt'')',...
                               'Tag','GBLoadGridBut');
   LoadBelBut=uicontrol(GBfig,'Style','Push',...
                              'Units','normalized',...  
                              'Position',[.835 .90 .15 .04],...
                              'String','Load Bel',...
                              'Callback','genbel4(''LoadBel'')',...
                              'Enable','off','Tag','GBLoadBelBut');
   HashBndBut=uicontrol(GBfig,'Style','Push',...
                               'Units','normalized',...  
                               'Position',[.835 .86 .15 .04],...
                               'String','New Bel',...
                               'Callback','genbel4(''HashBnd'')',...
                               'Enable','off','Tag','GBHashBndBut');
   OutputBut=uicontrol(GBfig,'Style','Push',...
                             'Units','normalized',...  
                             'Position',[.835 .82 .15 .04],...
                             'String','Output Bel',...
                             'Callback','genbel4(''OutPutBel'',''SetUp'')',...
                             'Enable','off','Tag','GBOutputBelBut');
   ClearAllBut=uicontrol(GBfig,'Style','Push',...
                               'Units','normalized',...  
                               'Position',[.835 .75 .15 .04],...
                               'String','Clear All',...
                               'Callback','genbel4(''ClearAll'')',...
                               'Enable','on','Tag','GBClearAll');
   KillBut=uicontrol(GBfig,'Style','Push',...
                           'Units','normalized',...  
                           'Position',[.835 .71 .15 .04],...
                           'String','Kill (No Save)',...
                           'Callback','genbel4(''KillGenbel'')',...
                           'Enable','on','Tag','GBKillBut');

   AxisEq=uicontrol(GBfig,'Style','Push',...
                          'Units','normalized',...  
                          'Position',[.35 .79 .175 .04],...
                          'String','Axis Equal',...
                          'Callback','genbel4(''SetAxis'')',...
                          'Tag','GBAxisEq');
   ZoomBut=uicontrol(GBfig,'Style','radio',...
                           'Units','normalized',...  
                           'Position',[.35 .75 .175 .04],...
                           'String','ZOOM OFF',...
                           'Callback','genbel4(''Zoom'')',...
                           'Tag','GBZoomBut');
   PanBut=uicontrol(GBfig,'Style','radio',...
                          'Units','normalized',...  
                          'Position',[.35 .71 .175 .04],...
                          'String','PAN OFF',...
                          'Callback','genbel4(''Pan'')',...
                          'Tag','GBPanBut');
   % Define Button-down events
   %
   genbel4('Def_buttons');
   
elseif strcmp(command,'Switch')          %%% SWITCH STARTING AND ENDING NUMBERS
%%%
%%% SWITCH STARTING AND ENDING NUMBERS
%%%
   % Retrieve starting and ending nodes and switch
   %
   GBStartingNN=findobj(GBfig,'Type','uicontrol','Tag','GBStartingNN');
   GBEndingNN=findobj(GBfig,'Type','uicontrol','Tag','GBEndingNN');
   startingnn=get(GBStartingNN,'String');
   endingnn=get(GBEndingNN,'String');
   if strcmp(startingnn,'<enter>')|strcmp(endingnn,'<enter>'),return,end
   set(GBStartingNN,'String',endingnn);
   set(GBEndingNN,'String',startingnn);
   
elseif strcmp(command,'Markbnd')          %%% MARK BND WITH INVIS TEXT and .'s
%%%
%%% MARK BND WITH INVISIBLE TEXT and VISIBLE LARGE .'s
%%%
   if GB_GRID==0
      set(GBInfoLine,'String',' Grid not Loaded yet. Use "Load Grid".');
      return
   elseif GB_BND==0
      set(GBInfoLine,'String',' Boundary NOT parsed or .bel NOT loaded.');
      return
   end

   bellist=get(GBaxes,'UserData');
   codes=bellist(:,5);
   
   % Delete previous node numbering text objs
   %
   delete(findobj(GBaxes,'Tag','Bnd Node #'));
   
   X=get(GBaxes,'XLim');
   Y=get(GBaxes,'YLim');

   ns=bnd(:,1);
   ne=bnd(:,2);
   x=x(ns);
   y=y(ns);
   nlist=bnd(:,1);

   % get indices of nodes within viewing window defined by X,Y
   filt=find(x>=X(1)&x<=X(2)&y>=Y(1)&y<=Y(2));
   
   code_color=['w','r','b','y','c','g'];

   % label only those nodes that lie within viewing window.
   for i=1:length(filt)
      line(x(filt(i)),y(filt(i)),.5,...
           'Marker','.',...
           'Color',code_color(codes(filt(i))+1),...
           'MarkerSize',25,...
           'Tag','Bnd Node #',...
           'UserData',int2str(nlist(filt(i))));
   end

elseif strcmp(command,'ClearAll')         %%% CLEAR CURRENT GRID AND .bel LIST
%%%
%%% CLEAR CURRENT GRID AND .bel LIST AND RESET AXIS
%%%
   cla
   axis('auto')
   set(GBfig,'UserData',[]);
   set(GBaxes,'UserData',[]);
   GBLoadBelBut=findobj(GBfig,'Type','uicontrol','Tag','GBLoadBelBut');
   GBHashBndBut=findobj(GBfig,'Type','uicontrol','Tag','GBHashBndBut');
   GBOutputBelBut=findobj(GBfig,'Type','uicontrol','Tag','GBOutputBelBut');
   set([GBLoadBelBut GBHashBndBut GBOutputBelBut],'Enable','off');
   set(GBInfoLine,'String',' Load a Grid with "Load Grid"');
   GB_GRID=0;
   GB_BND=0;
   GBOutPutBelFig=findobj(0,'Type','figure','Tag','GBOutPutBelFig');
   delete(GBOutPutBelFig);
   GBStartingNN=findobj(GBfig,'Type','uicontrol','Tag','GBStartingNN');
   set(GBStartingNN,'String','<enter>');      
   GBEndingNN=findobj(GBfig,'Type','uicontrol','Tag','GBEndingNN');
   set(GBEndingNN,'String','<enter>');   

elseif strcmp(command,'HashBnd')          %%% GENERATE BND LIST AND ORIENT LHS
%%%
%%% GENERATE BND LIST AND ORIENT LHS, IF BEL LISR DOES NOT EXIST
%%%
   
   % Call "Clear Codes" function if a bel list already exists; otherwise, 
   % compute the list from scratch
   if ~isnan(nbnd)
      genbel4('ClearCodes')
      return
   end

   set(GBInfoLine,'String',' Computing Boundary (Ignore "Divide by zero" warnings) ...');
   drawnow
   oldpt=get(GBfig,'Pointer');
   set(GBfig,'Pointer','watch');  

   % Compute element-finding arrays
   %
   belint4(e,x,y);
   ineg=el_areas4(e,x,y);
   global AR A B T
   if ~isempty(ineg)
      disp('??? Error using ==> genbel4')
      disp('negative element areas detected in element list')
      disp('check mesh with trigrid, diagnstcs, or convcodes');
      return
   end

   % Determine Boundary list
   %
   % Form (i,j) connection list from .ele element list
   %
   i=[e(:,1);e(:,2);e(:,3)];
   j=[e(:,2);e(:,3);e(:,1)];

   % Form the sparse adjacency matrix and add transpose.
   %
   n = max(max(i),max(j));
   ICM = sparse(i,j,-1,n,n);
   ICM = ICM + ICM';

   % Consider only the upper part of ICM, since ICM is symmetric
   % 
   ICM=ICM.*triu(ICM);

   % The boundary segments are ICM's with value == 1
   %
   ICM=ICM==1;

   % Extract the row,col from new ICM for the boundary list.
   %
   [ib,jb,s]=find(ICM);
   ib=ib(:);jb=jb(:);

   % Sort Col#1 of bnd and permute Col#2
   %
   [ib,iperm]=sort(ib);
   jb=jb(iperm);
   bnd=[ib(:) jb(:)];

   set(GBInfoLine,'String',' Re-ordering boundary list (this may take a while) ...');
   drawnow
   
   % The boundary list generated by the above sparse-matrix method
   % does not ensure that the "left-hand toward the grid interior" 
   % convention is maintained.  We'll force that part now.  Unfortunately,
   % this could take a while.  However, once this is done for a mesh, it 
   % need not be done again.  An existing .bel file can be loaded; its boundary
   % list will necessarily be ordered correctly. 
   %

   % Compute test points as follows:
   %
   %      Assume that the segments are oriented such that
   %      the interior of the FEM domain is to the left and then:
   %         1) compute boundary line-segment mid-points
   %         2) compute slopes of boundary line-segments
   %         3) compute normal slopes of boundary line-segments
   %         4) compute unit direction vectors of the boundary segment
   %            from the first node to the second.
   %         5) rotate the unit vectors pi/2 CCW, which SHOULD point 
   %            toward the interior, atleast locally.
   %         6) test points lie along normal segment direction vectors
   %            from mid-point.

   % 1) compute boundary line segment mid-points
        midp=[x(ib)+(x(jb)-x(ib))/2 y(ib)+(y(jb)-y(ib))/2];

   % 2) Compute boundary line segment slopes and replace Inf's by 1e10
	slope=(y(jb)-y(ib))./(x(jb)-x(ib));
	idx=find(slope>1e10);
	slope(idx)=1e10*ones(size(idx));

   % 3) Compute perpendicular slopes and replace Inf's by 1e10
	slopeperp=-1./slope;
	idx=find(slopeperp>1e10);
	slopeperp(idx)=1e10*ones(size(idx));

   % 4) Compute unit direction vectors 
	mag=sqrt((x(jb)-x(ib)).*(x(jb)-x(ib))+(y(jb)-y(ib)).*(y(jb)-y(ib)));
	UDVx=[x(jb)-x(ib)]./mag;
	UDVy=[y(jb)-y(ib)]./mag;

   % 5) rotate vectors; theta=pi/2, so cos terms==0, sin terms==1
	PUDVx=-UDVy;
	PUDVy=UDVx;

   % 6) test points are along normal direction vectors eminating
   %    from the boundary line-segment mid-points.
	dxy=sqrt(min(AR))/10;
	testx=midp(:,1)+PUDVx*dxy;
	testy=midp(:,2)+PUDVy*dxy;

   set(GBInfoLine,'String',' Ignore "Divide by zero" warnings!!')
   
   % Now, locate elements for each test point.  If a point is in the 
   % domain, an element will be found for it, and the boundary segment 
   % is oriented correctly.  Otherwise, switch the order of the boundary
   % segment node numbers.  The test points whose corresponding element
   % number, as returned by FINDELE, is NaN is a test point from a boundary
   % segment in the reverse order.
   %
%   j=findelemex4(testx,testy,AR,A,B,T);
   j=findelemex5(testx,testy,AR,A,B,T);
   
   irev=find(isnan(j));
   temp=bnd(irev,1);
   bnd(irev,1)=bnd(irev,2);
   bnd(irev,2)=temp;

   % Resort Col#1 of bnd and permute Col#2, 
   % just to make it easier to debug
   %
   ib=bnd(:,1);jb=bnd(:,2);
   [ib,iperm]=sort(ib);
   jb=jb(iperm);
   bnd=[ib(:) jb(:)];
   
   % Store bnd list in figure UserData, along with rest of grid
   %
   temp=get(GBfig,'UserData');
   temp(2,6)=length(bnd);
   temp(1:length(bnd),7:8)=bnd;
   set(GBfig,'UserData',temp);

   % Create the ".bel" matrix, this will be placed in the main axes
   % 'UserData' for later retrieval
   %
   % 5-columns 1) segment number 
   %           2) left-hand boundary node number, facing interior
   %           3) right-hand boundary node number, facing interior
   %           4) code for left of boundary segment; always 0
   %           5) code for right of boundary segment; 1-5
   %   
   temp=get(GBfig,'UserData');
   nbnd=temp(2,6);
   bnd=temp(1:nbnd,7:8);
   bellist=zeros(length(bnd),5);
   bellist(:,1)=[1:length(bnd)]';
   bellist(:,2)=bnd(:,1);
   bellist(:,3)=bnd(:,2);
   set(GBaxes,'UserData',bellist);

   % Draw boundary as is, probably with the 'no code assigned' color (white)
   %
   genbel4('PlotBnd')

   GBOutputBelBut=findobj(GBfig,'Type','uicontrol','Tag','GBOutputBelBut');
   set(GBOutputBelBut,'Enable','on');
   set(GBInfoLine,'String',' Enter Starting and Ending NN to connect (ignore "div by 0" warnings)')
   GB_BND=1;
   set(GBfig,'Pointer',oldpt);  
   
elseif strcmp(command,'Help')             %%% HELP PAGES
%%%
%%% HELP PAGES
%%%
   page1=[];          % Intro and Credits
   page2=[];
   page3=[];
   page4=[];
   page5=[];
%
% COLUMN COUNTERS
%       10        20        30        40        50        60        70        80
%        *         *         *         *         *         *         *         *   
%2345678901234567890123456789012345678901234567890123456789012345678901234567890   
   % PAGE 1
   page1=str2mat(' ',...
                 '                    Introduction and Startup: ',...
                 ' ',...
                 ' GENBEL is a mouse-driven interface for creating .bel files',...
                 ' from the domain files .ele and .nod.  GENBEL will either',...
                 ' create a .bel file from scratch or load an existing one',...
                 ' for the domain name specified in the .ele and .nod files.',...
                 ' ',...
                 ' At the MATLAB prompt, type "genbel4".  The GENBEL4',...
                 ' figure and controls will be generated.  At the bottom ,',...
                 ' of the figure there is an "Info" line that usually');
   page1=str2mat(page1,...    
                 ' points the user in next direction.  Reading these "Help ',...
                 ' Pages" and following those prompts should cover most',...
                 ' problems.  The GENBEL4 Help windows are resizable, so',...
                 ' if text hangs off the edge or end, "drag" the window to',...
                 ' a new size.');
   page1=str2mat(page1,...    
                 ' ',...
                 ' GENBEL4 was written by:',...
                 '          Brian O. Blanton',...
                 '          OPNML - Curr. in Marine Sciences',...
                 '          12-7 Venable Hall, CB#3300',...
                 '          UNC-CH, Chapel Hill, NC, 27599-3300',...
                 '          December 1995');
   % PAGE 2
%       10        20        30        40        50        60        70        80
%        *         *         *         *         *         *         *         *   
%2345678901234567890123456789012345678901234567890123456789012345678901234567890   
   page2=str2mat(' ',...
                 '                     Initial Steps: ',...
                 ' ',...
                 ' 1)  Load a domain by clicking on the "Load Grid" button.',...
                 '     Navigate to the input files with the "PopUp" file browers.',...
                 ' 2a) If you have an existing .bel file for the domain, ',...
                 '     load it with the "Load Bel" button.  Use this even if ',...
                 '     you intend on changing all of the boundary codes.  ',...
                 ' 2b) Use the "New Bel" only if you have NO .bel file for a ',...
                 '     domain.  This function parses and orders a bnd list ');
   page2=str2mat(page2,...    
                 '     directly from the element connectivity list and the',...
                 '     re-ordering can take a while if the mesh is >10000',...
                 '     elements.',...
                 ' 3)  Click on "Axis Equal" if you want a 1-to-1 aspect ratio.');

   % PAGE 3
%       10        20        30        40        50        60        70        80
%        *         *         *         *         *         *         *         *   
%2345678901234567890123456789012345678901234567890123456789012345678901234567890   
   page3=str2mat(' ',...
                 '                Specifying nodes and conditions: ',...
                 ' ',...
                 ' There are 2 ways to specify the starting and ending node',...
                 ' numbers.  ',...
                 '    1) Enter directly into the spaces marked "<enter>"',...
                 '    2) Navigate to a node-region with the zoom button',...
                 '       and click on "Number Bnd" or "Mark Bnd", and ',...
                 '       then click on the highlighted node itself.');
   page3=str2mat(page3,...    
                 '       The left mouse button will enter the number ',...
                 '       into the "Starting NN" field and the middle',...
                 '       mouse button will enter the number into the',...
                 '       "Ending NN" field.  Double-clicking with any ',...
                 '       button will clear both fields.  You MUST turn ZOOM',...
                 '       off before clicking on a node number.  Zoom all the',...
                 '       way out by double-clicking with any button while ',...
                 '       ZOOM is on.');
    page3=str2mat(page3,...    
                 ' ',...
                 ' The order in which the starting and ending nodes are',...
                 ' specified MATTERS.  GENBEL4 will connect the segments in',...
                 ' CounterClockWise (CCW) order.  However, if the numbers',...
                 ' are entered ClockWise, you can re-enter them in reverse',...
                 ' order by clicking on "SWITCH", click on "Connect", and ',...
                 ' the "error" will be over-written.');
    page3=str2mat(page3,...    
                 ' ',...
                 ' Next, click on the boundary type to assign the segment.',...
                 ' If all needed parameters have been specified, the "Connect"',...
                 ' button will turn green; click on it to make the connection.',...
                 ' The segment will be re-drawn in a color according to the',...
                 ' color of the "Boundary Type" specification buttons.');
                
   % PAGE 4
%       10        20        30        40        50        60        70        80
%        *         *         *         *         *         *         *         *   
%2345678901234567890123456789012345678901234567890123456789012345678901234567890   
    page4=str2mat(' ',...
                  '            Islands and Outputing the .bel file',...
                  ' ',...
                  ' You do not need to specify "Island" boundary codes',...
                  ' and segments.  Complete the outer boundary segments',...
                  ' first and at output time (see below), GENBEL4 will',...
                  ' provide the oportunity to assume ALL remaining ',...
                  ' un-assigned boundary segments are islands.  If the ',...
                  ' exterior boundary has been completely accounted for,',...
                  ' THIS WILL BE TRUE!!.  If you need to specify an ');
    page4=str2mat(page4,...    
                  ' island, enter the same number for starting and ending ',...
                  ' points, click on the BLUE Boundary Type bar, and click',...
                  ' on "Connect".');
    page4=str2mat(page4,...    
                  ' ',...
                  ' When you are ready to output the current boundary',...
                  ' configuration, click on "Output Bel" and follow the',...
                  ' prompts.  See "Data File Standards for the Gulf of',...
                  ' Maine Project", by Christopher E. Naimie, March 29,',...
                  ' 1993, Numerical Methods Laboratory, Thayer School of',...
                  ' Engineering, Dartmouth College, for a discussion of',...
                  ' filetypes and conventions.');
   
    
   % PAGE 5
%       10        20        30        40        50        60        70        80
%        *         *         *         *         *         *         *         *   
%2345678901234567890123456789012345678901234567890123456789012345678901234567890   
    page5=str2mat(' ',...
                  '                          Other Functions',...
                  ' ',...
                  ' "Clr Marks" clears the node numbers (vis & invis).',...
                  ' "Clear All" clears the current grid and boundary data',...
                  '     from GENBEL4 and is ready to start fresh.',...
                  ' "Kill (No Save)" terminates GENBEL4 with no option to save.',...
                  ' "SWITCH" flips the starting and ending nodes, which ',...
                  '    effectively reverses the order of connection from CW to ',...
                  '    CCW.  This is useful if the node numbers were entered ',...
                  '    in the wrong direction.');
          
   
   figname='GENBEL4 Help';
   ttlstr='GENBEL4 Help Pages';
   helpfun2(figname,ttlstr,page1,page2,page3,page4,page5);      
else                                      %%% IF THIS POINT IS EVER REACHED....
   disp('HOLE IN COMMAND SWITCHING')      %%% SOMETHING IS TERRIBLY WRONG!!!
   disp('HOLE IN COMMAND SWITCHING')
   disp('HOLE IN COMMAND SWITCHING')
   disp('HOLE IN COMMAND SWITCHING') 
end
