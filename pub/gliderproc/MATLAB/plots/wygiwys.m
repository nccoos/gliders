%
% WYGIWYS What you get is what you see
%
% WYGIWYS This function is called with no args and merely
%         changes the size of the figure printed to equal
%         the size of the figure that you see, 
%         according to the papersize attribute.  
%
% Calls: none
%
%         Catherine R. Edwards, NRL 
 
function wygiwys

set(gcf,'paperpositionmode','auto');
unis = get(gcf,'units');
ppos = get(gcf,'paperposition');
set(gcf,'units',get(gcf,'paperunits'));
pos = get(gcf,'position');
ppos(3:4) = pos(3:4);
set(gcf,'paperposition',ppos);
set(gcf,'units',unis);
