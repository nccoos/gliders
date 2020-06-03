%S2R Dartmouth FEM File Standard Filetype (Description).
%
%       Output format for a 2-D, real-valued (steady-state) scalar field.
%
%       This filetype is read by the OPNML MATLAB function 
%       READ_S2R.  Type "help read_s2r" for more information.
%
%       The .s2r file contains 2 header lines:
%          1) The geometric meshname
%          2) User-defined file description line
%
%       Then, there are NN lines of the form:
%             I  S(I)  
%
%       where:  S(I)    - scalar value at node I 
%               I=1,NN  - the outer loop over 2-D horizontal nodes
%               NN      - the number of horizontal nodes in the mesh
% 
%      See the document "DATA FILE STANDARDS FOR THE GULF OF MAINE PROJECT"
%      for more details. 

