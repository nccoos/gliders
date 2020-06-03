
	function [matchfiles,nomatchfiles]=wilddirc(datadir,string);

%
% 	WILDDIRC.M - creates a cell of files 
%	of all files in directory DATADIR containing STRING
%
%  Catherine R. Edwards
%  Last modified: 3 Apr 2006
%

if nargin==1
  string=datadir;
  datadir=pwd;  
end

if(~exist(datadir,'dir')); error([datadir,' is not a directory']); end

D=dirc(datadir,'f'); N=length(D);

matches=[];
for i=1:N
  file=char(D(i,1));
  matches(i)=~isempty(strfind(file,string));
end

matches=find(matches);

if(sum(matches)==0);
  matchfiles=[];nomatchfiles=D(:,1);
else; matchfiles=D(matches,1); nomatchfiles=setdiff(D(:,1),matchfiles);
end
