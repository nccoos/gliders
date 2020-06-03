
function  resize_legend (hL, ResizeFact)
%RESIZE_LEGEND - Changes LEGEND fontsize and axes position
%
%Syntax:  resize_legend(hL, ResizeFact);
%
%Inputs: 
%  hL           Legend axes handle
%  ResizeFact   Factor by which to resize the legend.
%               
%Example: %Make fontsize and legend axes twice bigger
%         hL=legend(......);
%         resize_legend(hL,2); 
%
%
% Calls: none
%Authors: Jim Phillips and Denis Gilbert
%Last revision: 20-Mar-2001

if ~exist('ResizeFact','var'), 
    warning('No resize factor provided')
    return
end

p = get(hL, 'position');
p(3) = p(3)*ResizeFact;
p(4) = p(4)*ResizeFact;
set(hL,'position', p)
ht = findobj( get(hL,'children'), 'type', 'text');
set(ht, 'FontSize', get(ht,'FontSize')*ResizeFact)
set(gcf,'Resizefcn','')
%set(hL,'visible','off')  %


