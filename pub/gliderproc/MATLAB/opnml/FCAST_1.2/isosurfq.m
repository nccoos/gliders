function ho=isosurfq(Q,Z,m,constant,slev)

%H = isosurfq(Q, Z, MESH, CONSTANT, SLICE_INTERVAL)
%
%INPUTS:
%Q [nn x nnv]           = Scalar quantity
%Z [nn x nnv]           = Vertical locations of nodes
%MESH (fem_grid_struct) = mesh information
%CONSTANT               = value of scalar at isosurface
%SLICE_INTERVAL [2]     = x and y interpolation interval (1e4)
% 
%OUTPUT STRUCTURE:
%H = handles to the triangle, quadrilateral, pentagonal and
%    hexagonal patches fo the isosurface.
%
%This code is derived from EQUISURF, available on the MATLAB web site 
%and uses two mex files found therein:
%
%POLYGONS
%INTERP_EQUISURF (actually referred to as INTERP in the release, but
%                 this conflicts with other MATLAB routines).

%OPNML COMPLIANT 3-19-99 CVL

newplot;
if exist('slev')~=1;
	slev=[1e4 1e4];
elseif length(slev)==1
	slev=[slev slev];
end

% INTERPOLATE ONTO RECTANGULAR GRID

R=interprect(Q,Z,m,slev);

% PAD EDGES

%nneighb=conv2(~isnan(R.Q(:,:,1)),ones(3),'same');
%edgemap=nneighb.*isnan(R.Q(:,:,1))>1;
R.Q(find(isnan(R.Q)))=0*find(isnan(R.Q));

%for in=1:size(R.Q,3)
%	R.Q(:,:,in)=R.Q(:,:,in)+...
%		conv2(R.Q(:,:,in),ones(3,1),'same').*edgemap;
%end

% DETERMINE POLYGONS OF ISOSURFACE

[p3,p4,p5,p6] = polygons(R.Q, [], constant);

sh = 'interp';

% DEFAULT PARAMETERS DRAWN FROM SURFL.M

if nargin<6
	p = [0.55 0.6 0.4 10];
end

% DETERMINE VIEW CONTROLS

[az,el] = view;

if az==0&el==90
	az = 322.5;
	el = 30;
end

az = az * pi / 180 + pi;
el = -el * pi / 180;
v = [cos(el)*sin(az), -cos(el)*cos(az), sin(el)];
s = [az*180/pi - 135, -el*180/pi];
saz = s(1) * pi / 180 + pi;
sel = -s(2) * pi / 180;
s(1) = cos(sel)*sin(saz);
s(2) = -cos(sel)*cos(saz);
s(3) = sin(sel);

view((az-pi)*180/pi, -el*180/pi);

% NORMALIZE PARAMETERS

p(1:3) = p(1:3) / sum(p(1:3));	   

% CALCULATE INTERPOLATED SHADINGS

[c3,c4,c5,c6] = interp_equisurf(p3, p4, p5, p6, v, s, p);

% BEGIN PLOT

% Color for this value,
cmax=max(max(Q));
cmin=min(min(Q));
crange=cmax-cmin;
cmap=colormap;
[nc,mc]=size(cmap);
col=floor(nc*(constant-cmin)/crange);
col=cmap(col,:);

h = [];

for in=3:6
	eval(['p=p',num2str(in),';'])
	eval(['c=c',num2str(in),';'])

	in = size(p,2);
	if in > 0,
		if strcmp(sh,'flat'),
			c = mean(c);
		end
		in = in / 3; 
		x=p(:,1:in);
		y=p(:,in+1:2*in);
		z=p(:,2*in+1:3*in);
		xr = interp3(R.XG,R.YG,R.ZG,R.X,x+1,y+1,z+1);
		yr = interp3(R.XG,R.YG,R.ZG,R.Y,x+1,y+1,z+1);
		zr = interp3(R.XG,R.YG,R.ZG,R.Z,x+1,y+1,z+1);
%		h = [h;patch(xr,yr,zr,c)];
		h = [h;patch(xr,yr,zr,col)];
	end
end

% HANDLE OUTPUT NICELY

if nargout
	ho=h;
end
