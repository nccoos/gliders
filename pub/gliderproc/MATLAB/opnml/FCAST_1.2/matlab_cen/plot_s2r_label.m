newplot='y';
while newplot == 'y',
%
% Load data from files
%
   load_adrdep2kmg
   ls *.s2r
   filename=input('Enter the name of .s2r file: ','s');
   [s2r,gname]=read_s2r(filename);
   scalar=s2r(:,2);
%
% Set contour levels and make plot
%
   newcont='y';
   while newcont == 'y',
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
      [cs,h]=lcontour3(in,x,y,scalar,cval);
      hlabel=extclabel(cs);
      delete(h)
      title(filename)    
      zoom on
      newcont=input('New contour interval? (y/n): ','s');
      if newcont == 'y',
         delete(hlabel);
      end
   end
   newplot=input('New plot? (y/n): ','s');
end
