function out=isdir(str)
%ISDIR	Test to see if a directory exists
%	isdir <directoryname> returns 1 if
%	the directory exists, 0 otherwise.
%	Specify either the absolute path
%	or path relative to the current dir.

%dt 10/27/94

a=pwd;
out = 1;
eval(['cd ',str],'out=0;');
cd(a)
