
%	LOADZ loads a compressed file (.Z extension) from data
%	without having to create alternate directories
%
% 	LOADZ is not yet modified for returning outputs
%	(e.g., [data, time]=loadZ(filename); )
%
%	compressed_filename='/mastiff/data/ioeb97b/unpack/gdb1.dat.Z';
%	loadZ;
%
% 	Catherine R. Edwards
%	Last modified: 2 Jun 1999

% check to make sure input filename has a .Z extension

len=length(compressed_filename);
tag=compressed_filename(len-1:len);

if strcmp(tag,'.Z')==0
  disp('Input file must have a compressed extension')
  return;
end

[s]=unix(['cp ',compressed_filename,' .']);
slash=findstr(compressed_filename,'/');
last=length(slash); 
uncompressed_filename=compressed_filename(slash(last)+1:len-2);

if s~=0
  disp('Error finding file')
  return;
end

[s]=unix(['uncompress ',uncompressed_filename,'.Z']);
if s~=0
  disp('Error compressing file')
  return;
end

disp('Loading file ... please be patient.')

load(uncompressed_filename);
%try
%   tmpStruc = load( filename );
%   data = tmpStruc.data;
%catch, return, end


[s]=unix(['rm ',uncompressed_filename]);

clear uncompressed_filena s slash last len tag

return;





