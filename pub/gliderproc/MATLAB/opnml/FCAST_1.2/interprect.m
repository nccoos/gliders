function R=interprect(Q,Z,m,slev)

% R=interprect(Q,Z,m,slev)
%
% INPUTS:
% Q [nn x nnv]        = Scalar quantity
% Z [nn x nnv]        = Vertical locations of nodes
% 
% OUTPUT STRUCTURE:
% R.Q                 = interpolated quantity
% R.X, R.Y and R.Z    = actual x locations of grid
% R.XG, R.YG and R.ZG = integer grid indices

% OPNML COMPLIANT 3-19-99 CVL

if nargin<4
	slev=[10e4 10e4];
elseif length(slev)==1
	slev=slev*[1 1];
end

% Transposing Q and Z; I assume you have more
% horizontal than vertical nodes!

Q=Q';
Z=Z';
nnv=size(Q,1);

% DEFINE MESH SPATIAL GRID AND NODAL GRID

x=slev(1)*(floor(min(m.x(:))/slev(1)):...
	ceil(max(m.x(:))/slev(1))+1);
y=slev(2)*(floor(min(m.y(:))/slev(2)):...
	ceil(max(m.y(:))/slev(2))+1);

xg=1:length(x);
yg=1:length(y);
zg=1:nnv;
[x,y,z]=meshgrid(x,y,zg);
[rx,ry,rz]=size(x);
[xg,yg,zg]=meshgrid(xg,yg,zg);

% CALCULATE BASIS FUNCTIONS FOR MESH

m=belint(m);
m=el_areas(m);

% CALCULATE POINTS ON LINE

xc=x(:,:,1);
yc=y(:,:,1);

xy=[xc(:),yc(:)];
[p,l]=basis2d(m,xy);

ind=find(~isnan(l(:)));
l=l(ind);
p=p(ind,1:3);

% INITIALIZE RESULTS FIELD

r=nan*ones(rx*ry,rz);
zo=nan*ones(rx*ry,rz);

% INTERPOLATE AT EACH SIGMA LEVEL

for in=1:nnv
	qs=Q(in,:);
	zs=Z(in,:);
	r(ind,in)=sum(p'.*qs(m.e(l,:))')';
	zo(ind,in)=sum(p'.*zs(m.e(l,:))')';
end

% CORRECT zo FOR NaN'S

ind=find(isnan(zo(:,1)));
inddeep=min(find(Z(1,:)==min(Z(1,:))));
zo(ind,:)=ones(length(ind),1)*Z(:,inddeep)';

% BUILD OUTPUT STRUCTURE

R.Q=reshape(r,rx,ry,rz);
R.X=x;
R.Y=y;
R.Z=reshape(zo,rx,ry,rz);
R.XG=xg;
R.YG=yg;
R.ZG=zg;
