function [x,y,ic,z,nbs]=read_nei(fname);
%READ_NEI read a FEM neighbor file of .nei filetype.
%
% [x,y,bc,z,nbs]=read_nei(fname);
%
%   Input :   If fname is omitted, READ_NEI enables a file browser
%             with which the user can specify the .NEI file.
%
%             Otherwise, fname is the name of the .nei file, relative 
%             or absolute (fullpath), including the suffix .'nei'.
%             This input is a string so it must be enclosed in
%             single quotes. 
%
%  Output :   Five (5) arrays are returned to the local workspace:
%             1) x - x-coordinates of the grid
%             2) y - y-coordinates of the grid
%             3) bc - boundary codes for each horizontal node
%             4) z - bathymetry of the grid
%             5) nbs - neighbor list of grid's nodes
%
% Call as: [x,y,bc,z,nbs]=read_nei(fname);
%
% Written by Brian Blanton 
% January 1996
%

if nargin==0&nargout==0
   disp('Call as: [x,y,bc,z,nbs]=read_nei(fname);')
   return
end

   
if ~exist('fname')
   [fname,fpath]=uigetfile('*.nei','Which .nei');
   if fname==0,return,end
else
   fpath=[];
end

if nargin > 1
   error(['READ_NEI requires 0 or 1 input argument; type "help READ_NEI"']);
elseif nargout ~=5
   error(['READ_NEI requires 5 output arguments; type "help READ_NEI"']);
end

% get filetype from tail of fname
ftype=fname(length(fname)-2:length(fname));

% make sure this is an allowed filetype
if ~strcmp(ftype,'nei')
   error(['READ_NEI cannot read ' ftype ' filetype'])
end

% open fname
[pfid,message]=fopen([fpath fname]);
if pfid==-1
   error([fpath fname,' not found. ',message]);
end

nnd=fscanf(pfid,'%d',1);
nnb=fscanf(pfid,'%d',1);
maxmin=fscanf(pfid,'%f %f %f %f',4);

fmt1='%d %f %f %d %f ';
fmt2='%d ';
for i=2:nnb
   fmt2=[fmt2 '%d '];
end
fmtstr=[fmt1 fmt2];
nread=nnb+5;
data=fscanf(pfid,eval('fmtstr'),[nread nnd])';
x=data(:,2);
y=data(:,3);
ic=data(:,4);
z=data(:,5);
nbs=data(:,6:nread);

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

