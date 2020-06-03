
function out = vcolon(in);

if(prod(size(in))~=2)
  error('Input must be 2x1 or 1x2 vector');
else
  out=in(1):in(2);
end
