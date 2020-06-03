function MakeContents(aString)

%MAKECONTENTS  makes Contents file in current working directory.
%   MAKECONTENTS(STRING) creates a standard "Contents.m" file in the
%   current directory by assembling the first comment (H1) line in
%   each function found in the current working directory.  If a 
%   "Contents.m" file exists, it is renamed to "Contents.old", before
%   a new "Contents.m" file is created.  STRING is inserted as the 
%   first line of the "Contents.m" file;  if omitted, a blank line 
%   is inserted instead.  The function changes permission on the 
%   resultant "Contents.m" file to rw-r--r-- on Unix systems.
%
% Updated 29 June 2000.
%
% See also CONTENTS.


% Author(s): L. Bertuccioli 
%            A. Prasad

% Based on mkcontents.m by Denis Gilbert


% Default value of input string
if nargin < 1,
     aString =' ';
end

disp(['Creating "Contents.m" in ' pwd])
if exist([pwd filesep 'Contents.m']) ~= 0 
     copyfile('Contents.m','Contents.old');
     delete Contents.m  
end

% Header lines
line1 = ['% ' aString];
line2 = ['% Path ->  ' pwd];

% Structure with fields files.m, files.mat, etc.
files = what;  
% Note: the field files.m does not include contents.m (IMPORTANT)
% Do not displace this line of code above or below its present location
% to avoid error messages.

if length(files.m)==0
     warning('No m-files found in this directory')
     return
end

fcontents = fopen('Contents.m','w'); 
fprintf(fcontents,'%s\n',line1);     
fprintf(fcontents,'%s\n',line2);     
fprintf(fcontents,'%% \n');

% Write first lines to Contents.m if they exist
for i = 1:length(files.m)
   fid=fopen(files.m{i},'r'); 
   aLine = fgetl(fid);
   if (strcmp(aLine(1:8),'function') == 1),
	count_percent = 0;
	while count_percent < 1 & feof(fid)==0; 
	     line = fgetl(fid);
	     if length(line) > 0 
		  if ~isempty(findstr(line,'%')) 
		       count_percent = count_percent + 1;
		       [tt,rr]=strtok(line(2:length(line)));
		       rr = fliplr(deblank(fliplr(rr)));
		       fn = strtok(char(files.m(i)),'.');
		       n = size(char(files.m),2) - length(fn) - 1;
		       line = ['%   ' fn blanks(n) '- ' rr];
		       fprintf(fcontents,'%s\n',line);
		  end % if ~isempty
	     end % if length
	     if feof(fid)==1  
		  fn = strtok(char(files.m(i)),'.');
		  n = size(char(files.m),2) - length(fn) - 1;
		  line = ['%   ' fn blanks(n) '- (No help available)'];
		  fprintf(fcontents,'%s\n',line); 
	     end % if feof
	end % while
   end % if strcmp
   fclose(fid);
end

fclose(fcontents);

% Change permissions on Contents.m file
% only valid for Unix systems, no effect in Win32 systems
!chmod go+r Contents.m
