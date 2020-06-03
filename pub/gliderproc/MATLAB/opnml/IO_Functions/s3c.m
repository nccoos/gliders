%S3C Dartmouth FEM File Standard Filetype (Description).
%
%       Output format for a 3-D, complex-valued (periodic) scalar field.
%
%       This filetype is read by the OPNML MATLAB function 
%       READ_S3C.  Type "help read_s3c" for more information.
%
%       The .s3c file contains 4 header lines:
%          1) The geometric meshname
%          2) User-defined file description line
%          3) NNV - number of vertical nodes
%          4) Frequency (radians/sec)
%
%       Then, there are NN lines of the form:
%             I  Z(I,J)   Samp(I,J)   Spha(I,J)  
%
%       where:  Z(I,J)    - vertical co-ordinate at node (I,J)
%               Samp(I,J) - scalar amplitude at node I 
%               Spha(I,J) - scalar phase at node I  (degrees)
%               J=1,NNV   - the inner loop over 1-D vertical nodes
%               I=1,NN    - the outer loop over 2-D horizontal nodes
%               NN        - the number of horizontal nodes in the mesh
% 
%      See the document "DATA FILE STANDARDS FOR THE GULF OF MAINE PROJECT"
%      for more details. 

