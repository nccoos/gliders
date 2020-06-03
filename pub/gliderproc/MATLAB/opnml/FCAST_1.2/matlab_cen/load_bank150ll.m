%
% load in nod, ele, and bat files
%
[in,x,y,z,bnd]=loadgrid('bank150');
size(in);
ne=ans(1);
size(x);
nn=ans(1);
nodes=get_nodes('/usr4/people/naimie/meshes/bank150','bank150ll');
x=nodes(:,1);
y=nodes(:,2);
bndo=plotbnd(x,y,bnd);
set(bndo,'Color','k')
cval=[60 100 150];
hc=lcontour2(in,x,y,z,cval);
set(hc,'Color','k')
hold on
%
%
%
axis([-69.5 -65.5 40.0  42.5])
set(gca,'Box','on');
set(gca,'XTick',[]);
set(gca,'YTick',[]);
