
	function [ind,jnd,v] = inrange(data,drange);
	
dmin=min(drange); dmax=max(drange);

ind=find((data>=dmin) & (data<=dmax));

if(nargout>1)
  [ind,jnd]=ind2sub(size(data),ind);
end
