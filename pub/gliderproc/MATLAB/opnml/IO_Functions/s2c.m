%S2C Dartmouth FEM File Standard Filetype (Description).
%
%       Output format for a 2-D, complex-valued (periodic) scalar field.
%
%       This filetype is read by the OPNML MATLAB function 
%       READ_V2R.  Type "help read_v2r" for more information.
%
%       The .s2c file contains 3 header lines:
%          1) The geometric meshname
%          2) User-defined file description line
%          3) Frequency (radians/sec)
%
%       Then, there are NN lines of the form:
%             I  Samp(I)  Spha(I)  
%
%       where:  Samp(I)    - scalar amplitude at node I 
%               Spha(I)    - scalar phase at node I  (degrees)
%               I=1,NN     - the outer loop over 2-D horizontal nodes
%               NN         - the number of horizontal nodes in the mesh
% 
%      See the document "DATA FILE STANDARDS FOR THE GULF OF MAINE PROJECT"
%      for more details. 

