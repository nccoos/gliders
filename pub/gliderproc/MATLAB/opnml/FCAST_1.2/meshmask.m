function [hlo,hi,hw]=mask(mesh,bfname)

% [HLAND,HISLAND,HWATER]=meshmask(fem_mesh_str)
%
% Needs to know where .bel file lies.

% Not OPNML COMPLIANT 3-18-99 CVL

if nargin==2
	bel=read_bel('/homes/blanton/FCAST_DIR/MESH/bank150.bel');
else
	bel=read_bel(bfname);
end

lbl=size(bel,1);

breakind=[find( bel(2:lbl,2)~=bel(1:lbl-1,3)|...
		bel(2:lbl,5)~=bel(1:lbl-1,5))...
			;lbl];

lind=1;
hl=[];
hi=[];
hw=[];

for in=1:length(breakind)
	uind=breakind(in);
	ind=lind:uind;
	nodeind=bel(ind,2);
	nodeind=[nodeind;bel(uind,3)];
 	if (bel(ind,5)==2)
		hi=[hi,patch(mesh.x(nodeind),mesh.y(nodeind),...
			get(gca,'color'),...
			'edgecolor','g')];
	elseif (bel(ind,5)==1)
		hl=[hl,plot(mesh.x(nodeind),mesh.y(nodeind),'g')];
	else
		hw=[hw,plot(mesh.x(nodeind),mesh.y(nodeind),'b')];
	end

	hold on
	lind=uind+1;
end

if nargout
	hlo=hl;
end
