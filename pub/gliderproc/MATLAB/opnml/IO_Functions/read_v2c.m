function [data,freq,gridname]=read_v2c(fname)
%READ_V2C read a FEM output file of .v2c filetype.
%   READ_V2C is part of a suite of OPNML I/O functions  
%   to read specific filetypes pertaining to FEM model  
%   input and output.   These functions allow the user to
%   get these data files into MATLAB without copying the
%   files and removing the header info by hand.
%
%   READ_V2C reads the FEM filetype .v2c, as 
%   detailed in "Data File Standards for the Gulf of Maine
%   Project" from the Numerical Methods Laboratory at 
%   Dartmouth College.  (This document is located in the OPNML
%   notebook under External Documents.)  There are five
%   columns, the first of which is the node number.  The
%   remaining columns are floating point. The filetype 
%   suffix ('.v2c') must be included in the input file name.  
%
%   Input :   If fname is omitted, READ_V2C enables a file browser
%             with which the user can specify the .v2c file.
%
%             Otherwise, fname is the name of the file, relative or 
%             absolute (fullpath).  This input is a string so it must 
%             must be enclosed in single quotes. The comment line 
%             is discarded.
%
%  Output :   Call READ_V2C as:
%             >> [data,freq,gname]=read_v2c(fname);
%             The domain name will be returned in "gname".
%             The frequency in rads/secs is returned in "freq".
%             The node counter and amplitude and phase of the 
%             u and v components of the vector field are returned 
%             in "data".
%
%             If READ_V2C cannot locate the file, it exits, returning 
%             a -1 instead of the data matrix.
%
% Call as: [data,freq,gname]=read_v2c(fname);
%
% Written by : Brian O. Blanton
%

if nargin==0 & nargout==0
   disp('Call as: [data,freq,gname]=read_v2c(fname);')
   return
end

if ~exist('fname')
   [fname,fpath]=uigetfile('*.v2c','Which .v2c ?');
   if fname==0,return,end
else
   fpath=[];
end

% get filetype from tail of fname
ftype=fname(length(fname)-2:length(fname));

% make sure this is an allowed filetype
if ~strcmp(ftype,'v2c')
   error(['READ_V2C cannot read ' ftype ' filetype'])
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
data=fscanf(pfid,'%d %f %f %f %f',[5 inf])';
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
