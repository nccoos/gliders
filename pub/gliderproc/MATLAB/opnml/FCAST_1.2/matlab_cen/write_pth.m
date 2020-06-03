%
% write drogue output .pth file for a single trajectory
%
%
%  write_pth(fname,gridname,ndts,tsec,x,y,z1,z2);
%
% 	   Input:
%		  fname    - path/name of .pth file
%                 gridname - domain name of computation
%                 ndts     - number of time steps in run (or zero)
%                 tsec     - length of run (or timestep) in seconds
%                 pth      - path data part of the .pth file. 
%                 (x,y)    - length of run (or timestep) in seconds
%                 pth      - path data part of the .pth file. 
%
function write_pth(fname,gridname,ndts,tsec,x,y,z1,z2);
fid=fopen(fname,'w');
fprintf(fid,'%c',gridname);
fprintf(fid,'\n RECORD ABOVE THIS LINE IS THE DOMAIN NAME ON WHICH \n');
fprintf(fid,' VELOCITIES WERE COMPUTED.                            \n');
fprintf(fid,' ************** BEGIN .IND FILE ECHO *************    \n');
fprintf(fid,'{Comment:}                                            \n');                                                        
fprintf(fid,'User comment/file description                         \n');                                      
fprintf(fid,'{# of model dts btwn drogue position updates (itrack)}\n');              
fprintf(fid,'1                                                     \n');                                                              
fprintf(fid,'{# of drog updates btwn drogue outputs (iprint)}      \n');                 
fprintf(fid,'1                                                     \n');                                                      
fprintf(fid,'{grid scaling factors in x,y directions (MKS->1.0)}   \n');                 
fprintf(fid,'1.0 1.0 1.0                                           \n');                                                    
fprintf(fid,'{drog coordinate scaling factors}                     \n');                                  
fprintf(fid,'1.0 1.0 1.0                                           \n');                                                     
fprintf(fid,'Number of starting drogues (ndr)                      \n');                                  
fprintf(fid,'1                                                     \n');                                                             
fprintf(fid,'Starting positions, x,y,z for ndr drogues             \n');                         
fprintf(fid,'%f %f %f\n',x(1),y(1),z1(1));
fprintf(fid,' ************** END .IND FILE ECHO ***************    \n');
fprintf(fid,'MODEL TIME-STEP (SECONDS)             : %10.4f\n',tsec);
fprintf(fid,'DROG3DDT  TIME-STEP (SECONDS)         : %10.4f\n',tsec);
fprintf(fid,'DROG3DDT OUTPUT INTERVAL (SECONDS)    : %10.4f\n',tsec);
fprintf(fid,'XXXX\n %i %f %i\n',ndts,tsec,1);
for i=1:length(x)
   fprintf(fid,'%f %f %f %f\n',x(i),y(i),z1(i),z2(i));
end
fclose(fid);
