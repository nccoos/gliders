%
% Determine nn and ne
%
size(x);
nn=ans(1);
size(in);
ne=ans(1);
%
% Elemental areas
%
for nele=1:ne
   i1=in(nele,1);
   i2=in(nele,2);
   i3=in(nele,3);
   dy1=y(i2)-y(i3);
   dy2=y(i3)-y(i1);
   dy3=y(i1)-y(i2);
   areae(nele)=0.5*(x(i1)*dy1+x(i2)*dy2+x(i3)*dy3);
   xe(nele)=(x(i1)+x(i2)+x(i3))/3.0;
   ye(nele)=(y(i1)+y(i2)+y(i3))/3.0;
   ze(nele)=(z(i1)+z(i2)+z(i3))/3.0;
end
%
% Elemental deltax
%
dxele=sqrt(2.0*areae);
%
% Nodal areas
%
for i=1:nn
   arean(i)=0.0;
end
for nele=1:ne
   i1=in(nele,1);
   i2=in(nele,2);
   i3=in(nele,3);
   arean(i1)=arean(i1)+areae(nele)/3.0;
   arean(i2)=arean(i2)+areae(nele)/3.0;
   arean(i3)=arean(i3)+areae(nele)/3.0;
end
%
% Nodal deltax
%
dxnod=sqrt(2.0*arean);
dxnod=dxnod';
