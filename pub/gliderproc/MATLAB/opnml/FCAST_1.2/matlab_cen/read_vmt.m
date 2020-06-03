%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read a .vmt file and load data arrays
%% function [z,u,v,sigt,t,s,q2,q2l,enzm,enzh,enzq,nn,nnv,gridname,header]=read_vmt(fname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [z,u,v,sigt,t,s,q2,q2l,enzm,enzh,enzq,nn,nnv,gridname,header]=read_vmt(fname)
ncol=13;
if nargin == 0
   !ls *.vmt
   fname=input('Enter the name of the .vmt file: ','s');
end
[pfid,message]=fopen([fname]);
datatype=fname(length(fname)-2:length(fname));
gridname=fgets(pfid);
gridname=gridname(1:length(gridname)-1);
header=fgets(pfid);
nnv=fscanf(pfid,'%f',1);
data=fscanf(pfid,'%f',[1 inf])';
fclose(pfid);
size(data);
nn=ans(1)/nnv/ncol;
string=[num2str(nn),'x',num2str(nnv),' ',datatype,' values read from ',fname];
fprintf(1,string); fprintf(1,'\n');
data=reshape(data,[ncol nn*nnv])';
z=data(:,2);
u=data(:,3);v=data(:,4);w=data(:,5);
sigt=data(:,6);t=data(:,7);s=data(:,8);
q2=data(:,9);q2l=data(:,10);
enzm=data(:,11);enzh=data(:,12);enzq=data(:,13);
