function [dataname]=load_array(filename)
load([filename]);
size(filename);
nchar=ans(2);
for i=1:nchar
   if filename(i) == '.'
      iend=i-1;
      break;
   elseif i==nchar
      iend=i;
      fprintf(1,'Could not find the end of the filename: %c\n',filename);
   end
end
dataname=eval([filename(1:iend)]);
