%
% TELLIPSE plot ellipses from amp/phase specification of a velocity field
%
% htel=tellipse(xc,yc,ua,up,va,vp,per,skip,sc)
%
%          TELLIPSE requires the following arguments:
%              xc   - ellipse x-coordinate centers, usually node x's;
%              yc   - ellipse y-coordinate centers, usually node y's;
%              ua   - east (u) component amplitudes          
%              up   - east (u) component phases (degrees)       
%              va   - north (v) component amplitudes          
%              vp   - north (v) component phases (degrees)        
%              per  - period of field in hours
%
%          TELLIPSE allows the following optional arguments:
%              skip - number of nodes to skip in subsampling field
%              sc   - scaling factor to use if per is 0.
%
%          If per is input as 0, TELLIPSE scales the ellipses to 
%          10% of the x-axis length if sc=1, 5% of the x-axis length 
%          if sc=.5, etc., in the same manner as VECPLOT.  In this case, 
%          you must specify both "skip" and "sc".  
%
%          If per is input as non-zero, TELLIPSE plots ellipses as
%          particle excursions from the ellipse center. Scaling
%          factor sc is ingored.  
%
%          TELLIPSE expects the input phases to be in degrees and 
%          attemps to determine the units of the phaselag by computing
%          the range of the phaselag columns in the input matrix.
%          If this range is within [0,2*pi], TELLIPSE reports this as
%          a potential problem.  It does NOT abort due to the possibility
%          of the phaselags correctly being in degrees and still having
%          a range within [0,2*pi].
%
%          NOTES: 1) TELLIPSE plots CCW ellipses in red and CW ellipses 
%                    in yellow.
%                 2) TELLIPSE requires atleast 2 points and vectors.
%
% Call as: htel=tellipse(xc,yc,ua,up,va,vp,per,skip,sc);
%
% Written by : Brian O. Blanton
%
function  [UMAJOR,UMINOR,ORIEN,PHASE]=tellipse_cen(xc,yc,u,phi_u,v,phi_v,per,skip,sc)

% DEFINE ERROR STRINGS
err1=['Not enough input arguments; type "help tellipse"'];
err2=['You must specify both "skip" and "sc" if period is 0'];
err3=['Too many input arguments; type "help tellipse"'];
err4=['Length of x,y,u,v must be the same'];
err5=['Length of x,y,phi_u,phi_v must be the same'];
err6=['Length of x,y,u,v must be greater than 1'];
warn1=str2mat([' Phases in input to TELLIPSE do '],...
              [' appear to be in radians.  If the'],...
              [' result looks wierd, this may be the'],...
              [' problem.']);

% Argument check
if nargin <7
   error(err1);
elseif nargin ==7
   if per==0
      error(err2);
   end
   sc=1;
   skip=0;
elseif nargin ==8
   sc=1;
elseif nargin >9
   error(err3);
end

curfig=gcf;

%columnate input
xc=xc(:);
yc=yc(:);
u=u(:);
v=v(:);
phi_u=phi_u(:);
phi_v=phi_v(:);
deg_to_rad=pi/180;

% check input vector lengths
if length(xc)~=length(yc) | length(xc)~=length(u) | length(xc)~=length(v)
   error(err4);
end
if length(xc)~=length(phi_u) | length(xc)~=length(phi_v) 
   error(err5);
end
if length(xc)==1 
   error(err6);
end


% compute range of phases 
pharangeu=range(phi_u);
pharangev=range(phi_v);
if pharangeu<=2*pi | pharangev<=2*pi
   hwarn=warndlg(warn1,'WARNING!!');
   pause(3)
end

figure(curfig)

% convert input phases to radians
phi_u=phi_u*deg_to_rad;
phi_v=phi_v*deg_to_rad;

% subsample if skip !=0
if skip~=0
   xc=xc(1:skip+1:length(xc));
   yc=yc(1:skip+1:length(yc));
   u=u(1:skip+1:length(u));
   v=v(1:skip+1:length(v));
   phi_u=phi_u(1:skip+1:length(phi_u));
   phi_v=phi_v(1:skip+1:length(phi_v));
end
us=u;
vs=v;
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
A1=us.*cos(phi_u);
B1=us.*sin(phi_u);
A2=vs.*cos(phi_v);
B2=vs.*sin(phi_v);
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
return
%
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
