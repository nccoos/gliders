
	function clim= newclim(begslot,endslot,oldclim,cmlength);

%  NEWCLIM.M -- A routine which resets clims when plotting multiple
%               subplots on one figure which require multiple colormaps.
%	       Effectively, NEWCLIM tricks matlab into letting us use
%	       part of the colormap (global to the figure, not the axes).
%	       
%	       You must concatenate the multiple colormaps and note their
%	       respective places within the extended colormap.  
%	       
%  NEWCLIM requires the following arguments:
%  	begslot/endslot - the first and last indices into the concatenated
%			  colormap	
%	oldclim		- the original clims when plotted with the concatenated
%		       	  colormap 
%	cmlength	- the length of the concatenated colormap
%
%  output vars:
%  	clim		- the new clims, to be reset through set(gca,....)
%	
%  See also PCBAR, a function which allows the desired subcolormap to be
%    placed alongside the new colormesh.  
%
% Calls: none
%    
% Last modified: 7 Oct 1999
% Catherine R. Edwards
%	


Bslot=(begslot-1)/(cmlength-1);
Eslot=(endslot-1)/(cmlength-1);
cmrange=Eslot-Bslot;
drange=oldclim(2)-oldclim(1);
clrange=drange/cmrange;
clim(1)=oldclim(1)-(Bslot*clrange);
clim(2)=oldclim(2)+(1-Eslot)*clrange;

return;
