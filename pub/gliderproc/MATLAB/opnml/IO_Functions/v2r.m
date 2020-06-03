%V2R Dartmouth FEM File Standard Filetype (Description).
%
%       Output format for a 2-D, real-valued (steady-state) vector field.
%
%       This filetype is read by the OPNML MATLAB function 
%       READ_V2R.  Type "help read_v2r" for more information.
%
%       The .v2r file contains 2 header lines:
%          1) The geometric meshname
%          2) User-defined file description line
%
%       Then, there are NN lines of the form:
%             I  U(I)  V(I)  
%
%       where:  U(I) - x-component of velocity 
%               V(I) - y-component of velocity 
%               I=1,NN  - the loop over 2-D horizontal nodes
%               NN - the number of horizontal nodes in the mesh
% 
%      See the document "DATA FILE STANDARDS FOR THE GULF OF MAINE PROJECT"
%      for more details. 

