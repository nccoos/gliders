function wid=get_fig_id(fign)
%GET_FIG_ID - get the Window Manager's Resource ID for a given figure
% GET_FIG_ID is a function which returns the Window Manager's 
% Resource ID for the figure number passed to it.  This ID
% is the HEXIDECIMAL identification number assigned to the
% figure window by the window manager, NOT MATLAB. 
% It is the same number that the X command xwininfo returns
% as part of its output.  
%
% Call as: wid=get_fig_id(fign);
%
% Calls: none
%
% Within the animation loop, use the following to get the
% frame into an image file:
%   ecom =['!import -border 0 -window ' wid 'image??.gif'];
%   eval(ecom)
%

if nargin~=1
   disp('Must have 1 input argument to GET_FIG_ID');
   return
end

if ~isfig(fign)
   disp('Input figure number is NOT a current figure number');
   return
end

%
win_name=get(fign,'Name');
numtitle=get(fign,'NumberTitle');

% set figure name to "Temp Fig Name", for X-resource purposes.
set(fign,'NumberTitle','off')
set(fign,'Name',deblank('TempFigName'))
drawnow

evalcom= ['!xwininfo -name ''TempFigName '' > /tmp/win.dat'];
eval(evalcom)

set(fign,'NumberTitle',numtitle)
set(fign,'Name',win_name)


% Read /tmp/win.dat to retrieve the Resource Manager's HEX ID 
% for the passed figure number

fid=fopen('/tmp/win.dat','r');
line=fgets(fid);
line=fgets(fid);
fclose(fid);

%parse line to get hex window id
colons=findstr(line,':');
subline=line(colons(2)+2:length(line));
spaces=findstr(line,' ');
wid=subline(1:spaces(1));

disp(['Current Fig ID = ' wid])

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
%        Spring  1995
%
