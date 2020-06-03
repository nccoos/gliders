%
% RMS computes the rms value of a vector (or columns of matrix)
% 
% [output] = rms(input)
%
% Charles Hannah Jan 1997

function [output] = rms(input)

output = sqrt(mean(input.*conj(input))); 
%
%
