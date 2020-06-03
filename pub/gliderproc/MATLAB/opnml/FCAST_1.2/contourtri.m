function C=contourtri(P,Z,N,V,fill);
% CONTOURTRI Contours a triangular mesh
%            This is an extension of contourc. CONTOURTRI calculates the 
%            contour matrix C for use by EXTCONTOUR to draw the actual
%            contour plot.
%
%            C=CONTOURTRI(P,Z,N,V) contours the surface given by
%            P=[X Y],Z given the node indices in an 3xn matrix N.
%            Contours are drawn at the (optional) V levels.
%
%            C=CONTOURTRI(...,'fill') returns closed contours by including
%            lines along edges. 

% Author: R. Pawlowicz (IOS) rich@ios.bc.ca
%         16/Mar/95

if (nargin==3), V=[]; end;
if (nargin==4 & isstr(V) ), fill=1; V=[]; else fill=0; end;
if (nargin==5), fill=1; end;

V=getlevels(Z,V);

C=contourctri(P,Z,N',V,fill);

 
 
 
 
 
  
