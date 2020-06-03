%
% EditLine Edit figure lines
%
% This is a callback function, used by OPNML-FEDAR MenuBar and 
% OPNML Prmenu.  This function should not be called directly!
%
% Original code from Keith Rogers  11/94
%
% Mods:
%     12/02/94 Shortened name to appease DOS users
%     12/5/94  Adapted to deal with single palette for all
%              figures,changed name to lower case to
%              appease VMS users.
%     12/14/94 Add Delete item callback
%     12/15/94 Fixed bugs.
%     12/20/94 When deleting an object, delete its 
%              SelectLine as well.
%
%     Mar 95 - Minor Mods by Brian Blanton for OPNML, including name 
%              change from 'dmencback'
%     Apr 95 - Mods by Sara Haines 
%          o Know about globals LASTOBJECT and LASTTYPE
%          o change name again 
%          o more object type checking, ii.e. for gridlinestyles
%
%     Aug 95 - Mods by Sara Haines
%          o removed color commands and options from this function
%          o edit value for 'other' option on line width and marker size.
%
function EditLine(command,option,subopt)

global LASTOBJECT LASTTYPE

selectedObj = LASTOBJECT;
if isempty(selectedObj),return,end	% exit if no selected object
type = LASTTYPE;

if (strcmp(type, 'line') | strcmp(type, 'patch'))
  style = get(selectedObj,'LineStyle');
end

if(command == 1)
   if(strcmp(type,'line'))
      set(selectedObj,'LineStyle',option);
   end
   
   if exist('subopt')
     if ( strcmp(subopt, 'Grid') | strcmp(subopt, 'MinorGrid') )
       set(selectedObj, [subopt 'LineStyle'], option)
     end
   end
elseif(command == 2)
   if(strcmp(type,'line') | strcmp(type,'patch'))
      if(option==0)
	value = get(selectedObj, 'LineWidth');
	option=EditValue('EditValue', 'Line Width:', value);
      end
      set(selectedObj,'LineWidth',option);
   end
elseif(command == 3)
   set(selectedObj,'Color',option);
elseif(command == 4)
   if(strcmp(type,'patch'))
      set(selectedObj,'FaceColor',option);
    elseif(strcmp(type,'axes'))
      set(selectedObj,'Color',option);
    elseif (strcmp(type, 'figure'))
      set(selectedObj, 'Color', option);
   end
elseif(command == 5)
   if(strcmp(type,'line'))
      if strcmp(style,'*') | ...
	    strcmp(style,'+') | ...
	    strcmp(style,'.') | ...
	    strcmp(style,'o')
         if(option==0)
	    value = get(selectedObj, 'MarkerSize');
	    option=EditValue('EditValue', 'Marker Size:', value);
            % if ~isint(option),option=floor(option);,end
         end
         set(selectedObj,'MarkerSize',option);
      end
   end
end

