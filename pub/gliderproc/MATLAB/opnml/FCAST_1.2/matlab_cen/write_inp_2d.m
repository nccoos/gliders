function write_inp_2d(inpfile,x,y,in,scalar)
%
% Determine required indexes
%
size(x);
nn=ans(1)
size(in);
ne=ans(1)
size(scalar);
nsca=ans(2)
%
% Open and write file
%
fid=fopen(inpfile,'w');
fprintf(fid,'%6.0f %6.0f %1.0f 0 0\n',nn,ne,nsca);
for i=1:nn
   fprintf(fid,'%6.0f %9.4e %9.4e 0.0\n',i,x(i),y(i));
end
for i=1:ne
   fprintf(fid,'%6.0f 1 tri %6.0f %6.0f %6.0f\n',i,in(i,1),in(i,2),in(i,3));
end
fprintf(fid,'%1.0f',nsca);
for i=1:nsca
   fprintf(fid,' %1.0f',1);
end
fprintf(fid,'\n');
for i=1:nsca
   fprintf(fid,'sca%1.0f ,m\n',i);
end
for i=1:nn
   fprintf(fid,'%6.0f ',i);
   for j=1:nsca
      fprintf(fid,'%9.4e ',scalar(i,j));
   end
   fprintf(fid,'\n');
end
return

