% RI_TO_AP_DEG   Convert real/imaginary vectors to amplitude/phase(deg)
%
% RI_TO_AP_DEG   Convert real/imaginary vectors to amplitude/phase,
%                assuming the phase is to be output in degrees.
%                RI_TO_AP_DEG(re,im) returns the amplitude and phase 
%                components in a two-column matrix as [amp,pha].
% 
%                Call as: [A,P]=ri_to_api_deg(re,im);
%
function [A,P]=ri_to_api_deg(re,im)

deg_to_rad = pi/180.;

A=sqrt(re.*re.+im.*im);
P=atan2(im,re))/deg_to_rad;

return

