function [hsurfo,hcb,hisl,csurf]=femfill(Q,mesh,cint);

% [HSURFACES,HCOLORBAR,HISLANDS,CSURF]=
%                    femfill(Q,CINT,FEM_MESH_STRUCT);
%
% HSURFACES - handles of data objects
% HCOLORBAR - handle to colorbar axis
% HISLANDS  - handle to land and island masks
% CSURF     - lines defining HSURFACES, useful for EXTCLABEL
%
% Draw nifty filled colored contours of a finite element mesh.  Masks
% islands and any non-filled regions inside the mesh using the current
% axis 'Color' property with a black border.
%
% Requires: CONTOURFILL (R. Pawlowicz) and subfunctions

% CVL 1/24/99

if exist('cint')
	if isempty(cint)|isnan(cint)
		clear cint
	end
end

% MOVE AXIS TO MAKE ROOM FOR COLORBAR

ah=gca;
set(ah,'position',get(ah,'position').*[1 1 0.85 1]);
ap=get(ah,'position');

% MASK LAND AND CALCULATE ISLAND MASKS

hold on
xo=[];
yo=[];
while ~isempty(mesh.bnd)
	ind=2;
	indseries=nan*mesh.bnd(:,1)';
	indseries(1:2)=mesh.bnd(1,:);
	mesh.bnd=mesh.bnd(2:size(mesh.bnd,1),:);
	while indseries(1)~=indseries(ind);
		nind=find(mesh.bnd(:,1)==indseries(ind));
		if isempty(nind)
			mesh.bnd=fliplr(mesh.bnd);
			nind=find(mesh.bnd(:,1)==indseries(ind));
		end
		ind=ind+1;
		indseries(ind)=mesh.bnd(nind,2);
		mesh.bnd=mesh.bnd([1:(nind-1) ...
			(nind+1):size(mesh.bnd,1)],:);
	end
	xo=[xo,mesh.x(indseries(1:ind))',nan];
	yo=[yo,mesh.y(indseries(1:ind))',nan];
end

ind=find(isnan(xo));
olst=1:ind(1)-1;
plst=max(olst);
for in=ind(2:length(ind))
	plst=max(plst)+2:in-1;
	if isinpoly(xo(olst(1)),yo(olst(1)),xo(plst),yo(plst))
		olst=plst;
	end
end

hisl=fill3(xo(olst),yo(olst),zeros(size(olst)),...
	get(gca,'color'),'edgecolor',1-get(gca,'color'));
	
% FILL AXIS

Qt=Q;
if exist('cint')==1
	[csurf,hs]=contourfill([mesh.x,mesh.y],mesh.e',Qt,cint);
	cinto=cint;
else
	[csurf,hs]=contourfill([mesh.x,mesh.y],mesh.e',Qt);
end

% DETERMINE ACTUAL CINT

ii = 1;
cint = [];
while (ii < size(csurf,2)),
	cint=[cint csurf(1,ii)];
	ii = ii + csurf(2,ii) + 1;
end
cint=cint(find(diff([cint(:);max(cint)+1])));
if ~exist('cinto')
	cinto=cint;
end

% SET EDGECOLORS AND HEIGHTS

ct=0;
for in=hs(:)'
	ct=ct+1;
	set(in,'edgecolor','k')
	if ~isnan(get(in,'cdata'))
		set(in,'cdata',find(get(in,'cdata')==cint),...
			'zdata',zeros(size(get(in,'xdata')))+ct);
	else
		set(in,'facecolor',get(gca,'color'),...
			'zdata',zeros(size(get(in,'xdata')))+ct)
	end
end

% MASK ISLANDS

hisl(2)=fill3(xo(olst),yo(olst),zeros(size(olst))+length(hs)+1,...
	get(gca,'color'),...
	'facecolor','none',...
	'edgecolor',1-get(gca,'color'));
plst=-1;
for in=ind
	plst=max(plst)+2:in-1;
	if olst(1)~=plst(1)
		hisl=[hisl,fill3(xo(plst),yo(plst),...
			zeros(size(plst))+length(hs)+1,...
			get(gca,'color'),...
			'edgecolor',1-get(gca,'color'))];
	end
end

% CREATE COLORBAR

hcb=axes('position',[ap(1)+1.04*ap(3) ap(2) ap(3)*.1 ap(4)]);

ulm=max(cint)>max(Q(:));
xcb=1:2;
ycb=[(min(Q(:))>min(cint(:))):...
	length(cint)+(max(Q(:))>max(cint(:)))-ulm];


[xcbg,ycbg]=meshgrid(xcb,ycb);

[outlines,hsbar]=contourf(xcb,ycb,ycbg,[1:length(cint)]);

set(hcb,'ticklength',[0 0],...
	'XTick',[],...
	'yTick',1:length(cinto),...
	'yticklabel',num2str(cinto(:)),...
	'YAxisLocation','right',...
	'color',get(ah,'color'))
for in=hsbar
	set(in,'edgecolor','k')
end

% RETURN TO ORIGINALLY SCHEDULED AXIS AND CHECK FOR NARGOUT

axes(ah)
if nargout
	hsurfo=hs;
end
