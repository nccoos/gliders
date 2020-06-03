function [data,gridname]=read_s2r(fname)
%READ_S2R read a FEM output file of s2r filetype.
%   READ_S2R is part of a suite of OPNML I/O functions  
%   to read specific filetypes pertaining to FEM model  
%   input and output.   These functions allow the user to
%   get these data files into MATLAB without copying the
%   files and removing the header info by hand.
%
%   READ_S2R reads the FEM filetype s2r, as detailed in
%   "Data File Standards for the Gulf of Maine Project"
%   from the Numerical Methods Laboratory at Dartmouth
%   College.  (This document is located in the OPNML
%   notebook under External Documents.)  There are two
%   columns, the first of which is the node number.  The
%   second column is floating point.  
%
%   Input :   If fname is omitted, READ_S2R enables a file browser
%             with which the user can specify the .s2r file.
%
%             Otherwise, fname is the name of the s2r file, relative 
%             or absolute (fullpath), including the suffix 's2r'.
%             This input is a string so it must be enclosed in single 
%             quotes. The header lines are discarded.
%
%  Output :   The data part is returned in the variable data.
%             The domain name is returned in gname 
%
%             Call READ_S2R as:
%             >> [data,gname]=read_s2r(fname);
%
%             If READ_S2R cannot locate the file, it exits, returning 
%             a -1 instead of the data matrix.
%
% Call as: >> [data,gname]=read_s2r(fname);
%
% Written by : Brian O. Blanton
%

if nargin==0 & nargout==0
   disp('Call as: [data,gname]=read_s2r(fname);')
   return
end

if ~exist('fname')
   [fname,fpath]=uigetfile('*.s2r','Which .s2r');
   if fname==0,return,end
else
   fpath=[];
end

% get filetype from tail of fname
ftype=fname(length(fname)-2:length(fname));

% make sure this is an allowed filetype
if ~strcmp(ftype,'s2r')
      error(['READ_S2R cannot read ' ftype ' filetype'])
end

% open fname
[pfid,message]=fopen([fpath fname]);
if pfid==-1
   disp([fpath fname,' not found. ',message]);
   data=-1;
   return
end

% In all filetypes there is always a gridname and description line
% as lines #1 and #2 of the file.
% read grid name from top of file; header line #1
gridname=fgets(pfid);
gridname=blank(gridname);

% read description line from top of file; header line #2
descline=fgets(pfid);

% read data segment 
data=fscanf(pfid,'%d %f',[2 inf])';
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
