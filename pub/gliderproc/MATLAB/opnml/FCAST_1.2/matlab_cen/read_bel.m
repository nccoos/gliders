% [x,y,inbe,gridname]=read_bel(fname)
%
function [x,y,inbe,gridname]=read_bel(fname)
%
%Uses GUI interface is no parameter fame is not sent
if ~exist('fname')
   [fname,fpath]=uigetfile('*.???','Which file?');
   if fname==0,return,end
else
   fpath=[];
end
%
% Open and read .bel file
[pfid,message]=fopen(fname);
if pfid==-1
   error([fpath fname,' not found. ',message]);
end
%  read grid name from top of file
gridname=fgetl(pfid);
gridname=blank(gridname);
%gridname
%  read header 
header=fgets(pfid);
%header
%  read incidence list
inbe=fscanf(pfid,'%f',[5 inf])';
fclose(pfid);
%
% Open and read associated .nod file
%
nodes=get_nodes(gridname);x=nodes(:,1);y=nodes(:,2);
return
