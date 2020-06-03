function [inbe,gridname]=read_bel(fname)
%READ_BEL read a FEM domain .bel file 
% READ_BEL reads a FEM domain .bel file (boundary element
% description file) and returns the boundary list.  See the 
% "Dartmouth File Standards" document for details on the .bel
% file structure/contents.
%
% With no input arguments, READ_BEL enables a file browser with 
% which the user can select a .bel file.  
%
% Input:  belname - .bel filename 
%
% Output: inbe    - boundary element list matrix
%         gridname - FEM domain name found in .bel file
%
% Call as: [inbe,gridname]=read_bel(fname)
%
% Written by: Chris E. Naimie
% Modified by: Brian O. Blanton to more general useage. (Jan 99)

nargchk(0,1,nargin);

if ~exist('fname')
   [fname,fpath]=uigetfile('*.bel','Which file?');
   if fname==0,return,end
else
   fpath=[];
end


% Open and read .bel file
[pfid,message]=fopen(fname);
if pfid==-1
   error([fpath fname,' not found. ',message]);
end

%  read grid name from top of file
gridname=fgetl(pfid);
gridname=blank(gridname);

%  read header 
header=fgets(pfid);

%  read incidence list
inbe=fscanf(pfid,'%f',[5 inf])';
fclose(pfid);
