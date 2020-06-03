%
% FULLPAGE set up a fullpage plotting window, ~8.5 x ~11 inches
%
% FULLPAGE sets up a new figure that occupies ~8.5 x ~11 inches and 
%          prints to a ~7.5 X ~10 inch area on the printed page.
%          This means the printed figure has 1 inch margins for
%          axis labels, titles, etc.         
% 
%
% Calls: none
figure
%
% set figure (window) size to ~ letter size
%
set(gcf,'Units','inches')
set(gcf,'Position',[0.0 0.0 8.5 11.])
set(gcf,'PaperPosition',[0.5 0.5 7.5 10])
set(gcf,'Units','normalized')
set(gcf,'Tag','FullPage');
%
% set axes (picture) size; this axes will be 
% overridden by the subplot command
%
set(gca,'Units','inches')
set(gca,'Position',[1 1 6.5 8])
set(gca,'Units','normalized')
wysiwyg;
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
%        blanton@marine.unc.edu
%
