
function dstruct = read_gliderasc(file)

% Calls: strfun/blank

datadir = '';
%file='test2.asc';

fid = fopen(blank([datadir,file]),'r');

if(fid<0);
    error(['File ',file,' does not exist.']);
end

for i=1:3  
  line = fgetl(fid); 
end

% grab # 
nvar = str2num(line(17:end));
for i=1:5
  line = fgetl(fid);
end

dstruct.fname = line(17:end);
line = fgetl(fid);
dstruct.mname = line(15:end);
for i=1:6
  line = fgetl(fid);
end

%line=fgetl(fid); 
line2 = fgetl(fid);
ndigits = str2num(fgetl(fid));
blpos = [0 find(line==' ') length(line)-1];
blpos2 = [0 find(line2==' ') length(line2)-1];
for i=1:length(blpos)-2
  dstruct.vars{i} = line(blpos(i)+1:blpos(i+1));
  dstruct.varlabs{i} = line2(blpos2(i)+1:blpos2(i+1));
end

data=[];
while 1
  line=fgetl(fid); 
  if ischar(line);
      data=[data;
      str2num(line)];
  else;
      break;
  end
end
fclose(fid);
dstruct.data = data;
%d=fscanf(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f\n',[14 inf]);
