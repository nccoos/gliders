function [data,nnv,freq,gridname]=read_vel(fname);
%READ_VEL read a FEM output file of .vel filetype.
%   READ_VEL is part of a suite of OPNML I/O functions  
%   to read specific filetypes pertaining to FEM model  
%   input and output.   These functions allow the user to
%   get these data files into MATLAB without copying the
%   files and removing the header info by hand.
%
%   READ_VEL reads the FEM filetype .vel, as detailed in
%   "Data File Standards for the Gulf of Maine Project"
%   from the Numerical Methods Laboratory at Dartmouth
%   College.  (This document is located in the OPNML
%   notebook under External Documents.)  There are eight
%   columns, the first of which is the node number.  The
%   remaining columns are floating point.  
%
%   Input :   If fname is omitted, READ_VEL enables a file browser
%             with which the user can specify the .vel file.
%
%             Otherwise, fname is the name of the .vel file, relative 
%             or absolute (fullpath), including the suffix '.vel'.
%             This input is a string so it must be enclosed in single 
%             quotes. The header lines are discarded.
%
%  Output :   The data part is returned in the variable data.  
%             There are eight columns, the first of which is the node 
%             number.  The remaining columns are floating point.
%             The number of vertical nodes is returned in nnv, and
%             the frequency is returned in freq. 
%
%             Call READ_VEL as:
%             >> [data,nnv,freq]=read_vel(fname);
%
%             If READ_VEL cannot locate the file, it exits, returning 
%             a -1 instead of the data matrix.
%
%   NOTES :   The .vel filetype contains 3-D data; i.e., complex-valued
%             velocity data at each vertical node per horizontal node.
%             The .vel file has phase in radians while the related .v3c 
%             format has phase in degrees.
%
% Call as: [data,nnv,freq,gridname]=read_vel(fname);
%
% Written by : Brian O. Blanton
%
if nargin==0 & nargout==0
   disp('Call as:  [data,nnv,freq,gridname]=read_vel(fname);')
   return
end


if ~exist('fname')
   [fname,fpath]=uigetfile('*.vel','Which .vel');
   if fname==0,return,end
else
   fpath=[];
end

if nargin > 1
   error(['READ_VEL requires 0 or 1 input argument; type "help READ_VEL"']);
end

% get filetype from tail of fname
ftype=fname(length(fname)-2:length(fname));

% make sure this is an allowed filetype
if ~strcmp(ftype,'vel')
   error(['READ_VEL cannot read ' ftype ' filetype'])
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

% read number of vertical nodes (line #3) number of frequencies (line #4)
% and the frequency (line #5)
nnv=fscanf(pfid,'%d',1);
nfreq=fscanf(pfid,'%f',1);
freq=fscanf(pfid,'%f',1);

% read data segment 
data=fscanf(pfid,'%d %f %f %f %f %f %f %f',[8 inf])';
fclose(pfid);
%
%        Brian O. Blanton
%        Curr. in Marine Science
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
