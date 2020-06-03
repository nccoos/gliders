newplot='y';
while newplot == 'y',
%
% Load data from files
%
   !ls *.vec
   filename=input('Enter the name of .vec file: ','s');
   load(filename)
   vec=eval(blank(filename(7:length(filename)-4)));
   ue=vec(:,2);
   ve=vec(:,3);
   gridname='yessub';
   [in,x,y,z,bnd]=loadgrid(gridname);
   size(in);
   ne=ans(1);
   for j=1:ne
      xe(1,j)=(x(in(j,1))+x(in(j,2))+x(in(j,3)))/3.0;
      ye(1,j)=(y(in(j,1))+y(in(j,2))+y(in(j,3)))/3.0;
   end
%
% Plot boundary
%
   figure
   whitebg('w')
   hold on
   bndo=plotbnd(x,y,bnd);
   set(bndo,'Color','k')
   axis('equal')
%
% Plot vector field
%
   newscale='y';
   while newscale == 'y',
      title([filename])
      vmax=max(abs(ue+sqrt(-1.0)*ve))
      scale=input('Enter the desired vector scale: ');
      hv=vecplot2(xe,ye,ue,ve,scale,'m/s',max(x)-0.1*(max(x)-min(x)),min(y)+0.1*(max(y)-min(y)))
      set(hv,'Color','k')
      zoom on
      newscale=input('New scale? (y/n): ','s');
      if newscale == 'y',
         delete(hv);
      end
   end
   newplot=input('New plot? (y/n): ','s');
end
