function [xout,yout,hout,iout]=boundline(arg1,x,y,h)

% [XOUT,YOUT,HOUT,IOUT]=boundline(BND,X,Y,H)
% [XOUT,YOUT,HOUT,IOUT]=boundline(FNAME)
% [XOUT,YOUT,HOUT,IOUT]=boundline(MESH_STRUCTURE)
%
% Assembles a set of continuous boundary line locations, depths and
% node numbers for a mesh.

if nargin==0
	arg1='marmap1';
end

if isstr(arg1)
	[ele,x,y,h,bnd]=cgload(arg1);
elseif isstruct(arg1)
	x=arg1.X;
	y=arg1.Y;
	h=arg1.H;
	bnd=arg1.B;
else
	bnd=arg1;
end

ho=[];
xo=[];
yo=[];
io=[];

while ~isempty(bnd)
	ind=2;
	indseries=nan*bnd(:,1)';
	indseries(1:2)=bnd(1,:);
	bnd=bnd(2:size(bnd,1),:);
	while indseries(1)~=indseries(ind);
		nind=find(bnd(:,1)==indseries(ind));
		if isempty(nind)
			bnd=fliplr(bnd);
			nind=find(bnd(:,1)==indseries(ind));
		end
		ind=ind+1;
		indseries(ind)=bnd(nind,2);
		bnd=bnd([1:(nind-1) (nind+1):size(bnd,1)],:);
	end
	io=[io,indseries(1:ind),nan];
	xo=[xo,x(indseries(1:ind))',nan];
	yo=[yo,y(indseries(1:ind))',nan];
	ho=[ho,h(indseries(1:ind))',nan];
end

if nargout
	xout=xo;
	yout=yo;
	hout=ho;
	iout=io;
else
	plot(xo,yo)
end
