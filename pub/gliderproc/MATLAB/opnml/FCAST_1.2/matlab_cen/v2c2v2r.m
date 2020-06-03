ls *.v2c
filename=input('Enter the name of .v2c file: ','s');
[v2c,freq]=read_v2c(filename);
u=v2c(:,2).*cos(v2c(:,3)*pi/180.0);
v=v2c(:,4).*cos(v2c(:,5)*pi/180.0);
%
%
%
filehead=blank(filename(1:length(filename)-3));
file1=[filehead,'v2r']
fid1=fopen(file1,'w');
fprintf(fid1,'adrdep2kmg\n');
fprintf(fid1,'adrdep2kmg\n');
size(u);
nn=ans(1);
for i=1:nn
   fprintf(fid1,'%10.0f %14.6e  %14.6e \n',i,u(i),v(i));
end
fclose(fid1);
