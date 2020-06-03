function [data,nnv,gname]=read_s3r(fname)
%READ_S3R read a FEM output file of .s3r filetype.
%   READ_S3R is part of a suite of OPNML I/O functions  
%   to read specific filetypes pertaining to FEM model  
%   input and output.   These functions allow the user to
%   get these data files into MATLAB without copying the
%   files and removing the header info by hand.
%
%   READ_S3R reads the ascii filetypes .s3r,
%   as detailed in "Data File Standards for the Gulf of Maine 
%   Project" from the Numerical Methods Laboratory at Dartmouth
%   College.  (This document is located in the OPNML notebook 
%   under External Documents.)  There are three columns, the 
%   first of which is the node number.  The second and third  
%   columns are floating point numbers.  The filetype suffix
%   ('.s3r') must be included in the input file name.    
%
%   Input :   If fname is omitted, READ_S3R enables a file browser
%             with which the user can specify the .s3r file.
%
%             Otherwise, fname is the name of the file, relative or 
%             absolute (fullpath), including the '.s3r' suffix; 
%             This input is a string so it must be enclosed in 
%             single quotes. The comment line is discarded.
%
%  Output :   Call READ_S3R as:
%             >> [data,nnv,gname]=read_s3r(fname);
%             The domain name will be returned in "gname".
%             The number of vertical nodes is returned in "nnv".
%             The node counter, depth and value of the scalar field
%             are returned in "data".
%
%             If READ_S3R cannot locate the file, it exits, returning 
%             a -1 instead of the data matrix.
%
%   NOTES :   The .s3r filetype contains 3-D data; i.e., real-valued
%             scalar data at each vertical node per horizontal node.
%
% Call as: [data,nnv,gname]=read_s3r(fname);
%
% Written by : Brian O. Blanton
%

if nargin==0 & nargout==0
   disp('Call as:  [data,nnv,gname]=read_s3r(fname);')
   return
end

if ~exist('fname')
   [fname,fpath]=uigetfile('*.s3r','Which .s3r ?');
   if fname==0,return,end
else
   fpath=[];
end

% get filetype from tail of fname
ftype=fname(length(fname)-2:length(fname));

% make sure this is an allowed filetype
if ~strcmp(ftype,'s3r')
   error(['READ_S3R cannot read ' ftype ' filetype'])
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
gname=blank(gridname);

% read description line from top of file; header line #2
descline=fgets(pfid);

% read number of vertical nodes (line #3) 
nnv=fscanf(pfid,'%d',1);

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
