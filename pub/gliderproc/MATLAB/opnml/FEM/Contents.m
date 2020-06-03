% OPNML/MATLAB5 FEM-related routines
% Version 3.0
% 24 July, 1998
%
% These are functions that are specific to FEM data structures,
% usually requiring the domain structure fem_grid_struct as input.
%
%BASIS2D      compute basis functions for input points in FEM grid
%BELINT       compute shape function information for a FEM domain
%BWIDTH       compute the full bandwidth of an FEM element list
%COLORMESH2D  draw a FEM mesh in 2-d colored by a scalar quantity.
%COLORMESH3D  draw FEM mesh in 3-d given, colored by a scalar field.
%CURL         compute the CURL of a FEM 2-D vector field
%DETBNDY      compute a boundary segment list for a FEM domain
%DIVG         compute the divergence of a FEM 2-D vector field
%DRAWELEMS    draw 2-D FEM element configuration 
%DRAWELEMS3D  draw 2-D FEM element configuration in 3-D
%DRAWVEC      draw arrows for vectors
%EL_AREAS     compute triangular finite element areas
%ELE2NEI      build a FEM neighbor list from element and node lists
%ELGEN        generate an element list for a rectangular FEM mesh
%FEM_DATA_STRUCT FEM data description structure
%FEM_GRID_STRUCT FEM grid description structure
%FEM_ICQ4_STRUCT FEM icq4 data description structure
%FINDELEM     element finding utility
%GRAD         compute the gradient of a FEM 2-D scalar field
%GRIDINFO     display info about fem_grid_struct
%HORZSLICEFEM slice a FEM domain horizontally
%INTERP_SCALAR interpolate scalar values onto scatter points
%IS_VALID_STRUCT determine if the input structure is "valid"
%IS_VALID_STRUCT2 determine if the input structure is "valid"
%LABCONT      label contours drawn with LCONTOUR
%LCONTOUR     contour a scalar on a FEM grid.
%LOADGRID     load principle gridfiles for a given FEM domain
%NUMBND       number boundary nodes on current axes in viewing region.
%NUMELEMS     number elements on current axes in viewing region.
%NUMNODES     number nodes on current axes.
%PLOTBND      plot boundary of FEM mesh
%PLOTDROG     plot drogue .pth file output from DROG3D or DROG3DDT.
%REDUCE       compute a bandwidth-reduced FEM domain connectivity list
%SHOWELEM     highlight and display statistics on selected element
%VECPLOT      routine to plot vectors.  
%WHICH_ELEM   determine bounding finite element in given domain
