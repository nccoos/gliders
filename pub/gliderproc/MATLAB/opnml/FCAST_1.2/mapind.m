function mi=mapind(x,y,l,m)

% mi=mapind(x,y,l,ele,xgrid,ygrid)
%
% Maps individuals at positions (X,Y) in element L onto a finite
% element mesh, providing an estimate of the density of individuals. 

xl=m.x(m.e);
yl=m.y(m.e);
A=    [ xl(:,1) .* (yl(:,2) - yl(:,3)) + ...
	xl(:,2) .* (yl(:,3) - yl(:,1)) + ...
	xl(:,3) .* (yl(:,1) - yl(:,2)) ]/2;
nnode=max(m.e(:));

mi=zeros(nnode,1);
[p,n]=phi(x,y,l,ele,xgrid,ygrid);
l3=l*ones(1,3);
p=p./A(l3);

n=[n(:);[1:nnode+1]'];
p=[p(:);zeros(nnode+1,1)];
[n,i]=sort(n(:));
p=p(i);
pcs=cumsum(p);
nind=[find(diff(n))];
mi=diff([0;pcs(nind)]);
mi=mi.*(mi>=0);
