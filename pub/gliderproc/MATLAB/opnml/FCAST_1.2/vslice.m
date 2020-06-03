function [vo,z,d,xl,yl]=vslice(Q,Z,x,y,np,mesh)

% [V,Z,D,X,Y]=vslice(Q,Z,X,Y,NP,MESH)
% [V,Z,D,X,Y]=vslice(Q,Z,X,Y,MESH)
%
% Q and Z are expected to be [nn x nnv]

% OPNML COMPLIANT 3-19-99 CVL

if exist('mesh')~=1&isstruct(np)
	mesh=np;
	np=25;
end

% GET [1 X 2] LINE DESIGNATORS

if isempty(x)|isnan(x)
	x=[min(mesh.x) max(mesh.x)];
elseif length(x)==1
	x=[x x];
end

if isempty(y)|isnan(y)
	y=[min(mesh.y) max(mesh.y)];
elseif length(y)==1
	y=[y y];
end

% REMAP OUTSIDE POINTS TO BOUNDARY

mesh=belint(mesh);
mesh=el_areas(mesh);
ll=findelem(mesh,[x;y]');
if any(isnan(ll))
	[xb,yb]=boundcross(x,y,mesh);
	cpti=find(min(abs(x+i*y)));
	cptb=find(min(abs(xb+i*yb)));
	if isnan(ll(cpti))
		x(cpti)=xb(cptb);
		y(cpti)=yb(cptb);
	end
	if isnan(ll(3-cpti))
		x(3-cpti)=xb(3-cptb);
 		y(3-cpti)=yb(3-cptb);
	end
	x=x+[1 -1]*diff(x)*1e-9;
	y=y+[1 -1]*diff(y)*1e-9;
	ll=findelem(mesh,[x;y]');
end


% CALCULATE POINTS ON LINE

NNV=size(Z,2);
in=[0:np]/np;
xl=x(1)+diff(x)*in;
yl=y(1)+diff(y)*in;

ll=findelem(mesh,[xl;yl]');
ind=find(~isnan(ll));
if isempty(ind)
	error('section off grid!')
end

xl=xl(ind);
yl=yl(ind);
ll=ll(ind);
d=((xl-xl(1)).^2+(yl-yl(1)).^2).^0.5;
p=basis2d(mesh,[xl;yl]',ll);
n=mesh.e(ll,:);

for iv=1:NNV
	t=Z(:,iv)';
	sum((p.*t(n))');
	z(iv,1:length(xl))=sum((p.*t(n))');
	t=Q(:,iv);
	v(iv,1:length(xl))=sum((p.*t(n))');
end

if nargout
	vo=v;
	[d,tm]=meshgrid(d,z(:,1));
	yl=meshgrid(yl,1:NNV);
	xl=meshgrid(xl,1:NNV);
else
subplot(211)
	pcolor(d,z,v)
	shading('interp')
subplot(212)
	plotbnd(mesh)
	hold on
	plot(xl,yl,'rx')
end
