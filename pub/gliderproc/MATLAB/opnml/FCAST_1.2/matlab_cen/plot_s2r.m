newplot='y';
while newplot == 'y',
%
% Load data from files
%
   ls *.s2r
   filename=input('Enter the name of .s2r file: ','s');
   [s2r,gridname]=read_s2r(filename);
   scalar=s2r(:,2);
   gridname=blank(gridname(1:length(gridname)-1));
   [in,x,y,z,bnd]=loadgrid(gridname);
%
% Plot boundary
%
   figure
   whitebg('w')
   hold on
   bndo=plotbnd(x,y,bnd);
   set(bndo,'Color','k')
   axis('equal')
%   cval=[50 100 200];
%   hc=lcontour2(ele,x,y,z,cval);
%   set(hc,'Color','k')
%
% Set contour levels and make plot
%
   newcont='y';
   while newcont == 'y',
      title([filename])
      scrange(scalar)
      cint=input('Enter the contour interval: ');
      cmin=cint*ceil(min(scalar)/cint);
      cmax=cint*floor(max(scalar)/cint);
      clear cval
      i=1;
      cval(i)=cmin;
      while cval(i) < cmax
         i=i+1;
         cval(i)=cval(i-1)+cint;
      end
      cval
      hc=lcontour2(in,x,y,scalar,cval);
      title([filename,': ',num2str(cmin),' to ',num2str(cmax),' by ',num2str(cint)])    
      zoom on
      newcont=input('New contour interval? (y/n): ','s');
      if newcont == 'y',
         delete(hc);
      end
   end
   newplot=input('New plot? (y/n): ','s');
end
