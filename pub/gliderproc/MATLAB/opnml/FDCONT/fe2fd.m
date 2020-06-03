function fd=fe2fd(fe,bfd)
%FE2FD - interpolate FE data to FD nodes contained in bfd array
%   FE2FD interpolates a 2-D FEM scalar field onto the FD nodes 
%   contained in a bfd array.
%
%   Input:  fe  -  column vector of FEM scalar data
%           bfd -  basis function data array 
%
%           FDCONTOUR takes care to pass in only the 
%           node numbers and basis functions to FE2FD.  
%           Other calls to this function must be careful
%           to pass in only columns 4:9 of the bfd array;
%           i.e., fe2fd(q,bfd(:,4:9))
%
%   Output: fd  -  FD-based interpolated data
%
%   Written by:
%   Christopher E. Naimie
%   Dartmouth College
%   christopher.e.naimie@dartmouth.edu
%-----------------------------------------------------------------------
fd=fe(bfd(:,1)).*bfd(:,4)+fe(bfd(:,2)).*bfd(:,5)+fe(bfd(:,3)).*bfd(:,6);
