function err=write_bat(z,fname)
%WRITE_BAT Write a bathymetry list to disk in .bat format.
%   WRITE_BAT writes an element list to a file, in the .bat
%   format as specified in the Dartmouth/Thayer School/NML
%   File Standards for the Gulf of Maine projects.
%
%   WRITE_BAT(Z,FNAME) opens a file named FNAME in "write" mode and
%   writes the 1-column bathymetry list Z to the filename in FNAME,
%   including the node counter as  the first column of the output 
%   file. The user should include the .bat file extension in the 
%   filename string FNAME.  Both arguments are REQUIRED.
%
%   WRITE_BAT returns a 0 if successful and a -1 if not.
% 

if nargin==0 & nargout==0
   disp('Call as: write_bat(z,fname)')
   return
end


if nargin~=2,error('WRITE_BAT requires 2 input arguments.'),end

[fid,mesg]=fopen(fname,'w');
% Check for open error
if(fid<0)
   errstr=sprintf('Filename %s could not be opened;\n%s\n',fname,mesg);
   disp(errstr);
   err=-1
else
   i=1:length(z);
   out=[i(:) z(:)];
   fprintf(fid,'%d %f\n',out');
   fclose(fid);
   err=0;
end


%
%        Brian O. Blanton
%        Department of Marine Sciences
%        Ocean Processes Numerical Modeling Laboratory
%        12-7 Venable Hall
%        CB# 3300
%        University of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%        Summer  1998
%
