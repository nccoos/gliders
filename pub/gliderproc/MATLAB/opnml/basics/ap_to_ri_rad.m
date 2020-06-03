% AP_TO_RI_RAD   Convert amplitude/phase(rad) vectors to real/imaginary.
%
%                AP_TO_RI_DEG(a,p) returns the real and imaginary 
%                components in a two-column matrix as [real,imag].
% 
%                Call as: [R,I]=ap_to_ri_rad(amp,pha);
%
function [R,I]=ap_to_ri_rad(a,p)

c=a.*exp(-i.*p);
R=real(c);
I=imag(c);

return


 

