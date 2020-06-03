function NDFUN
%NDFUN Matrix operations on N-D matrices
%   NDFUN treats an N-D matrix of double precision values as a set of pages
%   of 2D matrices, and performs various matrix operations on those pages.
%   The BLAS and LAPACK routines compiled into MATLAB are used for all these
%   operations, so results will be very close, and are usually identical, to
%   "native MATLAB results".  Available commands are:
%
%   C = NDFUN('mult', A, B)
%   C = NDFUN('backslash', A, B)
%   C = NDFUN('inv', A)
%   C = NDFUN('version')
%
%   The two-argument commands perform operations equivalent to:
%       for i=1:N
%           C(:,:,i) = A(:,:,i) * B(:,:,i);
%       end
%   The one-argument command
%       for i=1:N
%           C(:,:,i) = inv(A(:,:,i));
%       end
%
%   Any number of dimensions is supported, but dimensions > 2 must match:
%       C = ndfun('mult', rand(4,3,2,2,2), rand(3,1,2,2,2))
%   C will have size = [4 1 2 2 2]
%
%   NDFUN will reuse 2D arguments when needed, much like scalar
%   operations.  A single 2D matrix can be multiplied (or solved with)
%   each 2D page of the other argument.  For instance:
%       A = rand(4,3);  B = rand(3,10,100);
%       C = ndfun('mult', A, B);
%   is equivalent to:
%       for i=1:100
%           C(:,:,i) = A * B(:,:,i);
%       end
%   The reverse also works.  These types of operations are especially
%   efficient for the backslash operator.
%
%
%   Author: Peter Boettcher <boettcher@ll.mit.edu>

% Last modified: <Wed Mar 27 13:10:26 2002 by pwb>
  
  error('MEX file not found.  Try ''mex ndfun.c'' to compile.');
  
 
  
 
