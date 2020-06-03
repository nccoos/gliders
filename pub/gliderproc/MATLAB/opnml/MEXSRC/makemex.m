% OPNML/MATLAB CMEX-file compile script
echo on

% These stand-alone mex files should be OK

mex contmex5.c
mex ele2neimex5.c 
mex findelemex5.c
mex isopmex5.c 
mex read_icq4_mex5.c 
mex read_ucd_mex5.c 
mex rkck45.c


% These mex files require the banded matrix solver
% in band.c;  The first line below is a shell call
% that may need to be altered for a particular system.
% Hopefully, everyone has gcc available.  
%
% NOTE:  for 64-bit SGI, the gcc compiler appears to
% work, even though the combination is unsupported by MATHWORKS.


!gcc -ansi -fpic band.c -c
mex curlmex5.c band.o
mex divgmex5.c band.o
mex gradmex5.c band.o

% Moving mex binaries to ../MEX
!mv *.mex* ../MEX

echo off
