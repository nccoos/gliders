	function h=landpage;
%
% LANDPAGE set up a fullpage plotting window, ~11 x ~8.5 inches
%
% LANDPAGE sets up a new figure that occupies ~11 x ~8.5 inches 
%          (landscape paper orientation) and prints to a ~10 X ~7.5
%          inch area on the printed page. This means the printed 
%          figure has 1 inch margins for axis labels, titles, etc.         
%
% Calls: none
h=figure;
%
% set figure (window) size to ~ letter size
%
set(gcf,'Units','inches')
set(gcf,'Position',[0.0 0.5 11. 8.5])
set(gcf,'PaperPosition',[0.5 0.5 10 7.5])
set(gcf,'Units','normalized')
set(gcf,'PaperOrientation','landscape')
set(gcf,'Tag','LandPage');
%
% set axes (picture) size; this axes will be 
% overridden by the subplot command
%
set(gca,'Units','inches')
set(gca,'Position',[1 1 9 6.5])
set(gca,'Units','normalized')
%
%        Brian O. Blanton
%        Curr. in Marine Science
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
