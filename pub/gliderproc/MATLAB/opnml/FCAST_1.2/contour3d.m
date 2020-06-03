function [ho,hb]=contour3d(Q,Z,mesh,qlev,slev)

% [H,HB]=contour3d(Q,Z,MESH,QLEV,SLEV)
%
% Generates a wireframe of the isosurface of Q at value QLEV, with the
% interval between frames being described by SLEV
%
%     Q = Scalar field (nnv x nn)
%     Z = Z locations of scalar field (nnv x nn)
%     mesh = Structure loaded by MESHSTR (with E,X,Y fields)
%     qlev = isosurface value of Q to be plotted
%     slev = intervals between x, y and z wireframes (3 x 1)


nnv=size(Z,1);
xint=slev(1);
yint=slev(2);
zint=slev(3);
h=[];
hb=[];

hold on

% CONSTANT Z

if ~isnan(zint)
	zrange=	zint*ceil(min(Z(1,:))/zint+0.5):...
		abs(zint):0;
for zin=zrange
	disp([zin max(Q(:)) min(Q(:))])
	x=mesh.X;
	y=mesh.Y;
	e=mesh.E;
	if zin<0
		l=hslice(Z',Q',zin);
		save testprob x y l e qlev
		c=contourctri([x y],l,e,qlev,1);
	else
		c=contourctri([mesh.X mesh.Y],Q(nnv,:)',mesh.E,qlev,1);
	end
	while ~isempty(c)
		np=c(2,1);
		z=ones(1,np)*zin;
		x=c(1,2:np+1);
		y=c(2,2:np+1);
		h=[h;plot3(x,y,z,'c-')];
		c=c(:,np+2:size(c,2));
	end
end
end

% BATHYMETRY

c=contoursurf([mesh.X mesh.Y],mesh.E',-mesh.H,zrange);
while ~isempty(c)
	np=c(2,1);
	z=ones(1,np)*c(1,1);
	x=c(1,2:np+1);
	y=c(2,2:np+1);
	hb=[hb;plot3(x,y,z,'-',...
		'color',[0.3 0.3 0.3])];
	c=c(:,np+2:size(c,2));
end

% CONSTANT X

if ~isnan(xint)
	xrange=xint*ceil(min(mesh.X)/xint):...
		xint:...
		xint*floor(max(mesh.X)/xint);
for xin=xrange
	[l,z,d,xl,yl]=vslice(Q,Z,xin,[],100,mesh);
	hb=[hb;plot3(xl(1,:),yl(1,:),z(1,:),'-',...
		'color',[0.3 0.3 0.3])];
	
	c=contours(yl,z,l,[qlev qlev]);
	while ~isempty(c)
		np=c(2,1);
		x=ones(1,np)*xin;
		y=c(1,2:np+1);
		z=c(2,2:np+1);
		h=[h;plot3(x,y,z,'c-')];
		c=c(:,np+2:size(c,2));
	end
end
end

% CONSTANT Y

if ~isnan(yint)
	yrange=yint*ceil(min(mesh.Y)/yint):...
		yint:...
		yint*floor(max(mesh.Y)/yint);
for yin=yrange
	[l,z,d,xl,yl]=vslice(Q,Z,[],yin,150,mesh);
	hb=[hb;plot3(xl(1,:),yl(1,:),z(1,:),'-',...
		'color',[0.3 0.3 0.3])];

	c=contours(xl,z,l,[qlev qlev]);
	while ~isempty(c)
		np=c(2,1);
		y=ones(1,np)*yin;
		x=c(1,2:np+1);
		z=c(2,2:np+1);
		h=[h;plot3(x,y,z,'c-')];
		c=c(:,np+2:size(c,2));
	end
end
end

if nargout
	ho=h;
end