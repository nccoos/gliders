% RI_TO_AP_RAD   Convert real/imaginary vectors to amplitude/phase(rad)
%
% RI_TO_AP_RAD   Convert real/imaginary vectors to amplitude/phase,
%                assuming the phase is to be output in radians.
%                RI_TO_AP_RAD(re,im) returns the amplitude and phase 
%                components in a two-column matrix as [amp,pha].
% 
%                Call as: [A,P]=ri_to_api_rad(re,im);
%
function [A,P]=ri_to_api_rad(re,im)

A=sqrt(re.*re.+im.*im);
P=atan2(im,re));

return

