function err=write_ele(e,fname)
%WRITE_ELE Write an element list to disk in .ele format.
%   WRITE_ELE writes an element list to a file, in the .ele
%   format as specified in the Dartmouth/Thayer School/NML
%   File Standards for the Gulf of Maine projects.
%
%   WRITE_ELE(E,FNAME) opens a file named FNAME in "write" mode and
%   writes the 3-column incidence list E to the filename in FNAME,
%   including the element counter as  the first column of the output 
%   file. The user should include the .ele file extension in the 
%   filename string FNAME.  Both arguments are REQUIRED.
%
%   WRITE_ELE returns a 0 if successful and a -1 if not.
% 

if nargin==0 & nargout==0
   disp('Call as: write_ele(e,fname)')
   return
end

if nargin~=2,error('WRITE_ELE requires 2 input arguments.'),end

[fid,mesg]=fopen(fname,'w');
% Check for open error
if(fid<0)
   errstr=sprintf('Filename %s could not be opened;\n%s\n',fname,mesg);
   disp(errstr);
   err=-1
else
   i=1:length(e);
   out=[i(:) e];
   fprintf(fid,'%d %d %d %d\n',out');
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
