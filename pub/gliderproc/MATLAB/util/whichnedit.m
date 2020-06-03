function [status,result]=whichnedit(funcname);
%
%	WHICHNEDIT	- shortcut function to which a function
%			  then nedit it
%
%	whichnedit(funcname);			% funcname is a string
%

file=which(funcname);
[status,result]=system(['nedit ',file,'&']);
