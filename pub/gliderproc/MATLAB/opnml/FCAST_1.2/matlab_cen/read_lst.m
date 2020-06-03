% function [zl,datal,nn,nl,mesh,header]=read_lst(file)
% zl(1,nl)
% datal(nn,nl)
function [zl,datal,nn,nl,mesh,header]=read_lst(file)
%
if nargin == 0
   file=input('Enter the name of the .lst file: ','s');
end
%
[pfid,message]=fopen([file]);
datatype=file(length(file)-2:length(file));
mesh=fgets(pfid);mesh=blank(mesh(1:length(mesh)-1));
header=fgets(pfid);
nl=fscanf(pfid,'%d1');
zl=fscanf(pfid,'%f',[nl 1])';
datal=fscanf(pfid,'%f',[1 inf])';
size(datal);
nn=ans(1)/nl;
string=[num2str(nn),'x',num2str(nl),' level surface ',datatype,' values read from ',file];
fprintf(1,string); fprintf(1,'\n');
datal=reshape(datal,nl,nn)';
