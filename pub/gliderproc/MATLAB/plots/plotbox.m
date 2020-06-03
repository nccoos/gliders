
	function hbox=plotbox(xl,yl);
%
% Calls: none
	
	hold on;  
hbox=plot([xl(1) xl(2) xl(2) xl(1) xl(1)],[yl(2) yl(2) yl(1) yl(1) yl(2)]);
	
