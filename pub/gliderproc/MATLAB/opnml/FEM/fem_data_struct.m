%FEM_DATA_STRUCT - FEM data description structure
% FEM_DATA_STRUCT is a structure containing the 
% components that make up a finite element data file. 
% This data structure is returned/accepted by all
% OPNML/MATLAB I/O routines that the standard 
% filetypes (.src, .s2r, ...).  
%
% The struct array FEM_DATA_STRUCT contains the following fields:
%   INFO LINES
%       .fname - filename prefix of FEM data file     [char array]
%       .fext  - filename suffix of FEM data file     [char array]
%       .fpath - directory file is read from          [char array]
%       .gname - gridname for FEM data file           [char array]
%       .h1    - file header line records             [char array]
%       .h2    - file header line records             [char array]
%       .h3    - file header line records             [char array]
%   DATA BLOCK
%       .ndim  - number of dimensions of data         [double array]
%       .type1 - scalar|vector flag                   [char array]
%       .type2 - real/complex flag                    [char array]
%       .type3 - real-imag(ri) | amp-phase(ap)        [char array]
%       .freq  - frequency for complex data           [double array]
%       .n     - number of 2-D points                 [double array] 
%       .nnv   - number of 3-D levels                 [double array] 
%       .data1 - dim 1 data (n*nnv  X {1|2})          [double array] 
%       .data2 - dim 2 data (n*nnv  X {1|2})          [double array] 
%       .data3 - dim 3 data (n*nnv  X {1|2})          [double array] 
% 
% (FEM_DATA_STRUCT is NOT a function; this is just the description 
%  file for the structure.)

%
%        Brian O. Blanton
%        Department of Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        University of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%        Fall 1998
