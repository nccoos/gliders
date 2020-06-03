function ret_struct=read_icq4(filename)
%READ_ICQ4 read a QUODDY4 .icq4 file
%   READ_ICQ4 reads in and parses the Quoddy 4 model 
%   results contained in an .icq4 output file.
% 
%   The contents of the .icq4 file are returned to the 
%   MATLAB workspace as a structure contaioning fields 
%   for each variable.  Type "help fem_icq4_struct" 
%   for a description of the icq4 structure.
%
% Input:   If icq4name is omitted, READ_ICQ4 enables a 
%          file browser with which the user can specify 
%          the .icq4 file.
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
%   
% Written by: Brian Blanton and Charles Flagg (Dec 1998)
%

err1=['READ_ICQ4 requires 0 or 1 input arguments.'];
err2=['READ_ICQ4 requires exactly 1 output arguments.'];
err3=['Argument to READ_ICQ4 must be a string (filename)'];


if nargin > 1
   error(err1)
end

if nargout ~=1
   error(err2)
end

if ~exist('filename')
   [fname,fpath]=uigetfile('*.icq4','Which .icq4');
   filename=[fpath '/' fname];
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
initcondname=fgets(pfid);
initcondname=blank(initcondname);

ret_struct.codename=codename;
ret_struct.casename=casename;
ret_struct.inqfilename=inqfilename;
ret_struct.initcondname=initcondname;

% Read in the model dimensions
temp = fscanf(pfid,'%d %d',2)';
nn= temp(1);
nnv = temp(2);

ret_struct.nn=nn;
ret_struct.nnv=nnv;

% Read in the model date, time, and time step
datain = fscanf(pfid,'%d %d %d %f %f',5);
day = datain(1); month = datain(2); year = datain(3);
curr_seconds = datain(4); step_seconds = datain(5); 
ret_struct.day=day;
ret_struct.month=month;
ret_struct.year=year;
ret_struct.curr_seconds=curr_seconds;
fclose(pfid);

% Do the actual data read in c-mex file.
[HMID, UMID, VMID, HOLD, UOLD, VOLD,...
 ZMID,  ZOLD, UZMID ,VZMID, WZMID, ...
 Q2MID, Q2LMID, TMPMID, SALMID]=read_icq4_mex5(filename,nn,nnv); 


% Reshape vectors into nn X nnv arrays
ret_struct.ZMID = reshape(ZMID,nn,nnv); 
ret_struct.ZOLD = reshape(ZOLD,nn,nnv); 
ret_struct.UZMID = reshape(UZMID,nn,nnv);
ret_struct.VZMID = reshape(VZMID,nn,nnv); 
ret_struct.WZMID = reshape(WZMID,nn,nnv); 
ret_struct.Q2MID = reshape(Q2MID,nn,nnv); 
ret_struct.Q2LMID = reshape(Q2LMID,nn,nnv); 
ret_struct.TMPMID = reshape(TMPMID,nn,nnv); 
ret_struct.SALMID = reshape(SALMID,nn,nnv);


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


