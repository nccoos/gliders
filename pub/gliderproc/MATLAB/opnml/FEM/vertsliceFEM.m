function qlev=horzslicefem(zgrid,q,zlev)
%HORZSLICEFEM slice a FEM domain horizontally
%   HORZSLICEFEM slices a 3-D FEM domain specified in zgrid
%   horizontally at vertical position zlev, mapping the 
%   data in q to that level.
%
% Inputs (all three arguments REQUIRED):
%   zgrid - vertical position of FEM domain, in [nn x nnv] shape 
%       q - [nn x nnv] scalar field, in [nn x nnv] shape 
%           or a 3-d array of several variables to slice,
%           [nn x nnv x nqs], where nqs is the number of scalars
%           to slice
%    zlev - the vertical level at which to make slice
%
% Output:
%    qlev - quantity q mapped to zlev 
%
% ALTERNATIVE: (not yet available)
%  Input (Both arguments REQUIRED):
%   fem_icq4_struct - structure containing .icq4 variables
%   zlev - the vertical level at which to make slice
%
% Output: 
%    qlev - all 3-D .icq4 field variables mapped to zlev.
%           in the following order:
%            UZMID,VZMID,WZMID,Q2MID,Q2LMID,TMPMID,SALMID
%
% Call as: >> qlev=horzslicefem(zgrid,q,zlev)
%    OR:   >> qlev=horzslicefem(fem_icq4_struct,zlev)
%    
%
% Written by: Brian O. Blanton
%             December 1998   

nargchk(2,3,nargin);

if isstruct(zgrid)
   error('fem_icq4_struct input to HORZSLICEFEM not yet supported')
end

[nn,nnv]=size(zgrid);
[n,m,nq]=size(q);
if n~=nn | nnv~=m
   error('Size mismatch between zgrid and q in HORZSLICEFEM.')
end

% yank zgrid,q around a bit; now it's nnv X nn, top down
zgrid=flipud(zgrid');
% 

if nq==1
   q2=flipud(q');
else   % transpose and flipud each scalar component
   q2=ones(m,n,nq);
   for i=1:nq
      q2(:,:,i)=flipud(q(:,:,i)');
   end
end


% ilower is the vertical level immediately below the 
% vertical position zlev for each horizontal node iok

ilower=zgrid<zlev;
% find which nodes can bound zlev by surface and bottom
% heights; inotok are the node numbers with zlev deeper than,
% or above, the water column;  iok are the nude numbers entirely
% within the water column.
inotok=find(sum(ilower)==0);
iok=find(sum(ilower)>0);
nok=length(iok);

% remove the "water columns" that do not bound zlev 
ilower(:,inotok)=[];

% Determine which indices in zgrid represent the bounding
% vertical levels 
[i,j]=find(ilower==1);
idx=[1 find(diff(j')==1)+1];
ilower=i(idx);
iupper=ilower-1;

% then convert them to vector access, whereby zgrid is essentially
% treated as a 1x(nn*nnv) vector
ilower=(0:length(iok)-1)*nnv+ilower';
iupper=(0:length(iok)-1)*nnv+iupper';
zt=zgrid(:,iok);
qt=q2(:,iok,:);

% extract the bounding depths for each node in iok
zup=zt(iupper);
zdown=zt(ilower);

% extract scalars similarly
if nq==1
   qup=qt(iupper);
   qdown=qt(ilower);
else
   qup=ones(nok,nq);
   qdown=ones(nok,nq);
   for i=1:nq
      temp=qt(:,:,i);
      qup(:,i)=temp(iupper');
      qdown(:,i)=temp(ilower');
   end
end

% compute differential heights and 1-D linear basis functions
zdiff=zup-zdown;
b1=(zup-zlev)./zdiff;
b2=(zlev-zdown)./zdiff; 

% Interpolate scalars to zlev.
if nq==1
   qlev=NaN*ones(nn,nq);
   qlev(iok)=qdown.*b1+qup.*b2;
else
   qlev=NaN*ones(nn,nq);
   for i=1:nq
      qlev(iok,i)=qdown(:,i).*b1'+qup(:,i).*b2';
   end
end



% IMPROVEMENTS: The only looping is over the number of scalars 
% input, nq; this can and will be removes in the future.
% Also, zlev should be allowed to be a vector of vertical 
% levels at which to slice.
