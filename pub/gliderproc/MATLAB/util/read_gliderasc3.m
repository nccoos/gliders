
function dstruct = read_gliderasc3(file)



% dbdasc_extract.m

%fn = './pelagia-2012-046-4-0.tbdasc'

%file = 'pelagia-2012-022-0-0.dbdasc';
file = 'pelagia-2012-039-1-10.dbdasc';

datadir = '';

fid = fopen(blank([datadir, file]), 'r');

if fid>0
  numHeaderLines = 0;
  while (~feof(fid))
    
    % read header data without concern for order
    a = fgetl(fid);
    numHeaderLines = numHeaderLines + 1;
    if strmatch('num_ascii_tags:', a)
      numAsciiTags = str2num(a(17:end));
    elseif strmatch('filename_label:', a)
      fileName = a(17:end);
    elseif strmatch('mission_name:', a)
      missionName = a(15:end);
    elseif strmatch('sensors_per_cycle:', a)
      numVars = str2num(a(20:end));
    elseif strmatch('num_label_lines:', a)
      numLabelLines = str2num(a(17:end));
    elseif strmatch('segment_filename_0:', a)
      break;
    end
  end % while (~feof(fid))

  
  
  % extract variable labels
  labels = fgetl(fid);
  splitstring = textscan(labels,'%s');
  varLabels = splitstring{1}.';
  
  % extract unit labels
  labels = fgetl(fid);
  splitstring = textscan(labels,'%s');
  unitLabels = splitstring{1}.';
  
  % extract numbers
  a = fgetl(fid);


  
  dstruct.fname = fileName;
  dstruct.mname = missionName;
  dstruct.vars = varLabels;
  dstruct.varlabs = unitLabels;

  
  
  totalNumHeaderLines = numHeaderLines + numLabelLines;  
  
  formatString = repmat('%f', 1, numVars);
  % This creates '%f%f%f' ... but with dynamic length based on header info
  % You can make this elaborate based on file type (edb, dbd, tbd) and
  % intermix integers, float and strings.  e.g. %d%d%d%f%f%f%s%s

  
  % SMH -- 100 times faster to textscan() rather than load()
  %     -- and probably 1000 timers faster than reading line by line.
  D = textscan(fid, formatString, 'Headerlines', totalNumHeaderLines);
  D = cell2mat(D);
  [nr nc] = size(D);
  if nr>0
    dstruct.data = [D];
  end
  
end % if fid>0


fclose(fid);
