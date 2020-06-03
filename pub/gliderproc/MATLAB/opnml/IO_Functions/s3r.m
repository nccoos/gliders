%S3R Dartmouth FEM File Standard Filetype (Description).
%
%       Output format for a 3-D, real-valued (steady-state) scalar field.
%
%       This filetype is read by the OPNML MATLAB function 
%       READ_V2R.  Type "help read_v2r" for more information.
%
%       The .s3r file contains 3 header lines:
%          1) The geometric meshname
%          2) User-defined file description line
%          3) NNV - number of vertical nodes
%
%       Then, there are NN lines of the form:
%             I  Z(I,J) S(I,J)  
%
%       where:  Z(I,J)  - vertical co-ordinate at node (I,J)
%               S(I,J)  - scalar value at node I,J
%               J=1,NNV - the inner loop over 1-D vertical nodes
%               I=1,NN  - the outer loop over 2-D horizontal nodes
%               NN      - the number of horizontal nodes in the mesh
% 
%      See the document "DATA FILE STANDARDS FOR THE GULF OF MAINE PROJECT"
%      for more details. 

