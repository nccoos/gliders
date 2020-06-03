function [ho,hb]=slice3d(Q,Z,mesh,slev)

% [H,HB]=slice3d(Q,Z,MESH,SLEV)
%
% Generates a wireframe of the isosurface of Q at value QLEV, with the
% interval between frames being described by SLEV
%
%     Q = Scalar field (nnv x nn)
%     Z = Z locations of scalar field (nnv x nn)
%     mesh = Structure loaded by MESHSTR (with E,X,Y fields)
%     slev = intervals between x, y and z wireframes (3 x 1)

% OPNML COMPLIANT 3-18-99

nnv=size(Z,1);
xint=slev(1);
yint=slev(2);
zint=slev(3);
h=[];

if ~isnan(xint)
	xrange=xint*ceil(min(mesh.x)/xint):...
		xint:...
		xint*floor(max(mesh.x)/xint);
else
	xrange=[];
end
if ~isnan(zint)
	zrange=	zint*ceil(min(Z(1,:))/zint+0.5):...
		abs(zint):-5;
else
	zrange=[];
end
if ~isnan(yint)
	yrange=yint*ceil(min(mesh.y)/yint):...
		yint:...
		yint*floor(max(mesh.y)/yint);
else
	yrange=[];
end
hold on

% CONSTANT Z

for zin=zrange
	x=mesh.x;
	y=mesh.y;
	e=mesh.e;
	if zin<0
		l=horzslicefem(Z,Q,zin);
		ht=colormesh2d(mesh,l);
	else
		ht=colormesh2d(mesh,Q(nnv,:)');
	end
	set(ht,'zdata',get(ht,'xdata')*0+zin)
	h=[h;ht];
end

% CONSTANT X

for xin=xrange
	[l,z,d,xl,yl]=vslice(Q,Z,xin,[],100,mesh);
	ht=surf(xl,yl,z,l);
	shading('interp')
	h=[h;ht];
	plot3(xl(:,1),yl(:,1),z(:,1),'k')
	plot3(xl(:,size(xl,2)),yl(:,size(xl,2)),z(:,size(xl,2)),'k')
	plot3(xl(size(xl,1),:),yl(size(xl,1),:),z(size(xl,1),:),'k')
	plot3(xl(1,:),yl(1,:),z(1,:),'k')
end

% CONSTANT Y

for yin=yrange
	[l,z,d,xl,yl]=vslice(Q,Z,[],yin,150,mesh);
	ht=surf(xl,yl,z,l);
	shading('interp')
	h=[h;ht];
	plot3(xl(:,1),yl(:,1),z(:,1),'k')
	plot3(xl(:,size(xl,2)),yl(:,size(xl,2)),z(:,size(xl,2)),'k')
	plot3(xl(size(xl,1),:),yl(size(xl,1),:),z(size(xl,1),:),'k')
	plot3(xl(1,:),yl(1,:),z(1,:),'k')
end

if nargout
	ho=h;
end

for xin=xrange
for yin=yrange
	plot3(	xin*ones(2,1),...
		yin*ones(2,1),...
		[min(Z(:)) max(Z(:))],...
		'k-');
end
end

axis([-inf inf -inf inf min(Z(:)) max(Z(:))]);
