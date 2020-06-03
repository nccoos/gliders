%FEM_ICQ4_STRUCT - FEM icq4 data description structure
% FEM_ICQ4_STRUCT is a structure containing the 
% components that make up a QUODDY4 HOTSTART data file. 
%
% The struct array FEM_ICQ4_STRUCT contains the following fields:
%   INFO LINES
%      .codename     - Code name that generated the icq4 file [char array]
%      .casename     - Name of computational domain
%      .inqfilename  - QUODDY4 .inq filename
%      .initcondname - Starting .icq4 filename
%      .nn           - Number of horizontal nodes
%      .nnv          - Number of vertical nodes
%      .day          - Simulation day of month
%      .month        - Simulation month of year
%      .year         - Simulation year
%      .curr_seconds - Number of seconds elasped since start of day
%
%   DATA BLOCK - field names are same as QUODDY4 OUTPUTQ4 variable names
%                all *MID* fields are at time level of icq4 write
%                all *OLD* fields are at previous time level 
%      .HMID   - total depth             [nn x 1  double array]
%      .UMID   - depth-averaged u-vel        "    "     "   
%      .VMID   - depth-averaged v-vel        "    "     "   
%      .HOLD   - total depth                 "    "     "   
%      .UOLD   - depth-averaged u-vel        "    "     "   
%      .VOLD   - depth-averaged v-vel        "    "     "   
%      .ZMID   - vertical grid position at current time  [nn x nnv double]
%      .ZOLD   - vertical grid position at previous time   "     "     "
%      .UZMID  - 3-D east-west horizontal velocity         "     "     "
%      .VZMID  - 3-D east-west horizontal v-velocity       "     "     "
%      .WZMID  - 3-D east-west horizontal w-velocity       "     "     "
%      .Q2MID  - 3-D turbulence field                      "     "     "
%      .Q2LMID - 3-D turbulence field                      "     "     "
%      .TMPMID - 3-D temperature field                     "     "     "
%      .SALMID - 3-D salinity field                        "     "     "
%
% 
% (FEM_ICQ4_STRUCT is NOT a function; this is just the description 
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
