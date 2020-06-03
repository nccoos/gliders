function opnmldoc(topic)
%OPNMLDOC Display OPNML/MATLAB5 HTML documentation in Web browser.
%
%   OPNMLDOC, by itself, launches the Help Desk.
%
%   OPNMLDOC FUNCTION displays the HTML documentation for the MATLAB
%   function FUNCTION. If FUNCTION is overloaded, doc 
%   lists the overloaded functions in the MATLAB command
%   window.
%%
%   Examples:
%      opnmldoc lcontour
%   This is an OPNML hack of the MATLAB/doc command.

%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.33 $  $Date: 1997/11/21 23:31:41 $

% Get root directory of OPNML Help
global OPNML
help_path = [OPNML '/html/'];

% Show error if help docs not found 
if (isempty(help_path))
   error('Help_path in OPNMLDOC not defined.')
end

% Case no topic specified.
if (nargin == 0)
    html_file = fullfile(help_path,'index.html');
    if (exist(html_file) ~= 2)
       error('Could not locate OPNML html pages.');
   end
   display_file(html_file);
   return
end
 
     
topic_file = [topic '.html'];
html_file = fullfile(help_path,topic_file);
display_file(html_file);    
         
function display_file(html_file)
% Construct URL
if (strncmp(computer,'MAC',3))
    html_file = ['file:///' strrep(html_file,filesep,'/')];
end

% Load the correct HTML file into the browser.
stat = web(html_file);
if (stat==2)
    error(['Could not launch Web browser. Please make sure that'  sprintf('\n') ...
    'you have enough free memory to launch the browser.']);
elseif (stat)
    error(['Could not load HTML file into Web browser. Please make sure that'  sprintf('\n') ...
    'you have a Web browser properly installed on your system.']);
end



