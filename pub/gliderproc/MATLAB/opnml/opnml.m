more (20)
help opnml
%  OPNML/matlab Contents list:
%  Last Update: 2 Feb 1999
%  Contact: Brian Blanton
%           Department of Marine Sciences
%           Ocean Processes Numerical Modeling Laboratory
%           15-1A Venable Hall
%           CB# 3300
%           Uni. of North Carolina
%           Chapel Hill, NC
%                 27599-3300
%
%           919-962-4466
%           blanton@marine.unc.edu
%
%  NOTES: Functions designated with (*) were written outside of OPNML. 
%         Type "help <function-name>" at the MATLAB prompt ">>" for more
%         information on any function below.
%  
%  	OPNMLINIT  -  initialization function for accesing OPNML routines 
%  	              and data directories.  This routine calls SETDIRS
%  	              to specify the data directories and other FEM 
%  	              things.  For a Contents list of the OPNML 
%                     directory, type "help opnml" at the matlab prompt
%                     >>.  The function OPNMLINIT must called from
%                     your startup.m file in your local home matlab
%                     directory, $HOME/matlab/startup.m  This file should
%                     atleast look like:
%                     
%                     path(path,'/usr/local/OPNML/matlab');
%                     opnmlinit
%
%                    
%  Finite-Element specific routines:
%       BWIDTH       - compute bandwidth of an element list (.ele)
%       COLORMESH2D  - draw FEM mesh in 2-D with color scaling
%       COLORMESH3D  - draw FEM mesh in 3-D with color scaling
%       DELCONT      - delete all objects related to LCONTOUR2 
%       DELVEC       - delete all objects related to VECPLOT2 
%       DETBNDY      - compute a boundary node list from an element and
%                      node list
%   	DRAWELEMS    - draw element picture 
%       ELGEN        - generate a transect element list
%       ELE2NEI      - build a neighbor list from an element list 
%       LABCONT      - label contours drawn with LCONTOUR2 
%	LCONTOUR     - plot a contour given mesh data and 1-D vector
%       LOADGRID     - load .ele, .nod, .bat, and .bnd files for a 
%                      specified grid and return to workspace
%       MARKCCW      - mark CounterClockWise oriented tidal ellisese
%                      with an asterisk (*)
%  	NUMBND       - number boundary nodes within viewing window
%  	NUMELEMS     - number elements within viewing window
%  	NUMNODES     - number nodes within viewing window
%  	NUMSCAL      - number nodes in viewing window with scalar values
%  	PLOTDROG     - plot DROG3D or DROG3DDT .pth filetype
%       READ_NEI     - read FEM .nei filetype
%       READ_PTH     - read DROG3D or DROG3DDT .pth filetype
%       READ_S2R     - read FEM .s2r filetype
%       READ_S3C     - read FEM .s3c filetype
%       READ_TRN     - read FEM .trn transect filetype
%       READ_V2C     - read FEM .v2c or .v3r filetypes
%       READ_V2R     - read FEM .v2r, .s2c, or .s3r filetypes
%       READ_V3C     - read FEM .v3c filetype
%       READ_VEL     - read FEM .vel filetype
%       RESCALE      - redraw vector plot with different vector scale
%       STICKPLOT    - high-level vector plotter with sticks and dots
%       TELLIPSE     - draw ellipses based on amp-phase field definition
%   	VECPLOT2     - high-level vector plotter with arrowheads
%       WRITE_NEI    - write a FEM neighbor file 
%   	
%  Atomic routines called by above functions:
%       DRAWSTICK  - compute and draw vectors based on vector origins
%   		     and magnitudes with sticks and dots at origins
%   	DRAWVEC    - same as DRAWSTICK but with arrowheads
%       ELLIPSE    - draw ellipses based on major, minor axis data
%       ELLSCALE   - include a vector scale on an ellipse picture
%       GET_DEPTHS - load and return 1-column depth vector
%       GET_ELEMS  - load and return 3-column element matrix
%       GET_NODES  - load and return 2-column node matrix
%       MOVETEXT   - move a text object on the current axes
%       PLOTBND    - plot boundary of FEM domain from (x,y) and 
%                    boundary list
%       VECSCALE   - draw a vector scale on the current figure with
%  	             size equal to the largest vector in the viewing
%  	 	     window multiplied by a scaling factor
%   
%  General routines (not finite-element specific)
%     AZ_EL        - slider(widget)-driven 3-D azimuth and elevation control
%     AMPPHATOSC   - convert amp-pha field to scalar field at time t
%     AP_TO_RI_DEG - convert amp/phase to real/imag, assuming degrees
%     AP_TO_RI_RAD - convert amp/phase to real/imag, assuming radians
%     BLANK        - remove leading and trailing whitespace from string
%     CHAXIS       - button-driven axis editing panel
%     CIRCLES      - plot circles with radii and optional origins
%     COLORMENU2(*)- menu-driven colormap selector 
%     DELFIG       - draw a 'delete figure' button in the lower-left
%  	             corner of the current figure (window)
%     DELTEXT      - remove all text objects from current axes
%     FULLPAGE     - generate a plotting window that is ~8.5X11 inches
%                    for production-sized plots
%     GEN_DROG_GRID- mouse-driven initial contidion generator for DROG3D
%     GTEXT2       - place text on axes with different font attributes;
%                    an OPNML enhancement of MATLAB's GTEXT
%     HLINE	   - draw a horizontal line on current axes
%     ISINT        - determine if input is integer
%     ISOBJ(*)     - determine if given handle is a valid object
%     LANDPAGE     - set up an ~11x8.5 plotting region
%     MOVETEXT     - move text objects on the figure
%     PAN	   - move viewing window to a new center; mouse-driven
%     PLOTYY(*)    - plot graphs with Y tick labels on left and right side
%     PRINTFILE    - create a dialog box to print figures to files
%     PRINTSETUP   - create an interactive printed-page layout editor
%     PRMENU       - set up selection menus at top of current figure (window)
%     RGB          - Red/GreenBlue color editor
%     RI_TO_AP_DEG - convert real/imag to amp/phase, assuming degrees
%     RI_TO_AP_RAD - convert real/imag to amp/phase, assuming radians
%     SCRANGE      - compute and return the range (min & max) of a matrix
%     SETALLLIMS   - set all axes limits on the current figure to the
%                    same set of limits
%     TRANSLINES   - plot user-specified lines of current axes and
%                    report end-points
%     VLINE	   - draw a vertical line on current axes
%     WYSIWYG(*)   - changes the size of the figure on the screen to equal
%                    the size of the figure that would be printed
%     Y2LABEL(*)   - Y-axis label for second y-axis created using PLOTYY
%   	             driven 
more off 
%        Brian O. Blanton
%        Curr. in Marine Science
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
	              
