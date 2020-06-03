% function [z,sigt,t,s,nn,nnv,mesh,header]=read_s3r3(file)
function [z,sigt,t,s,nn,nnv,mesh,header]=read_s3r3(file)
[pfid,message]=fopen([file]);
datatype=file(length(file)-3:length(file));
mesh=fgets(pfid);mesh=blank(mesh(1:length(mesh)-1));
header=fgets(pfid);
nnv=fscanf(pfid,'%f',1);
data=fscanf(pfid,'%f',[1 inf])';
fclose(pfid);
size(data);
nn=ans(1)/nnv/5;
string=[num2str(nn),'x',num2str(nnv),' ',datatype,' values read from ',file];
fprintf(1,string); fprintf(1,'\n');
data=reshape(data,[5 nn*nnv])';
z=data(:,2);sigt=data(:,3);t=data(:,4);s=data(:,5);
