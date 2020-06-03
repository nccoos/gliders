bcsfile='output.s2c'
[s2cfile]=fopen(bcsfile,'w')
fprintf(s2cfile,'adrdep2kmg\n')
fprintf(s2cfile,'new boundary conditions\n')
fprintf(s2cfile,'.1405E-03\n')
for ibc=1:18
   fprintf(s2cfile,'%6.0f %12.4f %12.4f\n',new_bcs(ibc,1),new_bcs(ibc,2),new_bcs(ibc,3))
end
fclose(s2cfile)
