function R=searibbon2(ICQ4,mesh,xi,yi,interpint)
%SEARIBBON
%   SEARIBBON computes a transect given end-points, mesh, and .icq4
%   This is the transect  
% R=searibbon(ICQ4,mesh,x,y,interpint)
%
% R =    x: [nnv x npts] 
%        y: [nnv x npts]
%        d: [nnv x npts]
%     ZMID: [nnv x npts]
%    UZMID: [nnv x npts]
%    VZMID: [nnv x npts]
%    WZMID: [nnv x npts]
%    Q2MID: [nnv x npts]
%   Q2LMID: [nnv x npts]
%   TMPMID: [nnv x npts]
%   SALMID: [nnv x npts]
%
% Check for existence of .icq4 file

flds{1}='ZMID';
flds{2}='UZMID';
flds{3}='VZMID';
flds{4}='WZMID';
flds{5}='Q2MID';
flds{6}='Q2LMID';
flds{7}='TMPMID';
flds{8}='SALMID';

Z=ICQ4.ZMID;

NNV=size(Z,2);
% OPNML Compliant 3-18-99 CVL
mesh=belint(mesh);
mesh=el_areas(mesh);

% INTERPOLATE X & Y ALONG TRACK IF REQUESTED

d=[0; cumsum(((diff(xi(:))).^2+(diff(yi(:))).^2).^0.5)];
xy=[xi(:),yi(:)];
if exist('interpint')
	if ~isnan(interpint)
		xy=interp1(d,xy,...
			sort([d(:);[interpint:interpint:max(d)]']));
		d=sort([d(:);[interpint:interpint:max(d)]']);
	end
end

% REMOVE NANS FOR NOW

ll=findelem(mesh,xy);
ind=find(~isnan(ll));
if isempty(ind)
	error('section off grid!')
end

% BUILD BASIS FN LIST

ll=ll(ind);
xy=xy(ind,:);
[p]=basis2d(mesh,xy);

% FIRST PART OF STRUCTURE
R.x=meshgrid(xy(:,1),1:NNV)';
R.y=meshgrid(xy(:,2),1:NNV)';
R.d=d(ind)*ones(1,NNV);

% INTERPOLATE AT EACH SIGMA LEVEL

for iv=1:NNV
	t=Z(:,iv);
	v1(1:length(xy),iv)=sum((p.*t(mesh.e(ll,:)))')';
	
	t=ICQ4.UZMID(:,iv);
	v2(1:length(xy),iv)=sum((p.*t(mesh.e(ll,:)))')';
	
	t=ICQ4.VZMID(:,iv);
	v3(1:length(xy),iv)=sum((p.*t(mesh.e(ll,:)))')';
	
	t=ICQ4.WZMID(:,iv);
	v4(1:length(xy),iv)=sum((p.*t(mesh.e(ll,:)))')';
	
	t=ICQ4.Q2MID(:,iv);
	v5(1:length(xy),iv)=sum((p.*t(mesh.e(ll,:)))')';

	t=ICQ4.Q2LMID(:,iv);
	v6(1:length(xy),iv)=sum((p.*t(mesh.e(ll,:)))')';

	t=ICQ4.TMPMID(:,iv);
	v7(1:length(xy),iv)=sum((p.*t(mesh.e(ll,:)))')';

	t=ICQ4.SALMID(:,iv);
	v8(1:length(xy),iv)=sum((p.*t(mesh.e(ll,:)))')';
end

R=setfield(R,flds{1},v1);
R=setfield(R,flds{2},v2);
R=setfield(R,flds{3},v3);
R=setfield(R,flds{4},v4);
R=setfield(R,flds{5},v5);
R=setfield(R,flds{6},v6);
R=setfield(R,flds{7},v7);
R=setfield(R,flds{8},v8);
