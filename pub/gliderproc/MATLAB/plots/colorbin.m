
function colorbin(hc,cval);

%
% COLORBIN creates a "binned" colormap/colorbar for the current 
%	figure instead of the smooth colorbar.  
%
%	COLORBIN requires the following arguments:
%		hc (opt)	handle to the current colorbar
%		cval		vector of bin limits
%
%	colorbin(hc,cval);
%
% Calls: none
%
% Catherine R. Edwards
% Last modified: 31 Jul 2001
%

if nargin==1
  cval=hc;
end

cval=cval(:)';
hc=colorbar; clim=get(gca,'clim'); dc=clim(2)-clim(1);
map=colormap; nn=length(map);

% find where in colormap cvals lie
cind=max(round((cval-cval(1))*nn/dc),1);
len=diff([cind(cind<=nn) nn]); 
vals=map(cind(cind<=nn)+len,:);
rs=rldecode(len,vals(:,1)); 
gs=rldecode(len,vals(:,2)); 
bs=rldecode(len,vals(:,3)); 

colormap([rs gs bs]);
hc=colorbar;
