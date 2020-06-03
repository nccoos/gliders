function favg=vertavg(s,z)

% FAVG=vertavg(S,Z)
%
% Vertically averages an s3rx data array
%
% CVL (2/20/99) copied from W. Gentleman

nnv=min(size(z));
for j=2:nnv
	fint=fint+(s(:,j)+s(:,j-1)).*(z(:,j)-z(:,j-1))/2;
end;

favg=fint./(z(:,nnv)-z(:,1));
