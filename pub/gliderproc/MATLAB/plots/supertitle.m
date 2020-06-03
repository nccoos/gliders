
function [ax,h]=supertitle(text)
     %
     %Centers a title over a group of vertical subplots.
     %Returns a handle to the title and the handle to an axis.
     % [ax,h]=supertitle(text)
     %           returns handles to both the axis and the title.
     % ax=supertitle(text)
     %           returns a handle to the axis only.
%
% Calls: none


     ax=axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off');
     set(get(ax,'Title'),'Visible','on')
     title(text);
     if (nargout < 2)
       return
     end
     h=get(ax,'Title');

