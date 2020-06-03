function [xx,yy,j]=drog2ddt(fem_grid_struct,t1,t2,dt,xi,yi,V)
%DROG2DDT - Track drogues in a 2-D flow-field
% DROG2DDT tracks passive particles in a 2-D flow-field defined
% on a FEM domain.  The integrator is 4th-order Runge-Kutta.
%
%   Input: fem_grid_struct - fem grid structure (see LOADGRID)
%          t1,t2           - integration interval (in hours)
%          dt              - integration timestep (in hours)
%          xi,yi           - arrays of drogue starting positions
%          V               - array of structures containing velocity slices
%                            Type 
%
%  Output: xx,yy           - arrays of particle trajectories
%          j               - elements containing final drogue positions
%
% Note: unless the first (and only) argument is a help string ('mainhelp',
% 'velhelp',...), all arguments are required.
%
% Call as:[xx,yy,j]=drog2ddt(fem_grid_struct,t1,t2,dt,xi,yi,V)

% Check first argument
if nargin==1
   drog2ddthelp(fem_grid_struct);
   return
elseif nargin>7
   error('Too many arguments to DROG2DDT')
elseif nargin==0
   error('DROG2DDT must be called with 1|7 input arguments')
end

if ~isstruct(fem_grid_struct)
   disp('    First argument to DROG2DDT must be a structure.');return
elseif ~is_valid_struct(fem_grid_struct)
   error('    fem_grid_struct to DROG2DDT invalid.')
end


% Error-check the input times relative to the timestamps
% in the velocity cell array V.  It is ASSUMED that the 
% velocity slices are in temporal order within the cells
timemin=V(1).time;
timemax=V(length(V)).time;
if t1 < timemin
   error('T1 less than minimum time in velocity cells.')
elseif t2 > timemax
   error('T2 exceeds maximum time in velocity cells.')
end

xi=xi(:);yi=yi(:);
if length(xi)~=length(yi)
   error('Lengths of xi,yi must be equal')
end

% Extract a time vector for the times at which the velocity
% slices are available.
timevec=[V.time];

% Attach element finding arrays to fem_grid_struct
if ~isfield(fem_grid_struct,'A')|~isfield(fem_grid_struct,'B')|...
    ~isfield(fem_grid_struct,'A0')| ~isfield(fem_grid_struct,'T')
   fem_grid_struct=belint(fem_grid_struct);
   disp('   BELINT info added to fem_grid_struct')
end
if ~isfield(fem_grid_struct,'ar')
   disp('   EL_AREAS info added to fem_grid_struct')
   fem_grid_struct=el_areas(fem_grid_struct);
end

% Locate initial positions in grid
% j will be the array that keeps track of the
% current element number of each drog.  A NaN will
% be used to indicate drog in-activity, either because
% the drog is initially out-of-bounds, or because the
% drogue has left the domain during tracking.
j=findelem(fem_grid_struct,[xi yi]);

% Allocate space for time history of positions
xx=NaN*(ones(size(t1:dt:t2))'*ones(size(xi')))';
yy=xx;

% 
xx(:,1)=xi;
yy(:,1)=yi;

% Loop over time;  for development purposes, the integration will
% be forward Euler.
time=t1;
iter=1;
dtsecs=dt*3600;
disp(['Starting: [' int2str(iter) ' ' num2str(time) ']'])

while time<t2
   % 
%   if iter==3,keyboard,end;
   xnow=xx(:,iter);
   ynow=yy(:,iter);
   xnew=xnow;   % Propagate previously known positions, in case a 
   ynew=ynow;   % drogue is eliminated.
%   line(xnow,ynow,'Color','r','Marker','+')

   igood=find(~isnan(j));
   % If j contains NaN's, these drogues are have exited the
   % domain at some previous timestep. 
   
   if isempty(igood)
      disp('All drogues eliminated')
      disp(['Ending:   [' int2str(iter) ' ' num2str(time) ']'])
      return
   end
   
   % Extract drogues currently in domain
   jgood=j(igood);xgood=xnow(igood);ygood=ynow(igood);
   
   [xnext,ynext,jnext]=track(fem_grid_struct,jgood,xgood,ygood,V,timevec,time,dtsecs);
   j(igood)=jnext;
   xnew(igood)=xnext;
   ynew(igood)=ynext;

   time=time+dt;
   iter=iter+1;   

   xx(:,iter)=xnew;
   yy(:,iter)=ynew;
   
end

% Prepare for return
disp(['Ending:   [' int2str(iter) ' ' num2str(time) ']'])
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PRIVATE FUNCTIONS                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% locate_drog                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function jnew=locate_drog(fem_grid_struct,x,y,j)

jnew=j;
   
% See if drogs are still in Previously known element
idx=belel(fem_grid_struct,j,[x y]);
inotfound=find(idx==0);

% Get new elements, if not in previously known element
if ~isempty(inotfound)
   idx=inotfound;
   jnew(idx)=findelem(fem_grid_struct,[x(idx) y(idx)]);
end

function [xnew,ynew,jnew]=track(fem_grid_struct,j,x,y,V,timevec,t,dt)

jnew=j;
   
% Runge-Kutta 4
tt1=t+.5*dt/3600;

[u,v]=vel_interp(fem_grid_struct,x,y,j,V,timevec,t);
k1u=dt*u;
k1v=dt*v;
xinter1=x+.5*k1u;
yinter1=y+.5*k1v;
jinter=locate_drog(fem_grid_struct,xinter1,yinter1,j);
if all(isnan(jinter))
   xnew=x;
   ynew=y;
   jnew=jinter;
   return
end

[uinter,vinter]=vel_interp(fem_grid_struct,xinter1,yinter1,jinter,V,timevec,tt1);
k2u=dt*uinter;
k2v=dt*vinter;
xinter2=x+.5*k2u;
yinter2=y+.5*k2v;
jinter=locate_drog(fem_grid_struct,xinter2,yinter2,j);
if all(isnan(jinter))
   xnew=xinter1;
   ynew=yinter1;
   jnew=jinter;
   return
end

[uinter,vinter]=vel_interp(fem_grid_struct,xinter2,yinter2,jinter,V,timevec,tt1);
k3u=dt*uinter;
k3v=dt*vinter;
xinter3=x+k3u;
yinter3=y+k3v;
jinter=locate_drog(fem_grid_struct,xinter3,yinter3,j);
if all(isnan(jinter))
   xnew=xinter2;
   ynew=yinter2;
   jnew=jinter;
   return
end

[uinter,vinter]=vel_interp(fem_grid_struct,xinter3,yinter3,jinter,V,timevec,t+dt/3600);
k4u=dt*uinter;
k4v=dt*vinter;


xnew=x+k1u/6+k2u/3+k3u/3+k4u/6;
ynew=y+k1v/6+k2v/3+k3v/3+k4v/6;

jnew=locate_drog(fem_grid_struct,xnew,ynew,j);
         
% If NaN is in j, then drog has left domain.  
% insert last known location into arrays
inan=find(isnan(jnew));;
if ~isempty(inan)
   xnew(inan)=x(inan);
   ynew(inan)=y(inan);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% belel                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function retval=belel(fem_grid_struct,j,xylist)
%BELEL - determine if points are in elements
% BELEL 
tol=eps*10000000;
phi=basis2d(fem_grid_struct,xylist,j);
test=phi>=-tol & phi<=1+tol;
retval=all(test'==1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% vel_interp                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [u,v]=vel_interp(fem_grid_struct,x,y,j,V,timevec,t)
% Get the velocities at this time
% Temporal interpolation of velocity slices to this time.
it1=find(t<=timevec);it1=it1(1);
it2=find(t>=timevec);it2=it2(length(it2));
if it1==it2
   tfac1=1;tfac2=0;
else
   tfac1=(timevec(it1)-t)/(timevec(it1)-timevec(it2));
   tfac2=1-tfac1;
end
u1=V(it1).u;
u2=V(it2).u;
v1=V(it1).v;
v2=V(it2).v;

% Depending on the number of particles to track, the
% interpolation to (x,y,t) is done one of two ways.
% it is not ovvious, but the flop savings can be huge.
if length(j)>150
   % Interpolate in time first,...
   uu=tfac1*u2 + tfac2*u1;
   vv=tfac1*v2 + tfac2*v1;
   % ... then, space
   u=interp_scalar(fem_grid_struct,uu,x,y,j);
   v=interp_scalar(fem_grid_struct,vv,x,y,j);
else
   % Interpolate in space first, at the 2 time levels
   uu1=interp_scalar(fem_grid_struct,u1(:),x,y,j);
   vv1=interp_scalar(fem_grid_struct,v1(:),x,y,j);
   uu2=interp_scalar(fem_grid_struct,u2(:),x,y,j);
   vv2=interp_scalar(fem_grid_struct,v2(:),x,y,j);
   % Then, interpolate BETWEEN time levels
   u=tfac1*uu2 + tfac2*uu1;
   v=tfac1*vv2 + tfac2*vv1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% drog2ddthelp                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function drog2ddthelp(option)

if ~isstr(option)
   error('Invalid help string to DROG2DDT')
end

switch lower(option)
   case 'mainhelp'
      str=[sprintf('DROG2DDT HELP: mainhelp\n')];
   case 'velhelp'
      str=[sprintf('\nDROG2DDT HELP: velhelp\n')];
      str=[str sprintf('\nDROG2DDT needs a series of 2-D velocity fields.  This\n')];
      str=[str sprintf('information is passed into DROG2DDT in an array of structures.  \n')];
      str=[str sprintf('Each structure has fields named ''u'',''v'', and ''time''.  The first\n')];
      str=[str sprintf('two structures thus look like:\n')];
      str=[str sprintf('\n   V(1).u;        %%  u-velocity for time 1\n')];
      str=[str sprintf('   V(1).v;        %%  v-velocity for time 1\n')];
      str=[str sprintf('   V(1).time;     %%  actual time in hours!! for time 1\n')];
      str=[str sprintf('   V(2).u;        %%  u-velocity for time 2\n')];
      str=[str sprintf('   V(2).v;        %%  u-velocity for time 2\n')];
      str=[str sprintf('   V(2).time;     %%  actual time in hours!! for time 2\n')];
      str=[str sprintf('\nand so on...\n')];
      str=[str sprintf('DROG2DDT makes sure that each structure is identical in fields, \n')];
      str=[str sprintf('and that the integration times are within the initial and final\n')];
      str=[str sprintf('times specified in the velocity array V.  The sizes of the ''u'' and \n')];
      str=[str sprintf('''v'' fields must match the nuber of nodes in the fem_grid_struct.\n')];
 


   otherwise
      disp('DROG2DDT must be called with a valid help string.')
      disp('Try: ''mainhelp'',''velhelp''') 
end

if ~isempty(str)
   disp(str)
end
return
