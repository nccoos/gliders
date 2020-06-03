function err=writegrid(fem_grid_struct,fnamebase);
%WRITEGRID write a fem_grid_struct to separate gridfiles (.ele, .nod,...)
%   WRITEGRID writes the standard gridfiles .ele, .bat, .and nod to
%   disk.  It also writes the neighbor list to a file with extension
%   '.icm' if the .icm field of fem_grid_struct is filled.
%
%   WRITEGRID(FEM_GRID_STRUCT) prompts the user for a gridname, and
%   writes the files <gridname>.ele, <gridname>.bat, and <gridname>.nod
%   (and possibly <gridname>.icm).
%
%   WRITEGRID(FEM_GRID_STRUCT,FNAMEBASE) writes the files 
%   <fnamebase>.ele, <fnamebase>.bat, and <fnamebase>.nod
%   (and possibly <gridname>.icm).
% 
%   WRITEGRID returns a 0 if successful and a -1 if not. 
%   

if nargin==0 & nargout==0
   disp('Call as: writegrid(fem_grid_struct,fnamebase)')
   return
end


if nargin~=1 & nargin~=2
   error('WRITEGRID needs 1 or 2 input arguments.')
else
   if nargin==1
      fnamebase=input('Enter a domain name:','s');
   else
      % make sure input fnamebase is a string
      if ~isa(fnamebase,'char')
         disp('FNAMEBASE to WRITEGRID must be a string.');
         err=-1;
         return
      end
   end
end

% Is fem_grid_struct valid?
if ~is_valid_struct(fem_grid_struct)
   error('fem_grid_struct to WRITEGRID not valid.')
end

% Call write functions
disp(['Writing element file ' fnamebase '.ele.'])
if write_ele(fem_grid_struct.e,[fnamebase '.ele'])==-1
   disp(['Error writing element file ' fnamebase '.ele.'])
   err=-1;
   return
end

disp(['Writing node file ' fnamebase '.nod.'])
if write_nod(fem_grid_struct.x,fem_grid_struct.y,[fnamebase '.nod'])==-1
   disp(['Error writing node file ' fnamebase '.nod.'])
   err=-1;
   return
end

disp(['Writing depth file ' fnamebase '.bat.'])
if write_bat(fem_grid_struct.z,[fnamebase '.bat'])==-1
   disp(['Error writing depth file ' fnamebase '.bat.'])
   err=-1;
   return
end

% if there is a neighbor list (.icm) attached to fem_grid_struct, 
% write it to <fnamebase>.icm
if isfield(fem_grid_struct,'icm')
   disp(['Writing neighbor list file ' fnamebase '.icm.'])
   [m,n]=size(fem_grid_struct.icm);
   fmtstr=[];
   mm=max(fem_grid_struct.icm(:));
   mm=length(int2str(mm*10));
   mm=int2str(mm);
   fmtstp=['%' mm 'd'];
   for i=1:n
      fmtstr=[fmtstr fmtstp];
   end
   fmtstr=[fmtstr '\n'];
   fname=[fnamebase '.icm'];
   [fid,mesg]=fopen(fname,'w');
% Check for open error
   if(fid<0)
      errstr=sprintf('Filename %s could not be opened;\n%s\n',fname,mesg);
      disp(errstr);
      err=-1;
      return
   else
      fprintf(fid,fmtstr,fem_grid_struct.icm');
      fclose(fid);
   end
end

% Successful
err=0;

return

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

