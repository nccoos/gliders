%LOADGRID4   load principle gridfiles for a given domain name (input)
% 
%  Input:    gridname - name of domain to load grid files
%
% Output:    LOADGRID4 returns the following in this order (ALL OUTPUT
%            ARGUMENTS ARE REQUIRED!!):
%                1)  3-column element list (columns 2-4 of .ele file )
%                2)  x-coordinate node list ( col 2 of .nod file )
%                3)  y-coordinate node list ( col 3 of .nod file )
%                4)  bathymetry list (col 2 of .bat) file 
%                5)  boundary node/pair list (.bnd file )
%
%            LOADGRID4 with no input gridname checks to see if the global
%            variable DOMAIN has been set.  If so, LOADGRID4 uses this 
%            name to load files for.  If DOMAIN does NOT exist or is  
%            empty, the input gridname must be specified.  
%
%            If the boundary list (.bnd) exists locally, LOADGRID4
%            attempts to load the remaining files locally.  If the .bnd
%            file does NOT exist locally, LOADGRID4 searches the 
%            GRIDS and GRIDDIRS global variables for the grid data.
%
%            If any of the principle grids files does not exist, LOADGRID4
%            displays the appropriate message and exits, returning empty
%            arrays for missing variables.
%            
%            In a call to LOADGRID4, space must be provided for the 
%            output data to be returned.  Therefore, call LOADGRID4 
%            as follows:
%            >> [ele,x,y,z,bnd]=loadgrid4(gridname);
%            There are 5 variables in the output list, one for each 
%            returned array.  
%
% Call as: [ele,x,y,z,bnd]=loadgrid4(gridname);
%
% Written by : Brian O. Blanton
%

function [ele,x,y,z,bnd]=loadgrid4(gridname)

% DEFINE ERROR STRINGS
err1=str2mat('You must specify 5 output arguments; call LOADGRID',...
      'as [ele,x,y,z,bnd]=loadgrid(gridname)');
err2=['gridname not supplied and global DOMAIN is empty'];

global DOMAIN GRIDS GRIDDIRS

if nargout ~=5 
   disp('??? Error using ==> loadgrid');
   disp(err1);
   return
end

if ~exist('gridname')
   if isempty(DOMAIN)
      error(err2); 
   else
      gridname=DOMAIN;
   end
else
   slashes=findstr(gridname,'/');
   if length(slashes)==0
      fpath=[];
   else
      lastslash=slashes(length(slashes));
      fpath=gridname(1:lastslash);
      gridname=gridname(lastslash+1:length(gridname));
   end
   DOMAIN=gridname;
end

% Is there a dot in the gridname?
%
dots=findstr(gridname,'.');
if length(dots)~=0
   lastdot=dots(length(dots));
   dotname=gridname(1:lastdot-1);
end      
   
% check current working directory or fpath/cwd for principle gridfiles
%
if isempty(fpath)
   disp('Searching locally ...');
else
   disp([ 'Searching ' fpath]);
end

bndname=[deblank(gridname) '.bnd'];
nodname=[deblank(gridname) '.nod'];
elename=[deblank(gridname) '.ele'];
batname=[deblank(gridname) '.bat'];

gsum=0;
if exist([fpath bndname])==2 
   loadfn=['load ' fpath bndname];
   eval(loadfn);
   if ~isempty(dots)
      bnd=eval(dotname);
   else
      bnd=eval(gridname);
   end
   bndfound=1;
   gsum=gsum+1;
   disp(['Got ' bndname])
else
   bndfound=0;
   bnd=[];
end

if exist([fpath nodname])==2
   loadfn=['load ' fpath nodname];
   eval(loadfn);
   if ~isempty(dots)
      nodes=eval(dotname);
   else
      nodes=eval(gridname);
   end
   x=nodes(:,2);
   y=nodes(:,3);
   nodfound=1;
   gsum=gsum+1;
   disp(['Got ' nodname])
else   
   nodfound=0;
   x=[];
   y=[];
end
   
if exist([fpath elename])==2
   loadfn=['load ' fpath elename];
   eval(loadfn);
   if ~isempty(dots)
      ele=eval(dotname);
   else
      ele=eval(gridname);
   end
   ele=ele(:,2:4);
   elefound=1;
   gsum=gsum+1;
   disp(['Got ' elename])
else
   elefound=0;
   ele=[];
end

if exist([fpath batname])==2
   loadfn=['load ' fpath batname];
   eval(loadfn);
   if ~isempty(dots)
      z=eval(dotname);
   else
      z=eval(gridname);
   end
   z=z(:,2);
   batfound=1;
   gsum=gsum+1;
   disp(['Got ' batname])
else
   batfound=0;
   z=[];
end

% If all gridfiles found locally, return
if gsum==4
   lnod=length(x);
   lbat=length(z);
   maxe=max(max(ele));
   if lnod~=lbat,disp(['WARNING!! Lengths of node list and depth list'...
   ' are NOT equal']),end
   if lnod~=maxe,disp(['WARNING!! Max node number in element list does NOT'...
   ' equal length of node list']),end
   return
elseif bndfound==0&elefound==1&gsum==3
   disp(['   ' bndname ' not found; computing from ' elename '.'])
   bnd=detbndy(ele);
   return
elseif gsum~=0
   disp(' ')
   disp('   NOT ALL FILES FOUND LOCALLY.')
   if ~nodfound,disp(['   ' nodname ' not found locally.']),end
   if ~elefound,disp(['   ' elename ' not found locally.']),end
   if ~batfound,disp(['   ' batname ' not found locally.']),end
   str=str2mat(' ','   This is a problem.  The files ',...
               ['   ' nodname ' ' elename ' & ' batname],...
               '   must all exist locally or all in one of',...
               '   the following directories (as set in ',...
               '   the global GRIDDIRS):',...
               GRIDDIRS,...
               ' ');
   disp(str);
%   DOMAIN=[];
   return
end

if isempty(fpath)
   disp(['Gridfiles not found in ' pwd])
else
   disp(['Gridfiles not found in ' fpath])
end

if isempty(GRIDDIRS)
   disp('No places in GRIDDIRS to search.');
   return
else
   disp('Searching GRIDS for gridname match.');
end

% Check GRIDS list for gridname
%
if ~isempty(GRIDS)
   igrid=0;
   [m,n]=size(GRIDS);
   for i=1:m
      if strcmp(deblank(GRIDS(i,:)),gridname)==1
         igrid=i;
      end
   end
end
if ~igrid
   disp([gridname ' not in GRIDS list']);
   DOMAIN=[];
   return
end
disp('Got it.') 

% gridname found in GRIDS.  Now, check GRIDDIRS for gridfiles
%
fpath=deblank(GRIDDIRS(igrid,:));  
      
bn=[fpath '/' gridname '.bnd'];
nn=[fpath '/' gridname '.nod'];
en=[fpath '/' gridname '.ele'];
zn=[fpath '/' gridname '.bat'];

if ~exist(nn)
    disp([nn ' does not exist.']);
   return
end
disp(['Got ' nodname])
loadfn=['load ' nn];
eval(loadfn);
if ~isempty(dots)
   nodes=eval(dotname);
else
   nodes=eval(gridname);
end
x=nodes(:,2);
y=nodes(:,3);

if ~exist(en)
   disp([en ' does not exist.']);
   return
end
disp(['Got ' elename])
loadfn=['load ' en];
eval(loadfn);
if ~isempty(dots)
   ele=eval(dotname);
else
   ele=eval(gridname);
end
ele=ele(:,2:4);

if ~exist(zn)
   disp([zn ' does not exist.']);
   return
end
disp(['Got ' batname])
loadfn=['load ' zn];
eval(loadfn);
if ~isempty(dots)
   z=eval(dotname);
else
   z=eval(gridname);
end
z=z(:,2);

if exist(bn)
   disp(['Got ' bndname])
   loadfn=['load ' bn];
   eval(loadfn);
   if ~isempty(dots)
      bnd=eval(dotname);
   else
      bnd=eval(gridname);
   end
else
   disp([bn ' does not exist.  Computing from ' elename]);
   bnd=detbndy(ele);
end
return;
%
%        Brian O. Blanton
%        Department of  Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        University of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%

