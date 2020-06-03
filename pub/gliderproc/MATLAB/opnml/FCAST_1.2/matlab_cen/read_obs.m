%
% READ_OBS read standard observation files. 
% the standards are m2d,o2d,m3d,o3d 
%
% Call as: [data,gridname,year,ncol,gmt]=read_obs(fname);
%  or      [data,gridname,year,ncol,gmt]=read_obs;
%
% 	   Input:
%		  fname  - path/name of .pth file
%          Output:
%                 data   - array of column data 
%                 year   - the year of the data; 
%                 ncol  - number of columns used;
%                 gmt    - the gmt string from the data file (not yet)
%
%          All the data is assumed to be real numbers (not integers).
%
% Written by: Charles G. Hannah  Jan 1997. 
%
function [data,gridname,year,ncol,gmt]=read_obs(fname)

year = [];
gridname = [];
ncol = -1;
gmt = [];

%Uses GUI interface is no parameter fame is not sent
if ~exist('fname')
   [fname,fpath]=uigetfile('*.???','Which file?');
   if fname==0,return,end
else
   fpath=[];
end

% open fname
[pfid,message]=fopen([fpath fname]);
if pfid==-1
   error([fpath fname,' not found. ',message]);
end

% read until 'XXXX' delimiter
test=fscanf(pfid,'%s',1);
while ~strcmp(test,'XXXX')
   [test,count]=fscanf(pfid,'%s',1);
%   if test== [] 
%    if isempty[test] == 1
    if count == 0 
      disp(['String XXXX not found in file ',fname]);
      gridname=0;
      return
   end
end

%clear the end of line left from above 
fline=fgets(pfid);

% read grid name from top of file
gridname=fgets(pfid);
gridname=blank(gridname);
%gridname

% read header 
header=fgets(pfid);
%header

% read year 
year=fscanf(pfid,'%d',1);
%year

% read number of columns 
ncol=fscanf(pfid,'%d',1);
%ncol
% read entire file 
data=fscanf(pfid,'%f',[ncol inf])';
fclose(pfid);
return
