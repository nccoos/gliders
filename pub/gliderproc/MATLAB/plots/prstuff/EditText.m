%
% EDITTEXT Edit text objects with the mouse
%
% This is a callback function, used by OPNML-FEDAR MenuBar and 
% OPNML Prmenu.  This function should not be called directly!
%
% Keith Rogers  11/94
%
% Mods:
%    12/02/94  Shortened name to appease DOS Users
%    Mar 95 - Minor Mods by Brian Blanton for OPNML, including name 
%             change from 'txtcback'
%
%    Aug 95 - Sara Haines made changes so that globals are checked
%             for Prmenu and added call for Edit Text
function EditText(command,data)

global LASTOBJECT LASTTYPE LASTAXIS

if isempty(LASTAXIS)
  curaxes=gca;
else 
  curaxes=LASTAXIS;
end

selectedObj = LASTOBJECT;
if isempty(selectedObj),return,end      % exit if no selected object
type = LASTTYPE;

if( strcmp(lower(get(selectedObj,'Type')),'text') | ...
  strcmp(lower(get(selectedObj,'Type')),'axes') & selectedObj ~= [] )
   if(command == 1)
      set(selectedObj,'FontName',data);
   elseif(command == 2)
      set(selectedObj,'FontAngle',data);
   elseif(command == 3)
      set(selectedObj,'FontWeight',data);
   elseif(command == 4)
      set(selectedObj,'FontAngle','normal','FontWeight','normal');
   elseif(command == 5)
      if(data == 0)
	value = get(selectedObj, 'FontSize');
	tval=EditValue('EditValue', 'Font Size:', value);
	set(selectedObj,'FontSize',tval);
      else
         set(selectedObj,'FontSize',data);
      end
   elseif(command == 6)
      set(selectedObj,'Vert',data);
   elseif(command == 7)
      set(selectedObj,'Horiz',data);
   elseif(command == 8)
     if strcmp(lower(get(selectedObj,'Type')),'text')	
       string = get(selectedObj, 'String');
       data = EditString('Edit String', 'Edit Text:', string);
       set(selectedObj,'String',data);
     end
   elseif(command == 9)
     data = EditString('Edit String', 'Add Text:', '');
     axes(curaxes);
     h=gtext(data);
   end
   
else
   if(command == 9)
     data = EditString('Edit String', 'Add Text:', '');
     axes(curaxes);
     h=gtext(data);
   end
end

