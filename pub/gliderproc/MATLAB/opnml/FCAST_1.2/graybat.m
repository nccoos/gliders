function hpo=graybat(m)

% hpo=graybat(m)
%
% Creates a gray scaled 3D bathymetry image using a mesh structure
% loaded by MESHSTR

newplot;

hp=patch(m.x(m.e)',m.y(m.e)',-m.z(m.e)',m.z(m.e)');

h=(log(get(hp,'FaceVertexCData')));
ch=1-[h h h]/max(h(:));

set(hp,'CDataMapping','direct',...
	'FaceVertexCData',ch,...
	'EdgeColor','interp')
[a,e]=view;
if a==0&e==90
	view(45,30)
end
set(gca,'dataaspectratio',[1 1 1e-3])

if nargout
	hpo=hp;
end
