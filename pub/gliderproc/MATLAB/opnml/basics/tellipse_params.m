function  [UMAJOR,UMINOR,PHASE,ORIEN]=tellipse_params(u,phi_u,v,phi_v)
%TELLIPSE_PARAMS compute ellipse parameters from amp/phase specification 
%
%  TELLIPSE_PARAMS requires the following arguments:
%      ua   - east (u) component amplitudes        
%      up   - east (u) component phases (degrees)       
%      va   - north (v) component amplitudes          
%      vp   - north (v) component phases (degrees) 
%    
%  TELLIPSE_PARAMS outputs: 
%      UMAJOR - 
%      UMINOR - 
%      PHASE  -
%      ORIEN  -
%
%  TELLIPSE_PARAMS expects the input phases to be in degrees and 
%  attemps to determine the units of the phaselag by computing
%  the range of the phaselag columns in the input matrix.
%  If this range is within [0,2*pi], TELLIPSE_PARAMS reports this as
%  a potential problem.  It does NOT abort due to the possibility
%  of the phaselags correctly being in degrees and still having
%  a range within [0,2*pi].
%
% Call as: [UMAJOR,UMINOR,PHASE,ORIEN]=tellipse_params(ua,up,va,vp);
%
% Written by : Brian O. Blanton
%

% DEFINE ERROR STRINGS
err3=['Number of input arguments MUST be 4! Type "help tellipse_params"'];
err4=['Length of x,y,u,v,phi_u,phi_v must be the same'];
err7=['Particle excursion flag (arg 10) must be 0 or 1'];
warn1=str2mat([' Phases in input to TELLIPSE span'],...
              [' less that 2*pi degrees and appear'],...
              [' to be in radians.  If the resulting '],...
              [' plot looks wierd, this may be the'],...
              [' problem.']);

% Argument check
if nargin ~=4
   error(err3);
end

% check input vector lengths
if length(u)~=length(v) | length(u)~=length(phi_u)| length(u)~=length(phi_v)
   error(err4);
end


% convert input phases to radians
deg_to_rad=pi/180;
phi_u=phi_u*deg_to_rad;
phi_v=phi_v*deg_to_rad;


% COMPUTE TIDAL ELLIPSE PARAMETERS FROM AMP-PHASE INFORMATION
% NOTATION AS PER : Atlas of Tidal Elevation and Current
%                   Observations on the Northeast
%                   American Continental Shelf
%                   and Slope
%
%                   By: John A. Moody, Bradford Butman,
%                   Robert C. Beardsley, Wendell S. Brown,
%                   Peter Daifuku, James D. Irish,
%                   Dennis A Mayer, Harold O. Mofjeld,
%                   Brian Petrie, Steven Ramp, Peter Smith,
%                   and W. R. Wright
%  
%                   U.S. Geological Survey Bulletin 1611
%
A1=u.*cos(phi_u);
B1=u.*sin(phi_u);
A2=v.*cos(phi_v);
B2=v.*sin(phi_v);
Uplus =0.5*sqrt((A1+B2).*(A1+B2)+(A2-B1).*(A2-B1));
Uminus=0.5*sqrt((A1-B2).*(A1-B2)+(A2+B1).*(A2+B1));

% Compute major and minor axis components
UMAJOR=Uplus+Uminus;
UMINOR=Uplus-Uminus;

% Compute phase; not needed at this time
numer= 2*(A1.*B1) + 2*(A2.*B2);
denom= A1.*A1 - B2.*B2 + A2.*A2 - B1.*B1;
PHASE=0.5*atan2(numer,denom);

% Compute orientation
numer= 2*(A1.*A2 + B1.*B2);
denom= A1.*A1 + B1.*B1 - (A2.*A2 + B2.*B2);
ORIEN=0.5*atan2(numer,denom);



%
%LabSig  Brian O. Blanton
%        Department in Marine Sciences
%        12-7 Venable Hall
%        CB# 3300
%        University of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        brian_blanton@unc.edu
%
