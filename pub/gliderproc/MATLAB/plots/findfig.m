function H = findfig(figname)
%FINDFIG Get figure handle from name
% H = FINDFIG(FIGNAME)
% Returns the handle of the foremost figure
% with name FIGNAME, or 0 if not found
%
% Calls: none
%
% Keith Rogers 9/26/94
 
% Copyright (c) 1995 by Keith Rogers 

allfigs = get(0,'children');
H = 0;
for thisfig = (allfigs')
  if strcmp(get(thisfig,'name'),figname)
	H = thisfig;
	break
  end
end
