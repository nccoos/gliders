%-----------------------------------------------------------------------
% [smin(i),nclosest(i)]=closestnode(xref,yref,xobs,yobs)
% This function is a matlab version of closestnode.f
% 
% (xref,yref) is the reference grid
% (xobs,yobs) are the locations for which closest reference grid node 
%   numbers are desired
%
% Matlab5.1 commands
%-----------------------------------------------------------------------
function [smin,nclosest]=closestnode(xref,yref,xobs,yobs)
for i=1:length(xobs)
   [smin(i),nclosest(i)]=min((xref-xobs(i)).^2.0+(yref-yobs(i)).^2.0);
end
%-----------------------------------------------------------------------
