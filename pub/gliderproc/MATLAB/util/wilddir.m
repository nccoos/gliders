
	function [files,Dout]=wilddir(datadir,string);

%
% 	WILDDIR.M - creates a list of files padded with trailing blanks
%	(remove with deblank.m or blank.m) of all files in directory DATADIR 
%	ending with STRING
%
%  Catherine R. Edwards
%  Last modified: 2 Aug 2000
%

if nargin==1
  string=datadir;
  datadir=pwd;  
end

D=dir(datadir); N=length(D)-2; 
Dout=D;

files=[]; match=[];
for i=1:N
  file=getfield(D(i+2,1),'name');
  l=length(file); lstr=length(string);
  if(l>=lstr)
    if(strcmp(file(l-lstr+1:l),string))
      files=strvcat(files,file);
      match=[match i+2];
    end
  end
end
Dout=D(match);
