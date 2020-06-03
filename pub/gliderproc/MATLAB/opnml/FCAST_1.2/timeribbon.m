function R=timeribbon(icq4liststruct,mesh,xi,yi,t,interpint)

% R=timeribbon(icq4liststruct,varname,mesh,[x y t],interpint)
%
% R = x: [nnv x npts]
%     y: [nnv x npts]
%     z: [nnv x npts]
%     d: [nnv x npts]
%     v: [nnv x npts]
%     t: [nnv x npts]
%
% Q and Z are expected to be [nn x nnv]

flds{1}='ZMID';
flds{2}='UZMID';
flds{3}='VZMID';
flds{4}='WZMID';
flds{5}='Q2MID';
flds{6}='Q2LMID';
flds{7}='TMPMID';
flds{8}='SALMID';

if length(xi)==1
	xi=xi*ones(size(t));
	yi=yi*ones(size(t));
end
if length(t)==1
	t=t*ones(size(xi));
else
	t=t(:);
end

% OPNML Compliant 3-18-99 CVL

mesh=belint(mesh);
mesh=el_areas(mesh);

% INTERPOLATE X & Y ALONG TRACK IF REQUESTED

d=[0; cumsum(((diff(xi(:))).^2+(diff(yi(:))).^2).^0.5)];
xy=[xi(:),yi(:)];
if exist('interpint')
	if ~isnan(interpint)
		di=d;
		d=sort([d(:);[interpint:interpint:max(d)]']);
		xy=interp1(di,xy,d);
		t=interp1(di,t,d);
	end
end

% BUILD SPATIAL BASIS FN LIST

ll=findelem(mesh,xy);
ind=find(~isnan(ll));
if isempty(ind)
	error('section off grid!')
end
p=basis2d(mesh,xy);

% INTERPOLATE Z & Q AT EACH SIGMA LEVEL

D=icq4liststruct;
NFILE=length(D);
for in=1:NFILE
	f{1}=read_icq4(D(in).name,0);
	jday(in)=julian([f{1}.year,f{1}.month,f{1}.day,...
		0,0,f{1}.curr_seconds]);
end
[jday,Dsi]=sort(jday);
D=D(Dsi);
fileind=floor(interp1(jday,1:NFILE,t));
fileind=[fileind,fileind+1]';
if t(1)<jday(1)
	fileind(1:2,find(t<jday(1)))=1;
end
if isnan(fileind(1,length(t)))
	fileind(1:2,find(t>jday(NFILE)))=NFILE;
end

% FILL STRUCTURE TO NPTS x NNV

R.x=meshgrid(xy(:,1),1:f{1}.nnv)';
R.y=meshgrid(xy(:,2),1:f{1}.nnv)';
R.d=d*ones(1,f{1}.nnv);
R.t=meshgrid(t,1:f{1}.nnv)';
for if=1:8
	R=setfield(R,flds{if},nan*R.x);
end

% READ FIRST TWO FILES
f{1}=read_icq4(D(fileind(1,1)).name);
f{2}=read_icq4(D(fileind(2,1)).name);

% FOR LOOP THROUGH TIME POINTS

for it=ind(:)'
   tf=jday(fileind(1:2,it));
   tb=min([max([(t(it)-tf(1))/(eps+diff(tf)) 0]) 1]);
   R.tb(it,:)=[tb 1-tb];
   tb=[1-tb tb];

   for if=1:8
      Q=tb(1)*getfield(f{1},flds{if})+tb(2)*getfield(f{2},flds{if});
      for iv=1:f{1}.nnv
	 R=setfield(R,flds{if},{it,iv},sum( ( p(it,:)' .* Q( mesh.e(ll(it),:),iv ) )' ));
      end
   end

   nit=min(length(t), it+1);
   if fileind(1,it)~=fileind(1,nit)
      if fileind(1,nit)==fileind(2,it)
         f{1}=f{2};
      elseif fileind(1,nit)~=fileind(1,it)
         disp(['reading 'D(fileind(1,nit)).name])
         f{1}=read_icq4(D(fileind(1,nit)).name);
      end
   end
   if fileind(2,it)~=fileind(2,nit)
      if fileind(2,nit)==fileind(1,nit)
         f{2}=f{1};
      else
         disp(['reading 'D(fileind(2,nit)).name])
         f{2}=read_icq4(D(fileind(2,nit)).name);
      end
   end
end


