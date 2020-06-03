function S=fd_cube(nlims,dlims)      

nx=nlims(1);
ny=nlims(2);
nz=nlims(3);

minx=dlims(1);
maxx=dlims(2);
miny=dlims(3);
maxy=dlims(4);
minz=dlims(5);
maxz=dlims(6);

x=linspace(minx,maxx,nx+1);
y=linspace(miny,maxy,ny+1);
z(1,1,:)=linspace(minz,maxz,nz+1);

[X2D,Y2D]=meshgrid(x,y);

% Replicate 2D vertically
X3D=repmat(X2D,[1 1 nz+1]);
Y3D=repmat(Y2D,[1 1 nz+1]);
% Replicate 1D vert in 2D horz
Z3D=repmat(z,[nx+1 ny+1 1]);

% Build return structure
S=struct('X3D',X3D,'Y3D',Y3D,'Z3D',Z3D);