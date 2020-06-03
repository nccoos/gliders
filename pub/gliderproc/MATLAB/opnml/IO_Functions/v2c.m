%V2C Dartmouth FEM File Standard Filetype (Description).
%
%       Output format for a 2-D, complex-valued (periodic) vector field.
%
%       This filetype is read by the OPNML MATLAB function 
%       read_v2c.  Type "help read_v2c" for more information.
%
%       The .v2c file contains 3 header lines:
%          1) The geometric meshname
%          2) User-defined file description line
%          3) Frequency (radians/sec)
%
%       Then, there are NN lines of the form:
%             I  Uamp(I) Upha(I) Vamp(I) Vpha(I) 
%
%       where:  Uamp(I) - x-component amplitude of velocity
%               Upha(I) - x-component phase of velocity  (degrees)
%               Vamp(I) - y-component amplitude of velocity
%               Vpha(I) - y-component phase of velocity  (degrees)
%               I=1,NN  - the outer loop over 2-D horizontal nodes
%               NN - the number of horizontal nodes in the mesh
% 
%      See the document "DATA FILE STANDARDS FOR THE GULF OF MAINE PROJECT"
%      for more details. 

