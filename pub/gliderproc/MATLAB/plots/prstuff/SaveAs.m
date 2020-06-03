function SaveAs()
%
% Abstract:
%    User interface to save current figure template as an m-file function.
%
% Usage:
%    >> SaveAs
% 

% 
% History:
%    o 15 August 1995 created function SaveAs as part of Prmenu,
%          by Sara Haines.
%

[filename, currentpath] = uiputfile('*.m', 'Save Template As', 100, 100);
SaveTemplate(currentpath, filename);