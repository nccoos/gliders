ls *.s2c
filename=input('Enter the name of .s2c file: ','s');
[s2c,freq,gridname]=read_v2r(filename);
gridname=blank(gridname(1:length(gridname)-1));
amp=s2c(:,2);
pha=s2c(:,3);
%
%
%
filehead=blank(filename(1:length(filename)-3));
file1=[filehead,'amp.s2r']
fid1=fopen(file1,'w');
fprintf(fid1,'adrdep2kmg\n');
fprintf(fid1,'adrdep2kmg\n');
size(amp);
nn=ans(1);
for i=1:nn
   fprintf(fid1,'%10.0f %14.6e  \n',i,100.0*amp(i));
end
fclose(fid1);
%
%
%
filehead=blank(filename(1:length(filename)-3));
file1=[filehead,'pha.s2r']
fid1=fopen(file1,'w');
fprintf(fid1,'adrdep2kmg\n');
fprintf(fid1,'adrdep2kmg\n');
size(pha);
nn=ans(1);
for i=1:nn
   fprintf(fid1,'%10.0f %14.6e  \n',i,pha(i));
end
fclose(fid1);
