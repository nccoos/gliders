function D=dirsort(name)

D=dir(name);
dn={D.name}';
[y,i]=sort(dn);
D=D(i);


