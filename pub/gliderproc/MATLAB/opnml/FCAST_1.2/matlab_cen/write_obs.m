%
% WRITE_OBS write standard observation files. 
% the standards are m2d,o2d,m3d,o3d 
%
% Call as: a = write_obs(fname,fmt,data,gridname,year,ncol,gmt);
%
% 	   Input:
%		  fname  - path/name of the file
%                 fmt  - format string for writing the output
%                        e.g.  fmt = ' %f %f %g %g\n' ; 
%                        it should have ncol entries
%                 data   - array of column data 
%                 year   - the year of the data; 
%                 ncol  - number of columns used;
%                 gmt    - the gmt string from the data file (not yet)
%
% Written by: Charles G. Hannah  Sept 1997. 
%
function a = write_obs(fname,fmt,data,gridname,year,ncol,gmt);


% open fname
fpath=[];
[pfid,message]=fopen([fpath fname],'w');
if pfid==-1
   error([fpath fname,' not allowed to open and write. ',message]);
end

fprintf(pfid,'XXXX\n');
gridname=blank(gridname);
fprintf(pfid,'%s',gridname);
fprintf(pfid,'\nheader line\n');

 fprintf(pfid,'%d\n',year);
 fprintf(pfid,'%d\n',ncol);
%
 aa = size(data);
 if(ncol~=aa(2))
   disp('ncol sent does not agree with size of data array');
 end
%
%% write data to file  
% fmt
 fprintf(pfid,fmt,data');
 fclose(pfid);
 return
 
