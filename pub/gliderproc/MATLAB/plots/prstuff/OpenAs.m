function OpenAs()
%
% Abstract:
%    User interface to open a template figure window.
%    Runs function that is selected
%
% Usage:
%    >> OpenAs
% 

% 
% History:
%    o 15 August 1995 created function OpenAs as part of Prmenu,
%          by Sara Haines.
%

[filename, funcpath] = uigetfile('*.m', 'Open Template', 125, 125);
currentpath = pwd;
eval(['cd ' funcpath]);
[funcname]=strtok(filename,'.');
eval([funcname]);
eval(['cd ' currentpath]);
