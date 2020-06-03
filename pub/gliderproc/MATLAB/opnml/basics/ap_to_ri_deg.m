% AP_TO_RI_DEG   Convert amplitude/phase(deg) vectors to real/imaginary.
%
%                AP_TO_RI_DEG(a,p) returns the real and imaginary 
%                components in a two-column matrix as [real,imag].
% 
%                Call as: [R,I]=ap_to_ri_deg(amp,pha);
%
function [R,I]=ap_to_ri_deg(a,p)

deg_to_rad = pi/180.;

c=a.*exp(-i.*p*deg_to_rad);
R=real(c);
I=imag(c);

return


 

