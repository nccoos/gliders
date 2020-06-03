function fem_data_struct=read_fem_data(fname)
%READ_FEM_DATA read a FEM output file of standard filetype.
%   READ_FEM_DATA is part of a suite of OPNML I/O functions  
%   to read specific filetypes pertaining to FEM model  
%   input and output.   These functions allow the user to
%   get these data files into MATLAB without copying the
%   files and removing the header info by hand.
%
%   READ_FEM_DATA reads all FEM filetypes (.s2r,.v2c,...),
%   as detailed in "Data File Standards for the Gulf of Maine
%   Project" from the Numerical Methods Laboratory at 
%   Dartmouth College.  
%
%   READ_FEM_DATA returns a FEM_DATA_STRUCT to the local 
%   workspace that contains all into needed by subsequent 
%   routines.
%
%   If FNAME is omitted, READ_FEM_DATA enables a file 
%   browser with which the user can specify the  file.
%
%   Otherwise, FNAME is the name of a standard filetype, 
%   relative or absolute (fullpath), including the filetype
%   suffix.  This input is a char array so it must be enclosed 
%   in single quotes.
% 
%   See FEM_DATA_STRUCT for a description of the struct array
%   returned.
% Call as: >> data_struct=read_fem_data(fname);
%
% Written by : Brian O. Blanton

err1=['READ_FEM_DATA requires 0 or 1 argument.'];
err2=['Argument to READ_FEM_DATA must be a string (filename)'];
if ~exist('fname')
   [fname,fpath]=uigetfile('*','Which file');
   if fname==0,return,end
else
   if ~isstr(fname),error(err2),end
   % parse into filename and pathname
   slash_place=findstr(fname,'/');
   slash_place=slash_place(length(slash_place));
   fpath=fname(1:slash_place-1);
   fname=fname(slash_place+1:length(fname));
end

% Find dot delimiters in filename
dot_place=findstr(fname,'.');
% use only the last dot as the extension delimiter;
% this allows for gridnames with dots, like grid.new.ele, etc...
dot_place=dot_place(length(dot_place));
flength=length(fname);

% get filetype from tail of fname
ftype=fname(dot_place+1:flength);
fname2=fname(1:dot_place-1);

% make sure this is an allowed filetype
% The second set with trailing "e" allows for element-based
% data.
possible_types={'s2r','s2c','v2r','v2c','s3r','s3c','v3r','v3c',...
                's2re','s2ce','v2re','v2ce','s3re','s3ce','v3re','v3ce'};
if ~strcmp(ftype,possible_types)
      error(['READ_FEM_DATA cannot read ' ftype ' filetype'])
end

[pfid,message]=fopen([fpath '/' fname]);
if pfid==-1
   error([fpath fname,' not found. ',message]);
end

fem_data_struct.fname=fname2;
fem_data_struct.fext =ftype;
fem_data_struct.fpath=fpath;

% If we're this far...

%   the 2nd character of ftype is the dimension of the data
ndim=eval(ftype(2));
fem_data_struct.ndim=ndim;

%   the 1st character of ftype is the type of the data
type1=ftype(1);
if strcmp(type1,'s')
   type1='scalar';
else
   type1='vector';
end
fem_data_struct.type1=type1;

%   the 3rd character of ftype is the type real/complex
type2=ftype(3);
if strcmp(type2,'r')
   type2='real';
else
   type2='complex';
end
fem_data_struct.type2=type2;

%   if there is a 4th character, it is necessarily 'e' for 'element'
if length(ftype)==3
   type3='nodal';
else
   type3='elemental';
end
fem_data_struct.type3=type3;

% In all filetypes there is always a gridname 
% and description line as lines #1 and #2 of the file.
gridname=fgets(pfid);
iding=findstr(gridname,' ');
gridname(iding)=[];
descline=fgets(pfid);
fem_data_struct.gname=gridname;
fem_data_struct.h1=descline;

% If field is complex, frequency is next
% 
fem_data_struct.freq=1e-12;
if strcmp(type2,'complex')
   freq=eval(fgets(pfid));
   fem_data_struct.freq=freq;
end

% Depending on filetype, read remainder of file
if ndim==3
   % nnv is the next entry
   nnv=eval(fgets(pfid));
   fem_data_struct.nnv=nnv;
else
   fem_data_struct.nnv=1;
end
  
if ndim==2
   if strcmp(type1,'scalar')
      if strcmp(type2,'real')
	 ncol=1;
      else
	 ncol=2;
      end
   else   %  vector
      if strcmp(type2,'real')
	 ncol=2;
      else
	 ncol=4;
      end
   end
else
   if strcmp(type1,'scalar')
      if strcmp(type2,'real')
	 ncol=1;
      else
	 ncol=2;
      end
   else   %  vector
      if strcmp(type2,'real')
	 ncol=3;
      else
	 ncol=6;
      end
   end
end

% Build format string
format_string=['%d '];
for i=1:ncol
   format_string=[format_string '%f '];
end

% Add column for node counter
ncol=ncol+1;

% Extra column for depth in 3-D file
if ndim==3
   format_string=[format_string '%f '];
   ncol=ncol+1;
end

% Read block of data
data=fscanf(pfid,format_string,[ncol inf])';

if ndim==3
   fem_data_struct.zgrid=data(:,2);
   fem_data_struct.data1=data(:,3:ncol+1);
else
   fem_data_struct.zgrid='none';
   fem_data_struct.data1=data(:,2:ncol);
end

fclose(pfid);

%
%        Brian O. Blanton
%        Department of Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%        Fall 1998 
