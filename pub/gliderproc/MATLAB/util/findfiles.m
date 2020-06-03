function fnames = findfiles(extension,directory)
% Finds all files with the specified extension in the current directory and 
% subdirectories (recursive). Returns a cell array with the fully specified 
% file names.
%
%    files = findfiles( ext )
%       searches in the current directory and subdirectories.
%
%    files = findfiles( ext, directory)
%       starts search in directory specified.
%
% Note: if this function causes your recursion limit to be exceeded, then 
% it is most probably trying to follow a symbolic link to a directory that 
% has a symbolic link back to the directory it came from.
%
% Examples:
% 
%    bmpfiles = findfiles('bmp')
%    dllfiles = findfiles('dll','C:\WinNT')
%    mfiles = findfiles('m',matlabroot)

% Copyright (C) 2001 Quester Tangent Corporation
% Author: Tony Christney, tchristney@questertangent.com
% $Id: findfiles.m 1.2 2001/03/16 21:28:37 tchristney Exp $

% $Log: findfiles.m $
% Revision 1.2  2001/03/16 21:28:37  tchristney
% added some comments for external release, i.e. examples.
%
% Revision 1.1  2001/03/07 22:38:52  tchristney
% Initial revision
%

if nargin == 1
    directory = cd;
elseif nargin >= 2
    oldDir = cd;
    cd(directory);
    directory = cd;
    cd(oldDir);
end

d = dir(directory);

fnames = {};
numMatches = 0;
for i=1:length(d)
    % look for occurences of ['.' extension] in the file name
    extIndices = findstr(['.' extension],d(i).name);
    
    % if the file is not a directory, and the file has at least one occurence
    if ~d(i).isdir & ~isempty(extIndices)
        
        % then if the last occurrence is at the end of the file name,
        % add the file name to the list.
        if length(d(i).name) == (extIndices(length(extIndices)) + length(extension))
            numMatches = numMatches + 1;
            fnames{numMatches} = fullfile(directory,d(i).name);
        end
    % otherwise, descend directories appropriately.
    % note that this could result in a recursion limit error if it tries to 
    % follow symbolic links that loop back on themselves...
    elseif d(i).isdir & ~strcmp(d(i).name,'.') & ~strcmp(d(i).name,'..')
        fnames = [fnames findfiles(extension,fullfile(directory,d(i).name))];
    end
end