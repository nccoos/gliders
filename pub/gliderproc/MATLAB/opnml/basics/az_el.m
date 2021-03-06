%
% AZ_EL set up azimuth and elevation slider controls for 3-D viewing
%
% AZ_EL generates 2 uicontrols (sliders) to allow changing the view point
%       of a 3-D plot by moving the slider controls.  The user may
%       call AZ_EL from the command-line or within a function by 
%       passing AZ_EL "1" as the argument.   
%
% Call as: >>  az_el(1);
%
% AZ_EL was gutted from a MATLAB demo 
% and turned into a function by:
% Brian O. Blanton
%
function az_el(arg)

if ~exist('arg'),return,end 

if arg==1  
   fig=gcf;
   % Define Azimuth Slider
   sli_azm=uicontrol(fig,'Style','Slider','Units','Pixels',...
                     'Position',[50 10 120 20],...
                     'Tag','sli_azm',...
                     'Min',-90,'Max',90,'Value',-27,...
                     'CallBack','az_el(2)');
   % Define Elevation Slider
   sli_elv=uicontrol(fig,'Style','Slider','Units','Pixels',...
                     'Position',[240 10 120 20],...
                     'Tag','sli_elv',...
                     'Min',-90,'Max',90,'Value',30,...
                     'CallBack','az_el(3)');
   % Define Text Controls for the Minimum values
   azm_min=uicontrol(fig,'Style','text','Units','Pixels',...
                     'Position',[20 10 30 20],...
                     'Tag','azm_min',...
                     'String',num2str(get(sli_azm,'Min')));
   elv_min=uicontrol(fig,'Style','text','Units','Pixels',...
                     'Position',[210 10 30 20],...
                     'Tag','elv_min',...
                     'String',num2str(get(sli_elv,'Min')));
   % Define Text Controls for the Maximum values
   azm_max=uicontrol(fig,'Style','text','Units','Pixels',...
                     'Position',[170 10 30 20],...
                     'String',num2str(get(sli_azm,'Max')),...
                     'Tag','azm_max',...
                     'Horizon','right');
   elv_max=uicontrol(fig,'Style','text','Units','Pixels',...
                     'Position',[360 10 30 20],...
                     'String',num2str(get(sli_elv,'Max')),...
                     'Tag','elv_max',...
                     'Horizon','right');
   % Define Slider Labels
   azm_label=uicontrol(fig,'Style','text','Units','Pixels',...
                       'Position',[50 40 65 20],...
                       'Tag','azm_label',...
                       'String','Azimuth');                      
   elv_label=uicontrol(fig,'Style','text','Units','Pixels',...
                       'Position',[240 40 65 20],...
                       'Tag','elv_label',...
                       'String','Elevation');                      
   % Define Text Controls for Current Values
   azm_cur = uicontrol(fig,'Style','text','Units','Pixels',...
                      'Position',[120 40 50 20],...
                      'Tag','azm_cur',...
                      'String',num2str(get(sli_azm,'Value')));
   elv_cur = uicontrol(fig,'Style','text','Units','Pixels',...
                      'Position',[310 40 50 20],...
                      'Tag','elv_cur',...
                      'String',num2str(get(sli_elv,'Value')));
elseif arg==2
   sli_azm=findobj(gcf,'Type','uicontrol','Tag','sli_azm');
   sli_elv=findobj(gcf,'Type','uicontrol','Tag','sli_elv');
   azm_cur=findobj(gcf,'Type','uicontrol','Tag','azm_cur');
   set(azm_cur,'String',num2str(get(sli_azm,'Val')))
   set(gca,'View',[get(sli_azm,'Val'),get(sli_elv,'Val')])
elseif arg==3
   sli_azm=findobj(gcf,'Type','uicontrol','Tag','sli_azm');
   sli_elv=findobj(gcf,'Type','uicontrol','Tag','sli_elv');
   elv_cur=findobj(gcf,'Type','uicontrol','Tag','elv_cur');
   set(elv_cur,'String',num2str(get(sli_elv,'Val')))
   set(gca,'View',[get(sli_azm,'Val'),get(sli_elv,'Val')])
end

%
%        Brian O. Blanton
%        Curr. in Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@cuda.chem.unc.edu
%
