function errno=write_nei(x,y,bc,z,nbs,fname)
%WRITE_NEI Write a FEM neighbor file in .nei format.
%   WRITE_NEI requires 5 input arguments, with 1 optional argument:
%      1) x   - x-coordinates of the grid (REQ)		  
%      2) y   - y-coordinates of the grid (REQ)		  
%      3) bc  - boundary codes for each horizontal node (REQ)
%      4) z   - bathymetry of the grid (REQ)		  
%      5) nbs - neighbor list of grid's nodes (REQ)
%      6) fname - output filename (OPT)			  
%
%   If fname is omitted, WRITE_NEI enables a file browser
%   with which the user can specify the .NEI file.
%   Otherwise, fname is the name of the .nei file, relative 
%   or absolute (fullpath), including the suffix .'nei'.
%   This input is a string so it must be enclosed in
%   single quotes. 
%
%   WRITE_NEI checks the lengths of input arrays and the
%   structure of the neighbor list for some minimal
%   error checking.  This is not, however, very rigorous.
%
% CALL: err=write_nei(x,y,bc,z,nbs,fname);
%          err=write_nei(x,y,bc,z,nbs);
%
% Written by : Brian O. Blanton 
%              March 1996
%

if nargin==0 & nargout==0
   disp('Call as:  err=write_nei(x,y,bc,z,nbs,fname);')
   return
end


if nargout > 1
   error(['WRITE_NEI requires 0 or 1 output argument; type "help WRITE_NEI"']);
end

if nargin < 5 & nargin > 6
   error(['WRITE_NEI requires 5 or 6 input arguments; type "help WRITE_NEI"']);
end

if ~exist('fname')
   [fname,fpath]=uigetfile('*.nei','Which .nei');
   if fname==0,return,end
else
   fpath=[];
end

% get filetype from tail of fname
ftype=fname(length(fname)-2:length(fname));

% make sure this is an allowed filetype
if ~strcmp(ftype,'nei')
   error(['WRITE_NEI cannot write ' ftype ' filetype'])
end

% open fname
[pfid,message]=fopen([fpath fname],'w');
if pfid==-1
   error([fpath fname,' not found. ',message]);
end

fprintf(pfid,'%d\n',length(x));
[nn,nnb]=size(nbs);
fprintf(pfid,'%d\n',nnb);

xmin=min(x);xmax=max(x);
ymin=min(y);ymax=max(y);
maxmin=fprintf(pfid,'%.3f   %.3f   %.3f   %.3f\n',[xmax ymax xmin ymin]);

fmt1='%5d %14.6f %14.6f %1d %8.3f ';
fmt2='%5d ';
for i=2:nnb
   fmt2=[fmt2 '%5d '];
end
fmtstr=[fmt1 fmt2 '\n'];
nwrite=nnb+5;
nnn=1:nn;
fprintf(pfid,eval('fmtstr'),[nnn(:) x(:) y(:) bc(:) z(:) nbs]');

err=0;
return

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

