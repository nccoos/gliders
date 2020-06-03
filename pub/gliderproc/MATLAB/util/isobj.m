%
% ISOBJ	Determine if input number refers to a graphics object.
%
%       ISOBJ(X) returns 1's where the elements of X are
% 		valid graphics object handles and 0's where they are not.
%
%	Keith Rogers 11/93
function boolean  = isobj(handle,currobj)

if nargin == 1,
	currobj = 0;
end
boolean = (handle == currobj);
if(strcmp(get(currobj,'Type'),'axes'));
	boolean = boolean | (handle == get(currobj,'xlabel'));
	boolean = boolean | (handle == get(currobj,'ylabel'));
	boolean = boolean | (handle == get(currobj,'zlabel'));
	boolean = boolean | (handle == get(currobj,'title'));
end
children = get(currobj,'Children');
if(children)
	for i = 1:length(children)
		boolean = boolean | isobj(handle,children(i));
	end
end
