function [C,RA,RB] = insertrows(A,B,ind)
% INSERTROWS - Insert rows into a matrix at specific locations
%   C = INSERTROWS(A,B,IND) inserts the rows of matrix B into the matrix A at
%   the positions IND. Row k of matrix B will be inserted after position IND(k)
%   in the matrix A. If A is a N-by-X matrix and B is a M-by-X matrix, C will
%   be a (N+M)-by-X matrix. IND can contain non-integers.
%
%   If B is a 1-by-N matrix, B will be inserted for each insertion position
%   specified by IND. If IND is a single value, the whole matrix B will be
%   inserted at that position. If B is a single value, B is expanded to a row
%   vector. In all other cases, the number of elements in IND should be equal to
%   the number of rows in B, and the number of columns, planes etc should be the
%   same for both matrices A and B. 
%   If any of the inputs are empty, C will return A.
%
%   Examples:
%     % the size of A,B, and IND all match
%        C = insertrows(rand(5,2),zeros(2,2),[1.5 3]) 
%     % the row vector B is inserted twice
%        C = insertrows(ones(4,3),1:3,[1 Inf]) 
%     % matrix B is expanded to a row vector and inserted twice (as in 2)
%        C = insertrows(ones(5,3),999,[2 4])
%     % the whole matrix B is inserted once
%        C = insertrows(ones(5,3),zeros(2,3),2)
%
%   [C, RA, RB] = INSERTROWS(...) will return the row indices RA and RB for which C
%   corresponds to the rows of either A and B.
%        [c,ra,rb] = insertrows([1:4].',99,[0 3]) ;
%        c.'     % -> [99 1 2 3 99 4] ;
%        c(ra).' % -> [1 2 3 4] ;
%        c(rb).' % -> [99 99] ;
%
%   To insert columns, planes, etc., you can permute the inputs and ipermute the result.
%       A = ones(4,3) ; B = zeros(4,1) ; 
%       C = insertrows(permute(A,[2 1]), permute(B,[2 1]),1) ;
%       C = ipermute(C,[2 1]) ;
%
%  See also PERMUTE, IPERMUTE, RESHAPE, CAT

% for Matlab R13
% version 1.0 (feb 2006)
% (c) Jos van der Geest
% email: jos@jasen.nl

error(nargchk(3,3,nargin)) ;

% shortcut when any of the inputs are empty
if isempty(B) || isempty(ind),    
    C = A ;     
    if nargout,
        RA = 1:size(A,1) ;
        RB = [] ;
    end
end

sa = size(A) ;

% match the sizes of A, B
if numel(B)==1,
    % B has a single argument, expand to match A
    sb = [1 sa(2:end)] ;
    B = repmat(B,sb) ;
else
    % otherwise check for dimension errors
    if ndims(A) ~= ndims(B),
        error('Both input matrices should have the same number of dimensions.') ;
    end
    sb = size(B) ;
    if ~all(sa(2:end) == sb(2:end)),
        error('Both input matrices should have the same number of columns (and planes, etc).') ;
    end
end

ind = ind(:) ; % make as row vector
ni = length(ind) ;

% match the sizes of B and IND
if ni ~= sb(1),
    if ni==1 && sb(1) > 1,
        % expand IND
        ind = repmat(ind,sb(1),1) ;
    elseif (ni > 1) && (sb(1)==1),
        % expand B
        B = repmat(B,ni,1) ;
    else
        error('The number of rows to insert should equal the number of insertion positions.') ;
    end
end
sb = size(B) ;

% the actual work
% 1. concatenate matrices
C = [A ; B] ;
% 2. sort the respective indices
[abi,abi] = sort([[1:sa(1)].' ; ind(:)]) ;
% 3. reshuffle the large matrix
C = C(abi,:) ;
% 4. reshape as A for nd matrices (nd>2)
if ndims(A) > 2,
    sc = sa ;
    sc(1) = sc(1)+sb(1) ;
    C = reshape(C,sc) ;
end

if nargout,
    % outputs required
    R = [zeros(sa(1),1) ; ones(sb(1),1)] ;
    R = R(abi) ;
    RA = find(R==0) ;
    RB = find(R==1) ;
end






