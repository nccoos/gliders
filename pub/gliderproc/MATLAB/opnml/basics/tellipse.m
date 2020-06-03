function  [htel,hccw,hcw]=tellipse(xc,yc,u,phi_u,v,phi_v,per,skip,sc,part_flag)
%TELLIPSE plot ellipses from amp/phase specification of a vel field
% [htel,hccw,hcw]=tellipse(xc,yc,ua,up,va,vp,per,skip,sc,flag)
%
%  TELLIPSE requires the following arguments:
%      x    - ellipse x-coordinate centers, usually node x's;
%      y    - ellipse y-coordinate centers, usually node y's;
%      ua   - east (u) component amplitudes        
%      up   - east (u) component phases (degrees)       
%      va   - north (v) component amplitudes          
%      vp   - north (v) component phases (degrees)        
%      per  - period of field in hours
%
%  TELLIPSE allows the following optional arguments:
%      skip - number of nodes to skip in subsampling field
%      sc   - scaling factor to use if per is 0.
%      flag - flag for particle-excursion interpretation (0|1)
% 
%      NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
%      IF THE SCALING FACTOR NEEDS TO BE SPECIFIED, SKIP
%      MUST ALSO BE SPECIFIED.  IF FLAG IS SPECIFIED, 
%      SC AND SKIP MUST BE SPECIFIED, BOTH OF WHICH CAN BE SET
%      TO 1.
%
%  TELLIPSE scales the ellipses to 10% of the x-axis length 
%  if sc=1; this is the default.  If sc=.5, the ellipse 
%  magnitudes are scaled to 5% of the x-axis length,
%  in the same manner as VECPLOT.  
%
%  TELLIPSE expects the input phases to be in degrees and 
%  attemps to determine the units of the phaselag by computing
%  the range of the phaselag columns in the input matrix.
%  If this range is within [0,2*pi], TELLIPSE reports this as
%  a potential problem.  It does NOT abort due to the possibility
%  of the phaselags correctly being in degrees and still having
%  a range within [0,2*pi].
%
%  NOTES: 1) TELLIPSE plots CCW ellipses in blue and CW ellipses 
%            in red.
%         2) TELLIPSE requires atleast 2 points and vectors.
%
% Call as: [htel,hccw,hcw]=tellipse(x,y,ua,up,va,vp,per,skip,sc,flag);
%
% Written by : Brian O. Blanton
%

% DEFINE ERROR STRINGS
err1=['Not enough input arguments; type "help tellipse"'];
err2=['You must specify both "skip" and "sc" if period is 0'];
err3=['Too many input arguments; type "help tellipse"'];
err4=['Length of x,y,u,v must be the same'];
err5=['Length of x,y,phi_u,phi_v must be the same'];
err6=['Length of x,y,u,v must be greater than 1'];
err7=['Particle excursion flag (arg 10) must be 0 or 1'];
warn1=str2mat([' Phases in input to TELLIPSE span'],...
              [' less that 2*pi degrees and appear'],...
              [' to be in radians.  If the resulting '],...
              [' plot looks wierd, this may be the'],...
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
   sc=1;part_flag=0;
elseif nargin==9
   part_flag=0;
elseif nargin==10
   if(part_flag~=0&part_flag~=1)
      error(err7);
   end
elseif nargin >10
   error(err3);
end
real_per=per;
real_freq=2*pi/real_per;

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
%   hwarn=warndlg(warn1,'WARNING!!');
%   pause(3)
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

% get ranges of x,y coordinates 
xrangedata=range(xc);
yrangedata=range(yc);
   
% if particle excursion mode, convert period to seconds and
% compute drogue excursion ellipse magnitudes.
if part_flag==1
   per=real_per*3600;
   freq=2*pi/per;
% scale amplitudes to represent particle excursions and center one
% particle's excursion at node 
   us=u/freq;
   vs=v/freq;
   magscale=NaN;
   vecscale=NaN;
else
   per=0.;
   scale=(10*sc)/100;
   % Scale Velocity amplitude data to domain scale 
   magscale=max(max(abs(u)),max(abs(v)));
%   magscale=max(sqrt(u.*u+v.*v));
   % scale by max vector size
   us=u/magscale;
   vs=v/magscale;
   
   %scale by range of x values
   us=us*xrangedata;
   vs=vs*xrangedata;

   %scale to 'scale' percent of x range
   us=us*scale;
   vs=vs*scale;
   vecscale=xrangedata*scale;
end

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

%if nargout==3
%   htel=UMAJOR;
%   umi =UMINOR;
%   ori =ORIEN;
%   return
%end
   

% Get list of CCW- and CW-rotating ellipses
% If UMINOR is >0, rotation is CCW
% If UMINOR is <=0, rotation is CW
ccw=find(UMINOR>0);
cw=find(UMINOR<=0);

% PLOT ELLIPSES
% SEND CCW TIDAL ELLIPSES TO ELLIPSE ROUTINE WITH COLOR blue
hccw=ellipse_east(xc(ccw),yc(ccw),UMAJOR(ccw),UMINOR(ccw),ORIEN(ccw),'b');
set(hccw,'UserData','ellipse');
set(hccw,'Tag','ellipse-ccw');
% SEND CW TIDAL ELLIPSES TO ELLIPSE ROUTINE WITH COLOR red
hcw=ellipse_east(xc(cw),yc(cw),UMAJOR(cw),UMINOR(cw),ORIEN(cw),'r');
set(hcw,'UserData','ellipse');
set(hcw,'Tag','ellipse-cw');

% PLOT Phase Lines
% COMPUTE direction of flow and the speed for CCW ellipses at t=0.
time=0.;
omegat=time*real_freq;
numer=vs(ccw).*cos(omegat-phi_v(ccw));
denom=us(ccw).*cos(omegat-phi_u(ccw));
theta=atan2(numer,denom);
q=sqrt(us(ccw).*us(ccw).*cos(-phi_u(ccw)).*cos(-phi_u(ccw))+...
       vs(ccw).*vs(ccw).*cos(-phi_v(ccw)).*cos(-phi_v(ccw)));
xf=xc(ccw)+q.*cos(theta);
yf=yc(ccw)+q.*sin(theta);
xp=[xc(ccw) xf NaN*ones(size(xc(ccw)))]';
yp=[yc(ccw) yf NaN*ones(size(yc(ccw)))]';
xp=xp(:);
yp=yp(:);
hplccw=line(xp,yp,'Color','b');
set(hplccw,'Tag','ellipse-ccw');

% COMPUTE direction of flow and the speed for CW ellipses at t=0.
numer=vs(cw).*cos(omegat-phi_v(cw));
denom=us(cw).*cos(omegat-phi_u(cw));
theta=atan2(numer,denom);
q=sqrt(us(cw).*us(cw).*cos(-phi_u(cw)).*cos(-phi_u(cw))+...
       vs(cw).*vs(cw).*cos(-phi_v(cw)).*cos(-phi_v(cw)));
xf=xc(cw)+q.*cos(theta);
yf=yc(cw)+q.*sin(theta);
xp=[xc(cw) xf NaN*ones(size(xc(cw)))]';
yp=[yc(cw) yf NaN*ones(size(yc(cw)))]';
xp=xp(:);
yp=yp(:);
hplcw=line(xp,yp,'Color','r');
set(hplcw,'Tag','ellipse-cw');

hccw=[hccw hplccw];
hcw=[hcw hplcw];


% CREATE DATA OBJECT THAT CONTAINS THE TIDAL ELLIPSE PARAMETERS;
% THIS OBJECT WILL BE PLOTTED AT THE ORIGIN BUT AS INVISIBLE.  THIS
% ALLOWS US TO FILL THE 'UserData' PARAMETER WITH ELLIPSE DATA
% EVEN THOUGH THE OBJECT IS "NOT THERE".  THE HANDLE TO THIS "ZERO"
% OBJECT WILL BE RETURNED EVEN THOUGH IT DOES NOT REFERENCE THE ELLIPSE
% OBJECTS ON SCREEN.
%
% The columns of the 'UserData' block are filled with the following:
% 1: ellipse x-coordinate centers
% 2: ellipse y-coordinate centers
% 3: major axis magnitudes
% 4: minor axis magnitudes
% 5: ellipse orientation
%
% At the bottom of this matrix is an extra line so that the period of
% the ellipses can be encoded in 'UserData'.  The first 4 entries are 
% 'NaN'; the last is the period in hours.  This means that the columns
% contain one more record than the number of ellipse centers.
htel=line(0,0,'Visible','off');
set(htel,'Tag','ellipse data');
UD_matrix=[xc yc UMAJOR UMINOR ORIEN;xrangedata magscale vecscale per real_per];
set(htel,'UserData',UD_matrix);

return
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
