% OPNML/MATLAB5 IO-related routines
% Version 3.0
% 24 July, 1998
%
% These are I/O functions for the various Dartmouth File Standards
% datafile definitions, and some others.
%
%READ_BEL      read a FEM domain .bel file 
%READ_FEM_DATA read a FEM output file of standard filetype.
%READ_ICQ4     read a QUODDY4 .icq4 file
%READ_NEI      read a FEM neighbor file of .nei filetype.
%READ_PTH      read drogue .pth file output from DROG3D or DROG3DDT.
%READ_S2C      read a FEM output file of .s2c filetype.
%READ_S2R      read a FEM output file of s2r filetype.
%READ_S3C      read a FEM output file of s3c filetype.
%READ_S3R      read a FEM output file of .s3r filetype.
%READ_TRN      read a .trn file as output from the OPNML transect code
%READ_UCD      read an .inp file, an AVS-Unstructured Cell Data file
%READ_V2C      read a FEM output file of .v2c filetype.
%READ_V2R      read a FEM output file of .v2r filetype.
%READ_V3C      read a FEM output file of .v3c filetype.
%READ_V3R      read a FEM output file of .v3r filetype.
%READ_VEL      read a FEM output file of .vel filetype.
%S2C           Dartmouth FEM File Standard Filetype (Description).
%S2R           Dartmouth FEM File Standard Filetype (Description).
%S3C           Dartmouth FEM File Standard Filetype (Description).
%S3R           Dartmouth FEM File Standard Filetype (Description).
%V2C           Dartmouth FEM File Standard Filetype (Description).
%V2R           Dartmouth FEM File Standard Filetype (Description).
%V3C           Dartmouth FEM File Standard Filetype (Description).
%V3R           Dartmouth FEM File Standard Filetype (Description).
%WRITE_BAT     write a bathymetry list to disk in .bat format.
%WRITE_ELE     write an element list to disk in .ele format.
%WRITE_NEI     write a FEM neighbor file in .nei format.
%WRITE_NOD     write a node list to disk in .nod format.
%RWRITE_VEL    write a FEM output file of .vel filetype.
%WRITEGRID     write a fem_grid_struct to separate gridfiles (.ele, .nod,...)
