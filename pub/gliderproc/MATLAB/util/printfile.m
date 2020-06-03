%
% PRINTFILE create a dialog box to print figures to files
%
function printfile(opt,subopt)
if nargin==0,opt='Initialize';,end

curfig=gcf;
if strcmp(opt,'Initialize')  % Setup
   printfig=findobj(0,'Type','figure','Tag','PrintFig');
   if ~isempty(printfig),return,end

   printfig = figure('Position',[150 350 500 220],...
                   'NumberTitle','off',...
                   'Name','Printfile Setup',...
                   'NextPlot','new',...
                   'Tag','PrintFig');
   set(printfig,'UserData',curfig);

   ColorButton = uicontrol('Parent',printfig,...
                     'Style','checkbox',...
                     'String','Color ?',...
                     'Units','normalized',...
                     'Position',[.05 .2 .2 .125],...
                     'Tag','ColorButton');
   set(ColorButton,'UserData',str2mat('<NULL>','<NULL>'));
   
   EncapButton = uicontrol('Parent',printfig,...
                     'Style','checkbox',...
                     'String','Encapsulate ?',...
                     'Units','normalized',...
                     'Position',[.3 .2 .3 .125],...
                     'Tag','EncapButton');

   FNameButton=uicontrol('Parent',printfig,...
                     'Style','pushbutton',...
                     'String','File Name',...
                     'Units','normalized',...
                     'Position',[.3 .4 .3 .125],...
                     'Callback','printfile(''To File'')',...
                     'Tag','FNameButton');

   PrintButton=uicontrol('Parent',printfig,...
                     'Style','pushbutton',...
                     'String','Print',...
                     'Units','normalized',...
                     'Position',[.7 .4 .2 .125],...
                     'Callback','printfile(''Exec Print'')',...
                     'Tag','PrintButton');

   CancelButton=uicontrol('Parent',printfig,...
                     'Style','pushbutton',...
                     'String','Cancel',...
                     'Units','normalized',...
                     'Position',[.7 .2 .2 .125],...
                     'Callback','printfile(''Kill'')',...
                     'Tag','CancelButton');

elseif strcmp(opt,'To File')    
   ColorButton=findobj(0,'Type','uicontrol','Tag','ColorButton');
   [outfile, outpath] = uiputfile('', 'Save As');
   set(ColorButton,'UserData',str2mat(outpath,outfile));        
elseif strcmp(opt,'Kill')
   printfig=findobj(0,'Type','figure','Tag','PrintFig');
   delete(printfig);
elseif strcmp(opt,'Exec Print')
   printfig=findobj(0,'Type','figure','Tag','PrintFig');
   ColorButton=findobj(printfig,'Type','uicontrol','Tag','ColorButton');
   ud=get(ColorButton,'UserData');
   if strcmp(ud(2),'<null>')|strcmp(ud(2),' ')
      errstr=['No filename set.  No file printed.'];  
      herr=errordlg(errstr);
      return
   end
   
   outname=deblank([ud(1,:) ud(2,:)]);
   curfig=get(printfig,'UserData');
   
   EncapButton=findobj(printfig,'Type','uicontrol','Tag','EncapButton');
   ColorButton=findobj(printfig,'Type','uicontrol','Tag','ColorButton');
   EncapButtonVal=get(EncapButton,'value');
   ColorButtonVal=get(ColorButton,'value');
   
   if (EncapButtonVal&ColorButtonVal)
      dash='-depsc' ;                     % Encapsulated Color PostScript (EPSF)
   elseif (EncapButtonVal) 
      dash='-deps' ;                      % Encapsulated B&W PostScript (EPSF)
   elseif (ColorButtonVal)
      dash='-dpsc' ;                      % Color PostScript
   else
      dash='-dps';                        % B&W PostScript
   end
   
% If printer is defined in shell, use it; else, let MATLAB do its default
   PRINTER=getenv('PRINTER');
   if ~isempty(PRINTER)
      dash = [dash ' -P' PRINTER];
   end

   if ~strcmp(outname,'<NULL><NULL>')
      prcom=['print ' dash ' ' outname];
   else
      prcom=['print ' dash];
   end

   figure(curfig);
   eval(prcom);  
   set(ColorButton,'UserData',str2mat('<NULL>','<NULL>'));   
end
%
%        Brian O. Blanton
%        Curriculum in Marine Science
%        Ocean Processes Numerical Modeling Laboratory
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%        March 1995
%

