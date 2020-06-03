%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% load node and element files
%
figure
load_bank150
close
%
% load level surface data
%
!ls *.lst *.lte *.lsa
fname=input('Enter the name of the .lst file: ','s')
[pfid,message]=fopen([fname]);
datatype=fname(length(fname)-2:length(fname))
gridname=fgets(pfid);
header=fgets(pfid);
nl=fscanf(pfid,'%d1');
zl=fscanf(pfid,'%f',[nl 1])';
data=fscanf(pfid,'%f',[1 inf])';
size(data);
nn=ans(1)/nl;
datal=reshape(data,[nl nn]);
datal=datal';
datalmin=min(min(datal))
datalmax=max(max(datal))
cmin=ceil(datalmin);
cmax=floor(datalmax);
% floor rounds toward -infinity
% ceil  rounds toward +infinity
% fix   rounds toward  0
%
% output avs .inp files
%
for il=1:nl
   size(in);
   nel=0;
   clear inl
   for ie=1:ans(1)
      depth=(z(in(ie,1))+z(in(ie,2))+z(in(ie,3)))/3.0;
      if depth >= -zl(il)
         nel=nel+1;
         inl(nel,1)=in(ie,1);
         inl(nel,2)=in(ie,2);
         inl(nel,3)=in(ie,3);
      end
   end
   inpfile=['truth_level',num2str(il),'.inp']
   write_inp_2d(inpfile,x,y,inl,datal(:,il))
end
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
