function ret_struct=read_ucd(inpname);
%READ_UCD read an .inp file, an AVS-Unstructured Cell Data file with
%         uniform cell topology of type TRI.
%
%         For an unknown reason, AVS uses the suffix '.inp' to indicate
%         a input file for a UCD structure and not the obvious '.ucd', 
%         even though the AVS routines which use UCD structures are called 
%         UCD routines.  OPNML will adhere to this convention as well.
%         This unfortunately conflicts with the filename suffix for
%         the FUNDY series of FEM models.
%
%         This routine is provided as an "interface" between the
%         AVS-UCD datatype and OPNML/MATLAB in the loosest sense.
%         Currently, only the TRANSECT code and the transect routines 
%         in QUODDY3.3 and later output a UCD-structure file.
%         The .trn (transect) filetype is obsolete.
%
% Input:   If inpname is omitted, READ_UCD enables a file browser
%          with which the user can specify the .inp file.
%
%          Otherwise, READ_UCD takes as input the filename of the 
%          transect data file, including the .inp suffix.
%
% Output:  The output of READ_UCD is a fem_grid_struct containing the
%          transect information.  The output structure can be passed
%          directly to OPNML routines like COLORMESH2D, LCONTOUR, etc.
%          The actual data for the transect is attached to the structure 
%          in the field .data.  This .data field  is as wide
%          as the number of columns in the node-data specification
%          part of the .inp file.  Vector components will be returned
%          as three scalars, NOT 1 vector. 
%
%          Read the "man" page for TRANSECT (type "man transect" at a UNIX
%          prompt) for more information on the transect output formats.
%
%          Make sure a semi-colon is used at the end of the command; 
%          otherwise READ_UCD will return the output arrays to the screen.
%
%          Since OPNML/MATLAB routines are based on linear triangular
%          finite elements in 2-D, READ_UCD only reads UCD structures 
%          with cell-topologies of type TRI.  No other cell-types, or 
%          mixtures of cell-types, are allowed into OPNML/MATLAB through
%          this routine.  THIS CLEARLY DOES NOT APPLY TO AVS.
%
% Call as: transdata=read_ucd(inpname);         
%
% Written by : Brian O. Blanton (Jun 98)
%

err1=['READ_UCD requires 0 or 1 input arguments.'];
err2=['READ_UCD requires exactly 1 output arguments.'];
err3=['Argument to READ_UCD must be a string (filename)'];

if nargin==0 & nargout==0
   disp('Call as: transdata=read_ucd(inpname);')
   return
end

if nargin > 1
   error(err1)
end

if nargout ~=1
   error(err2)
end

if ~exist('inpname')
   [inpname,fpath]=uigetfile('*.inp','Which .inp');
   if inpname==0,return,end
else
   if ~isstr(inpname),error(err3),end
   fpath=[];
end

[et,xt,yt,zt,data]=read_ucd_mex5(inpname);
keyboard
% Generate a fem_grid_struct for return
ret_struct.name='trans';
ret_struct.x=xt;
ret_struct.y=yt;
ret_struct.z=zt;
ret_struct.e=et;
ret_struct.bnd=detbndy(et);
ret_struct.data=data;



return


%
%        Brian O. Blanton
%        Department of Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%

