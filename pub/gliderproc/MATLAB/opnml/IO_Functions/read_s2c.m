function [data,freq,gridname]=read_s2c(fname)
%READ_S2C read a FEM output file of .s2c filetype.
%   READ_S2C is part of a suite of OPNML I/O functions  
%   to read specific filetypes pertaining to FEM model  
%   input and output.   These functions allow the user to
%   get these data files into MATLAB without copying the
%   files and removing the header info by hand.
%
%   READ_S2C reads the ascii filetype .s2c,
%   as detailed in "Data File Standards for the Gulf of Maine 
%   Project" from the Numerical Methods Laboratory at Dartmouth
%   College.  (This document is located in the OPNML notebook 
%   under External Documents.)  There are three columns, the first
%   of which is the node number.  The second and third columns  
%   are floating point numbers.  The filetype suffix ('.s2c') 
%   must be included in the input file name. 
%
%   Input :   If fname is omitted, READ_S2C enables a file browser
%             with which the user can specify the .s2c file.
%
%             Otherwise, fname is the name of the file, relative or 
%             absolute (fullpath). This input is a string so it 
%             must be enclosed in single quotes. The comment line 
%             is discarded.
%
%  Output :   Call READ_S2C as:
%             >> [data,freq,gname]=read_s2c(fname);
%             The domain name will be returned in "gname".
%             The frequency in rads/secs is returned in "freq".
%             The node counter, amplitude and phase of the scalar 
%             field are returned in "data".
%
%             If READ_S2C cannot locate the file, it exits, returning 
%             a -1 instead of the data matrix.
%
% Call as: [data,freq,gname]=read_s2c(fname);
%
% Written by : Brian O. Blanton
%

if nargin==0 & nargout==0
   disp('Call as: [data,freq,gname]=read_s2c(fname);')
   return
end

if ~exist('fname')
   [fname,fpath]=uigetfile('*.s2c','Which .s2c ?');
   if fname==0,return,end
else
   fpath=[];
end

% get filetype from tail of fname
ftype=fname(length(fname)-2:length(fname));

% make sure this is an allowed filetype
if ~strcmp(ftype,'s2c')
   error(['READ_S2C cannot read ' ftype ' filetype'])
end

% open fname
[pfid,message]=fopen([fpath fname]);
if pfid==-1
   error([fpath fname,' not found. ',message]);
end

% In all filetypes there is always a gridname and description line
% as lines #1 and #2 of the file.
% read grid name from top of file; header line #1
gridname=fgets(pfid);
gridname=blank(gridname);

% read description line from top of file; header line #2
descline=fgets(pfid);

% read frequency line (#3) 
freq=fscanf(pfid,'%f',1);

% read data segment 
data=fscanf(pfid,'%d %f %f',[3 inf])';
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
