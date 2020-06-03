function [ho,hb]=contourfill3d(Q,Z,mesh,qlev,slev)

% [H,HB]=contour3d(Q,Z,MESH,QLEV,SLEV)

nnv=size(Z,1);
xint=slev(1);
yint=slev(2);
zint=slev(3);
h=[];
hb=[];

hold on

% CONSTANT Z

zrange=	zint*ceil(min(Z(1,:))/zint+0.5):...
	abs(zint):0;

if ~isnan(zint)
for zin=zrange
	if zin<0
		l=horzslicefem(Z',Q',zin);
		c=contourctri([mesh.X mesh.Y],l,mesh.E,qlev,1);
	else
		c=contourctri([mesh.X mesh.Y],Q(nnv,:)',mesh.E,qlev,1);
	end
	while ~isempty(c)
		np=c(2,1);
		z=ones(1,np)*zin;
		x=c(1,2:np+1);
		y=c(2,2:np+1);
		h=[h;patch(x,y,z,'w',...
			'facecolor','none',...
			'edgecolor','c')];
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

xrange=xint*ceil(min(mesh.X)/xint):xint:xint*floor(max(mesh.X)/xint);

if ~isnan(xint)
for xin=xrange
	[l,z,d,xl,yl]=vslice(Q,Z,xin,[],60,mesh);
	hb=[hb;plot3(xl(1,:),yl(1,:),z(1,:),'-',...
		'color',[0.3 0.3 0.3])];
	
	[c,ht]=contourf(yl,z,l,[qlev qlev]);
	h=[h;ht];
	for in=ht(:)'
		z=get(in,'ydata');
		y=get(in,'xdata');
		x=ones(size(y))*xin;
		set(in,'xdata',x,...
			'ydata',y,...
			'zdata',z,...
			'facecolor','none',...
			'edgecolor','c')
	end
end
end

% CONSTANT Y

yrange=yint*ceil(min(mesh.Y)/yint):yint:yint*floor(max(mesh.Y)/yint);

if ~isnan(yint)
for yin=yrange
	[l,z,d,xl,yl]=vslice(Q,Z,[],yin,100,mesh);
	hb=[hb;plot3(xl(1,:),yl(1,:),z(1,:),'-',...
		'color',[0.3 0.3 0.3])];

	[c,ht]=contourf(xl,z,l,[qlev qlev]);
	h=[h;ht];
	for in=ht(:)'
		z=get(in,'ydata');
		x=get(in,'xdata');
		y=ones(size(x))*yin;
		set(in,'xdata',x,...
			'ydata',y,...
			'zdata',z,...
			'facecolor','none',...
			'edgecolor','c')
	end
end
end

if nargout
	ho=h;
end
