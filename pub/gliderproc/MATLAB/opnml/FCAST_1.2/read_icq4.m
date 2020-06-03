function ret_struct=read_icq4(filename,flag)
%READ_ICQ4 read a QUODDY4 .icq4 file
%   READ_ICQ4 reads in and parses the Quoddy 4 model 
%   results contained in an .icq4 output file.
% 
%   The contents of the .icq4 file are returned to the 
%   MATLAB workspace as a structure contaioning fields 
%   for each variable.  Type "help fem_icq4_struct" 
%   for a description of the icq4 structure.
%
% Input:   icq4name - .icq4 file to read (optional)
%          flag     -  See below. (optional)
%
%          If icq4name is omitted, READ_ICQ4 enables a 
%          file browser with which the user can specify 
%          the .icq4 file.  The flag (0|1) is used to 
%          only read the header info in the .icq4 file. 
%          flag==0 -> "read only header info"
%          flag==1 -> "read entire .icq4 file"
%
%          Otherwise, READ_ICQ4 takes as input the filename 
%          of the icq4 data file, either relative or
%          absolute, including the .icq4 suffix.
%
% Output:  The output of READ_ICQ4 is a fem_icq4_struct 
%          containing the variables with in the .icq4 file.
%          The output structure can be passed directly to 
%          OPNML routines that take .icq4 structures as 
%          direct input, like VIZICQ4.
%
% Call as: icq4struct=read_icq4(icq4name);         
%      OR: icq4struct=read_icq4(icq4name,flag);         
%   
% Written by: Brian Blanton (Dec 1998)
%

err1=['READ_ICQ4 requires 0,1,2 input arguments.'];
err2=['READ_ICQ4 requires exactly 1 output arguments.'];
err3=['Argument to READ_ICQ4 must be a string (filename)'];

if nargin > 2
   error(err1)
end

% Assume full read of .icq4 file if flag not specified
if nargin==1|nargin==0,flag=1;,end

if nargout ~=1
   error(err2)
end

if ~exist('filename')
   [fname,fpath]=uigetfile('*.icq4','Which .icq4');
   if fname==0,return,end
else
   if ~isstr(filename),error(err3),end
   % break into fpath and fname
   % parse into filename and pathname
   slash_place=findstr(filename,'/');
   if length(slash_place)==0
      fpath=[];
      fname=filename;
   else
      slash_place=slash_place(length(slash_place));
      fpath=filename(1:slash_place-1);
      fname=filename(slash_place+1:length(filename));
   end
end

% get filetype from tail of fname
ftype=fname(length(fname)-3:length(fname));

% make sure this is an allowed filetype
if ~strcmp(ftype,'icq4')
   error(['READ_ICQ4 cannot read ' ftype ' filetype'])
end

% open fname
[pfid,message]=fopen([fpath '/' fname]);
if pfid==-1
   error([fpath '/' fname,' not found. ',message]);
end

% read codename and casename from top of file; header line #1,#2
codename=fgets(pfid);
codename=blank(codename);
casename=fgets(pfid);
casename=blank(casename);
inqfilename=fgets(pfid);
inqfilename=blank(inqfilename);
inqfilename=strrep(inqfilename(12:length(inqfilename)),' ','');

initcondname=fgets(pfid);
initcondname=blank(initcondname);
initcondname=strrep(initcondname(19:length(initcondname)),' ','');

% Read in the model dimensions
temp = fscanf(pfid,'%d %d',2)';
nn= temp(1);
nnv = temp(2);

% Read in the model date, time, and time step
datain = fscanf(pfid,'%d %d %d %f %f',5);
day = datain(1); month = datain(2); year = datain(3);
curr_seconds = datain(4); step_seconds = datain(5); 

% Close input file so that read_icq4_mex5 can re-open if needed.
fclose(pfid);

if flag
   filename=[fpath '/' fname];
   if isempty(fpath),filename=fname;,end
   % Do the actual data read in c-mex file.
   [HMID, UMID, VMID, HOLD, UOLD, VOLD,...
    ZMID,  ZOLD, UZMID ,VZMID, WZMID, ...
    Q2MID, Q2LMID, TMPMID, SALMID]=read_icq4_mex5(filename,nn,nnv);

   % Reshape vectors into nn X nnv arrays
   ZMID   = reshape(ZMID,nn,nnv);
   ZOLD   = reshape(ZOLD,nn,nnv);
   UZMID  = reshape(UZMID,nn,nnv);
   VZMID  = reshape(VZMID,nn,nnv);
   WZMID  = reshape(WZMID,nn,nnv);
   Q2MID  = reshape(Q2MID,nn,nnv);
   Q2LMID = reshape(Q2LMID,nn,nnv);
   TMPMID = reshape(TMPMID,nn,nnv);
   SALMID = reshape(SALMID,nn,nnv);

else
   HMID = [];UMID = [];VMID = [];ZMID = [];
   HOLD = [];UOLD = [];VOLD = [];ZOLD = [];
   UZMID = [];VZMID = [];WZMID = [];Q2MID = [];
   Q2LMID =[];TMPMID =[];SALMID =[];
end

ret_struct=struct('codename',codename,'casename',casename,'inqfilename',inqfilename,...
		  'initcondname',initcondname,'nn',nn,'nnv',nnv,...
		  'day',day,'month',month,'year',year,'curr_seconds',curr_seconds,...
                  'HMID',HMID',...
		  'UMID',UMID',... 
		  'VMID',VMID',... 
		  'HOLD',HOLD',... 
		  'UOLD',UOLD',... 
		  'VOLD',VOLD',... 
                  'ZMID',ZMID,...
                  'ZOLD',ZOLD,...
                  'UZMID', UZMID,...
                  'VZMID', VZMID,...
                  'WZMID', WZMID,...
                  'Q2MID', Q2MID,...
                  'Q2LMID',Q2LMID,...
                  'TMPMID',TMPMID,...
                  'SALMID',SALMID);

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


