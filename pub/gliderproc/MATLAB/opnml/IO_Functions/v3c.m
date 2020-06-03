%V3C Dartmouth FEM File Standard Filetype (Description).
%
%       Output format for a 3-D, complex-valued vector field.
%
%       This filetype is read by the OPNML MATLAB function 
%       READ_V3C.  Type "help read_v3c" for more information.
%
%       The .v3c file contains 4 header lines:
%          1) The geometric meshname
%          2) User-defined file description line
%          3) NNV - number of vertical nodes
%          4) Frequency (radians/sec)
%
%       Then, there are NN lines of the form:
%             I  Z(I,J) Uamp(I,J) Upha(I,J) Vamp(I,J) Vpha(I,J) Wamp(I,J) Wpha(I,J)
%
%       where:  Z(I,J)    - vertical co-ordinate at node (I,J)
%               Uamp(I,J) - amp of x-velocity at node (I,J)
%               Upha(I,J) - phase of x-velocity at node (I,J) (degrees)
%               Vamp(I,J) - amp of y-velocity at node (I,J)
%               Vpha(I,J) - phase of y-velocity at node (I,J) (degrees)
%               Wamp(I,J) - amp of z-velocity at node (I,J)
%               Wpha(I,J) - phase of z-velocity at node (I,J) (degrees)
%               J=1,NNV   - the inner loop over 1-D vertical nodes
%               I=1,NN    - the outer loop over 2-D horizontal nodes
%               NN        - the number of horizontal nodes in the mesh
% 
%      See the document "DATA FILE STANDARDS FOR THE GULF OF MAINE PROJECT"
%      for more details. 

