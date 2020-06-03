function B = rotarray(A, n, dim)
%ROTARRAY Rotate array or subarrays.
%
%   ROTARRAY(A) is the 90 degree counterclockwise rotation of matrix A.
%   ROTARRAY(A, N) is the K*90 degree rotation of A, N = 0,+-1,+-2,...
%
%   Example,
%      A = [ 1 2 3      B = rotarray(A) = [ 3 6
%            4 5 6 ]                        2 5
%                                           1 4 ]
%
%   If A is an ND array, the same operation is performed on all 2-D
%   slices A(:,:,I,J,K,...).
%
%   ROTARRAY(A, K, DIM), where DIM is a vector with two integers, will
%   perform the rotation counterclockwise around an axis perpendicular
%   to a plane through the specified dimensions.  The default value for
%   the dimension vector is [1 2].
%   ROTARRAY(A, K, DIM) where DIM is a scalar, is equivalent to
%   ROTARRAY(A, K, [DIM DIM+1]).
%   ROTARRAY(A, K, [DIM1 DIM2]) is equivalent to
%   ROTARRAY(A, 4-K, [DIM2 DIM1]).
%
% Calls: none
%
%   See also ROT90.

%   Author:      Peter J. Acklam
%   Time-stamp:  2000-04-28 13:23:45
%   E-mail:      jacklam@math.uio.no
%   WWW URL:     http://www.math.uio.no/~jacklam

   nargsin = nargin;
   error(nargchk(1, 4, nargsin));

   % Get N.
   if (nargsin < 2) | isempty(n)
      n = 1;
   else
      if any(size(n) ~= 1) | (n ~= round(n))
         error('N must be a scalar integer.');
      end
      n = n - 4*floor(n/4);        % map n to {0,1,2,3}
   end

   % Get DIM1.
   if nargsin < 3
      dim1 = 1;
   else
      if any(size(dim1) ~= 1) | (dim1 <= 0) | (dim1 ~= round(dim1))
         error('DIM1 must be a scalar positive integer.');
      end
   end

   % Get DIM2.
   if nargsin < 4
      dim2 = dim1 + 1;
   else
      if any(size(dim2) ~= 1) | (dim2 <= 0) | (dim2 ~= round(dim2))
         error('DIM2 must be a scalar positive integer.');
      end
   end

   if (n == 0) | ((size(A,dim1) <= 1) & (size(A,dim2) <= 1))
      % Special case when output is identical to input.
      B = A;
   else
      % Largest dimension number we have to deal with.
      nd = max([ ndims(A) dim1 dim2 ]);

      % Initialize subscript cell array.
      v = {':'};
      v = v(ones(nd,1));

      switch n
         case 1
            v{dim2} = size(A,dim2):-1:1;
            d = 1:nd;
            d([ dim1 dim2 ]) = [ dim2 dim1 ];
            B = permute(A(v{:}), d);
         case 2
            v{dim1} = size(A,dim1):-1:1;
            v{dim2} = size(A,dim2):-1:1;
            B = A(v{:});
         case 3
            v{dim1} = size(A,dim1):-1:1;
            d = 1:nd;
            d([ dim1 dim2 ]) = [ dim2 dim1 ];
            B = permute(A(v{:}), d);
      end
   end
