function [Xo,Yo,c,w]=boundcross(xl,yl,m)

% [X,Y,NODELIST,WEIGHT]=boundcross(XL,YL,M)
%
% XL and YL are two points defining a line
% M is a mesh structure loaded with MESHSTR
%
% X and Y are all boundary crossings.

% ROTATE MESH UNTIL LINE IS Y AXIS

b=atan(diff(xl)/(diff(yl)+eps));
tm=[    cos(b)		sin(b)
        cos(b+pi/2)	sin(b+pi/2)];
Xr=reshape([m.x(m.bnd(:)) m.y(m.bnd(:))]*tm(:,1),size(m.bnd))-...
	[xl(1) yl(1)]*tm(:,1);

% CHECK FOR NODES ON AXIS

c=[];
w=[];
if any(Xr(:)==0)
	c=sort(m.bnd(find(Xr(:)==0)));
	c=reshape(c,2,length(c)/2);
	w=ones(size(c))/2;
end

% CHECK FOR LINE CROSSINGS

if any(abs(diff(sign(Xr')))==2);
	ct=find(abs(diff(sign(Xr')))==2);
	c=[c m.bnd(ct,:)'];
	w=[w 1-abs(Xr(ct,:)'./([1;1]*diff(Xr(ct,:)')))];
end

% FIND XY POINTS AND REORDER FROM LOWEST TO HIGHEST

Xo=sum(w.*m.x(c));
Yo=sum(w.*m.y(c));
[Xo,in]=sort(Xo);Yo=Yo(in);
[Yo,in]=sort(Yo);Xo=Xo(in);
