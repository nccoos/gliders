
	function [data]=read_lbe(fname);
	
%  Last modified: 23 Sept 1999
%  Catherine R. Edwards
	
if nargin==0 & nargout==0
   disp('Call as: [data]=read_lbe(fname);')
   return
end

if ~exist('fname')
   [fname,fpath]=uigetfile('*.lbe','Which .lbe ?');
   if fname==0,return,end
else
   fpath=[];
end

% get filetype from tail of fname
ftype=fname(length(fname)-2:length(fname));

% make sure this is an allowed filetype
if ~strcmp(ftype,'lbe')
   error(['READ_LBE cannot read ' ftype ' filetype'])
end

% open fname
[pfid,message]=fopen([fpath fname]);
if pfid==-1
   error([fpath fname,' not found. ',message]);
end

% In all filetypes there is always a gridname and description line
% as lines #1 and #2 of the file.
% read grid name from top of file; header line #1
% gridname=fgets(pfid);
% gridname=blank(gridname);

% read data segment 
data=fscanf(pfid,'%d %f %f',[3 inf])';
fclose(pfid);
