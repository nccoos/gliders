%
% READ_TRN read a .trn file as output from the OPNML transect code
%
% data=read_trn(trnname);         
%
%          If trnname is omitted, READ_TRN enables a file browser
%          with which the user can specify the .trn file.
%
%          Otherwise, READ_TRN takes a input the filename of the 
%          transect data file, including the .trn suffix.
%
%          The columns of the returned data part are:
%             
%              Dist.    Depths    Normal   Parallel   Vert.
%              along      at       Vel.      Vel.     Vel.
%              trans   Stations
%               (X)       (Y)      (Vn)      (Vp)      (W)
%
%          Read the "man" page for TRANSECT (type "man transect" at a UNIX
%          prompt) for the format specifics of a .trn file.
%
%          In order to plot the results of a transect, an element list 
%          corresponding to the number of horizontal and vertical
%          stations must be generated.  This list is output by TRANSECT,
%          either as "trans.ele" or "ftn99".  Alternatively, this list can 
%          be generated within MATLAB
%          with the OPNML/MATLAB routine ELGEN.  The element list can also
%          be generated with the OPNML binary code "elgen".  
%
%          Make sure a semi-colon is used at the end of the command; 
%          otherwise READ_TRN will return the data part to the screen.
%
% Call as: data=read_trn(trnname);
%
function data=read_trn(trnname)

err1=['READ_TRN requires 0 or 1 argument.'];
err2=['Argument to READ_TRN must be a string (filename)'];

if nargin > 1
   error(err1)
end

if ~exist('trnname')
   [trnname,fpath]=uigetfile('*.trn','Which .trn');
   if trnname==0,return,end
else
   if ~isstr(trnname),error(err2),end
   fpath=[];
end

[pfid,message]=fopen([fpath trnname]);
if pfid==-1
   error([fpath trnname,' not found. ',message]);
end

%%%%%%%%%%%%%%  READ HEADER INFO FROM TOP OF .trn FILE %%%%%%%%%%%%%%%
% read grid name from top of .trn file
%
gridname=fscanf(pfid,'%s',1);
gridname=blank(gridname);

% read until '=', then get the filename of the 
% source data used to generate this transect
%
word=[' '];
while word~='='
   word=fscanf(pfid,'%s',1);
end
sourcedata=fscanf(pfid,'%s',1);

% read to the end of the "Transect End-Points" description line
%
trash=fscanf(pfid,'%s',1);
trash=fscanf(pfid,'%s',1);

% read transect end-points
%
trash=fscanf(pfid,'%4s',1);trash=fscanf(pfid,'%2s',1);
X1=fscanf(pfid,'%f',1);
trash=fscanf(pfid,'%4s',1);trash=fscanf(pfid,'%2s',1);
Y1=fscanf(pfid,'%f',1);
trash=fscanf(pfid,'%4s',1);trash=fscanf(pfid,'%2s',1);
X2=fscanf(pfid,'%f',1);
trash=fscanf(pfid,'%4s',1);trash=fscanf(pfid,'%2s',1);
Y2=fscanf(pfid,'%f',1);
endpoints=[X1 Y1 X2 Y2];

% read until '=', then get number of horizontal points in transect 
%
word=[' '];
while word~='='
   word=fscanf(pfid,'%s',1);
end
nhorz=fscanf(pfid,'%f',1);

% read until '=', then get number of vertical points in transect 
%
word=[' '];
while word~='='
   word=fscanf(pfid,'%s',1);
end
nvert=fscanf(pfid,'%f',1);

npts=[nhorz nvert];

data=fscanf(pfid,'%f %f %f %f %f',[5 nhorz*nvert]);
data=data';
fclose(pfid);



