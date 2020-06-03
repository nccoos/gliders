%V3R Dartmouth FEM File Standard Filetype (Description).
%
%       Output format for a 3-D, Steady-state, vector field.
%
%       This filetype is read by the OPNML MATLAB function 
%       read_v2c.  Type "help read_v2c" for more information.
%
%       The .v3r file contains 3 header lines:
%          1) The geometric meshname
%          2) User-defined file description line
%          3) NNV, the number of vertical sigme mesh nodes
%             under each horizontal 2-D node.
%
%       Then, there are NN*NNV lines of the form:
%             I  Z(I,J) U(I,J) V(I,J) W(I,J)
%
%       where:  Z(I,J) = vertical coordinate at horizontal node I,
%                        vertical node J (MKS)
%		(U,V,W) = (x,y,z) vector amplitudes of the 3-D
%		          velocity at node (I,J)
%               J=1,NNV - the inner loop over 1-D vertical nodes
%               I=1,NN  - the outer loop over 2-D horizontal nodes
%               NN = the number of horizontal nodes in the mesh
% 
%      See the document "DATA FILE STANDARDS FOR THE GULF OF MAINE PROJECT"
%      for more details. 

