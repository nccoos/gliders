%
% outstr=blank(instr)
%
% BLANK returns the non-whitespace portion in the input string instr
%
% Calls: none
%
function outstr=blank(instr)

[m,n]=size(instr);
if m>1
   error('input string must be a vector');
end

% REMOVE LEADING BLANKS
%
[m,n]=size(instr);
count=0;

spaces=find(instr==' ');
instr(spaces)='';

outstr=instr;

return;
