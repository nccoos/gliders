
function dstruct = read_gliderasc2(file)


%file = 'pelagia-2012-039-0-0.ebdasc';
%file = 'pelagia-2012-022-0-0.dbdasc';
%file = 'pelagia-2012-039-1-10.dbdasc';


% Calls: strfun/blank

datadir = '';
%file='test2.asc';

fid = fopen([datadir, file], 'r');

if(fid<0);
    error(['File ', file, ' does not exist.']);
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


% data=[];
% while 1
%   line=fgetl(fid); 
%   if ischar(line);
%       data=[data;
%       str2num(line)];
%   else;
%       break;
%   end
% end



% BEGIN NEW CODE (WStark) /////////////////////////////////////////////////
% Use Matlab IMPORTDATA function to read in body of glider ascii file
%
%  IMPORTDATA(FILENAME, DELIM, NHEADERLINES) loads data from ASCII file
%                                            FILENAME, delimited by DELIM,
%                                            reading numeric data starting
%                                            from line NHEADERLINES+1.

% file = blank(file);  % make sure the filename has no trailing whitespace

fimport = importdata(file, ' ', 17);

if(length(fimport)==1)
%    if(length(fimport.data)>=1)
        dstruct.data = fimport.data;
    else
        dstruct.data = [];
%    end
end
% END NEW CODE ///////////////////////////////////////////////////////////



fclose(fid);

%d=fscanf(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f\n',[14 inf]);
