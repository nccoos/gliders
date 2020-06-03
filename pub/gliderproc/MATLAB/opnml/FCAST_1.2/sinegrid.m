function zz=sinegrid(zbot,zeta,nnv,dzbl)
nev=nnv-1;

a=(zbot+zeta-dzbl*nev)/(nev*sin(2.*pi/nev));

a(a<0)=0;

zz=NaN*ones(length(zbot),nnv);

zz(:,1)=-zbot;
eps=(((2:nnv)-1)/nev);  

zz(:,2:nnv)=(-zbot)*(1.-eps)-a*sin(2.*pi*eps)+zeta*eps;
zz(:,nnv)=zeta;
