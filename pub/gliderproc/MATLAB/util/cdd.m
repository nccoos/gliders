function WorkingDirectory = cdd(dirname)
% CDD    Change directories using the wildcard *
%   Change directories using * as a wildcard in the search 
%   directory string name.  The wildcard (*) may be placed either
%   at the beginning or end of the search string.  Only a 
%   single wildcard (*) is allowed.
%
%   CDD .. moves to the parent directory of the current one.
%   CDD, by itself, displays the current working directory.
%
%   WD = CDD returns the current directory in the string WD.
%
%   The functional form of CDD, such as CDD('DirectoryWildcard'),
%   may be used when the target directory specification is 
%   stored in the string DirectoryWildcard.
%
%   For example, to change to directory TargetDirectory,
%
%       CDD Tar*  or  CDD *dire  or  CDD *tory 
%
%   CDD is case sensitive, but insensitive to the occurrence of 
%   spaces in the name of the target directory so that 
%
%       CDD Pro*  or  CDD *File
%
%   changes to the directory "Program Files".
%
%   Created by A. Prasad
%   Updated 8 May 1999
%
%   See also CD, PWD

if nargin < 1
   if nargout < 1
      disp(' ');
      disp(pwd);
      disp(' ');
   elseif nargout == 1
      WorkingDirectory = pwd;
    else
      disp('???  Error using ==> cdd');
      disp('Incorrect number of arguments.');
      disp('  ');
   end
   break
end	

if strcmp(dirname,'..') == 1,
     cd('..');
     break
elseif strcmp(dirname,'.') == 1,
     break
end

LengthDirName = length(dirname);

% Find asterisk character and quit if more than single wildcard
asterisk = find(dirname=='*');
if length(asterisk) > 1,
     disp('???  Error using ==> cdd');
     disp('Too many wildcards.');
     disp('  ');
     break
elseif isempty(asterisk) == 1 
     disp('???  Error using ==> cdd');
     disp('Invalid wildcard.');
     disp('  ');
     break
else
     if asterisk == length(dirname),
	  SrchDirName = dirname(1:(LengthDirName-1));
	  CurrentDir = dir;
	  FindTargetDir = 0;
	  for i=1:length(CurrentDir),
	       dirflag = {CurrentDir.isdir};
	       if dirflag{i} == 1,
		    SubDirList = {CurrentDir.name};
		    FindTargetDir = strncmp(SubDirList{i},SrchDirName,(LengthDirName-1));
		    if FindTargetDir == 1
			 TargetDirName = SubDirList{i};
			 cd(TargetDirName);
			 CurrentDirectory = pwd
			 break
		    end
	       end
	  end
	  if FindTargetDir == 0,
	       disp('??? Error using ==> cdd');
	       disp('Target directory not found.');
	       disp('  ');
	  end
     elseif asterisk == 1,
	  SrchDirName = dirname(2:LengthDirName);
	  CurrentDir = dir;
	  FindTargetDir = [];
	  for i=1:length(CurrentDir),
	       dirflag = {CurrentDir.isdir};
	       if dirflag{i} == 1,
		    SubDirList = {CurrentDir.name};
		    FindTargetDir = findstr(lower(SubDirList{i}),lower(SrchDirName));
		    if isempty(FindTargetDir) ~= 1
			 TargetDirName = SubDirList{i};
			 cd(TargetDirName);
			 CurrentDirectory = pwd
			 break
		    end
	       end
	  end
	  if isempty(FindTargetDir) == 1,
	       disp('??? Error using ==> cdd');
	       disp('Target directory not found.');
	       disp('  ');
	  end
     else
	  disp('??? Error using ==> cdd');
	  disp('Invalid wildcard.');
	  disp('  ');
     end
end

