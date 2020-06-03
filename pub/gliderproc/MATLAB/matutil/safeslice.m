
function A2=safeslice(A,dimm,index);
% 
% SAFESLICE.M 	-- slices any-dimensional matrix A along a given
%		   dimension and a given index.  Useful if the 
%		   actual dimensions or size of A are unknown 
%		   or if the size of A varies.
%
%		B = safeslice(A,dimm,index);
%
% 	SAFESLICE requires the following inputs
%		A	- input matrix of any size or shape
%		dimm	- dimension along which to sample
%		index	- index of sampled dimension
%
%	A=reshape(1:60,[3 4 5]);   % size(A)=[3 4 5];
%		
%	A2=safeslice(A,1,[1 3]);   % equivalent to A([1 3],:,:)
%
% Calls: util/fmap
%
% Catherine R. Edwards
% Last modified: 10 Sep 2002
%

% input checks
if(nargin~=3); error('SAFESLICE requires 3 inputs'); end

asize=num2cell(-size(A));

if(max(index)>-asize{dimm})
  error('Index exceeds matrix dimensions along dimension specified.');
elseif(dimm>length(asize))
  error('Dimension specified does not exist in input matrix.');
end

cellind=fmap('colon',asize,-1);cellind=fmap('uminus',cellind);
cellind=fmap('sort',cellind); cellind{dimm}=index;

A2=A(cellind{:});

return;
