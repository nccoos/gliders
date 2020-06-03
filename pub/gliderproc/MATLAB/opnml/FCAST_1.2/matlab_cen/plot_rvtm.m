%
% Load data from files and set data arrays
%
   ls *.rvt
   nfiles=input('Enter the number of .rvt files: ');   
   lead=input('Enter leading character string for your .rvt files: ','s');
   for i=1:nfiles
      filename=[lead,num2str(i),'.rvt']
      load(filename);
      rvt=eval(blank(filename(1:length(filename)-4)));
      x(:,i)=rvt(:,2);
      y(:,i)=rvt(:,3);
      rho(:,i)=rvt(:,4);
      u(:,i)=rvt(:,5);
      v(:,i)=rvt(:,6);
      w(:,i)=rvt(:,7);
      enz(:,i)=rvt(:,8);
      T(:,i)=rvt(:,9);
      S(:,i)=rvt(:,10);
   end
%
% Create mesh and create boundary
%
   nnv=21;
   size(x);
   nn=ans(1);
   nseg=nn/nnv-1;
   femgen
   bnd=detbndy(in);
   xmin=min(x(:,1));
   xmax=max(x(:,1));
   ymin=min(y(:,1));
   ymax=max(y(:,1));
%
% Set contour levels
%
   newcont='y';
   while newcont == 'y',
      scalarc=input('Enter variable you desire to contour (rho,u,v,w,enz,T,S): ','s');
      scalar=eval(scalarc);
      scalarmin=min(min(scalar))
      scalarmax=max(max(scalar))
      cint=input('Enter the contour interval: ');
      cmin=cint*ceil(scalarmin/cint);
      cmax=cint*floor(scalarmax/cint);
      clear cval
      i=1
      cval(i)=cmin;
      while cval(i) < cmax
         i=i+1;
         cval(i)=cval(i-1)+cint;
      end
      cval
%
% Make subplots
%
      figure
      whitebg('w')
      for i=1:nfiles
         subplot(nfiles/2,2,i)
         hold on
         bndo=plotbnd(x,y,bnd);
         set(bndo,'Color','k')
         axis([xmin xmax ymin ymax])
         axis('off')
         hc=lcontour2(in,x(:,i),y(:,i),scalar(:,i),cval);
         filename=[lead,num2str(i),'.rvt']
         title(filename)    
      end
%
% Plot min, max, avg data values
%
      clear sstat
      for i=1:nn
         sstat(1,i)=min(scalar(i,:));
         sstat(2,i)=max(scalar(i,:));
         sstat(3,i)=mean(scalar(i,:));
         sstat(4,i)=sstat(2,i)-sstat(1,i);
      end
      sstat=sstat';
      figure
      whitebg('w')
      for i=1:3
         subplot(3,1,i)
         hold on
         bndo=plotbnd(x,y,bnd);
         set(bndo,'Color','k')
         axis([xmin xmax ymin ymax])
         axis('off')
         hc=lcontour2(in,x(:,1),y(:,1),sstat(:,i),cval);
         if i == 1
            string=[lead,' tidal time maximum ',scalarc];
         elseif i == 2
            string=[lead,' tidal time minimum ',scalarc];
         else
            string=[lead,' tidal time average ',scalarc];
         end
         title(string)    
      end
%
% Plot range of values
%
      scalar=sstat(:,4);
%
      scalarmin=min(min(scalar))
      scalarmax=max(max(scalar))
      scalar10=(scalarmax-scalarmin)/10.
      cint=input('Enter the contour interval: ');
      cmin=cint*ceil(scalarmin/cint);
      cmax=cint*floor(scalarmax/cint);
      clear cval
      i=1
      cval(i)=cmin;
      while cval(i) < cmax
         i=i+1;
         cval(i)=cval(i-1)+cint;
      end
      cval
%
      figure
      whitebg('w')
      bndo=plotbnd(x,y,bnd);
      set(bndo,'Color','k')
      axis([xmin xmax ymin ymax])
      axis('off')
      [cs,h]=lcontour3(in,x,y,scalar,cval);
      hlabel=extclabel(cs);
      bndo=plotbnd(x,y,bnd);
      set(bndo,'Color','k')
      axis([xmin xmax ymin ymax])
      axis('off')
%      hc=lcontour2(in,x(:,1),y(:,1),sstat(:,4),cval);
      filename=[lead,num2str(i),'.rvt']
      title([lead,' tidal time ',scalarc,' variations'])
%
% Make another plot?
%
      newcont=input('Contour new variable? (y/n): ','s');
   end
