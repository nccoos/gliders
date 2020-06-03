function outmat=gen_drog_line(nd,z,end_points)
%GEN_DROG_LINE Mouse-driven drogue input coordinate generator
%   GEN_DROG_LINE - Mouse-driven drogue input coordinate generator 
%                   prompts the user to draw a line on the current 
%                   axes and returns an array of coordinates suitable 
%                   for a drogue initialization file.
%
%  INPUT:  nd     - number of drogues along the line.
%          z      - the depth to assign to the horizontal drogue
%                   locations.  
%          end_points - optional 4x1 vector defining the end points of
%                       the sampling lines.  
%                       The 4 values are [X1 Y1 X2 Y2], and if defined
%                       they take precedence over the mouse-driven facility.
%
% OUTPUT:  outmat - if z is supplied as input, outmat is a (nx*ny*length(z)) by 3 
%                   array of 3-D starting locations
%                   if z is NOT supplied as input, outmat is a (nx*ny) by 2
%                   array of 2-D starting locations
%
% Call as: outmat=gen_drog_line(nd)
%      OR: outmat=gen_drog_line(nd,z)
%      OR: outmat=gen_drog_line(nd,z,end_points)
%
% Written by :Brian O. Blanton
% December 1998
%


nargchk(1,3,nargin)

if ~isint(nd)
   error('first argument to gen_drog_line must be integer')
end
if nd==0
   error('first argument to gen_drog_line cannnot be 0')
end

if nargin==2|nargin==3
   if prod(size(z))~=length(z)
      error('depth vector to gen_drog_grid must be 1-D')
   end
   nlev=length(z);
else
   z=[];
   nlev=0;
end

% if 3th arg exists, must be 1x4 or 4x1
if nargin==3
   [m,n]=size(end_points);
   if (m*n)~=4 
      error('End_points must be 4x1 or 1x4 in gen_drog_line.')
   end
   if m~=1&n~=1
      error('End_Points must be 4x1 or 1x4 in gen_drog_line.')
   end
   % Further end point checks?? maybe
end 

% Delete previous lines
delete(findobj(gca,'Tag','Gen Drog Line'))

currfig=gcf;
figure(currfig);

% Get line dimensions
if ~exist('end_points')
   disp('Click and drag mouse to draw line');
   WindowButtonDownFcn = get(gcf,'WindowButtonDownFcn');
   WindowButtonMotionFcn = get(gcf,'WindowButtonMotionFcn');
   WindowButtonUpFcn = get(gcf,'WindowButtonUpFcn');
   set(gcf,'WindowButtonDownFcn','stretchline');   
   waitforbuttonpress;
   waitforbuttonpress;
   set(gcf,'WindowButtonDownFcn',WindowButtonDownFcn, ...
           'WindowButtonMotionFcn',WindowButtonMotionFcn, ...
           'WindowButtonUpFcn',WindowButtonUpFcn)
   % find box object on screen from stretchline
   hs = findobj(gca,'Type','line','Tag','Box Lines For stretchline');
   xdata=get(hs,'XData');
   ydata=get(hs,'YData');
   
   end_points=[xdata(1) ydata(1);
               xdata(2) ydata(2)];
   Pt1=[end_points(1) end_points(3) NaN;
        end_points(1) end_points(3) NaN];
   Pt2=[end_points(2) end_points(4) NaN;
        end_points(2) end_points(4) NaN];

%   Pt1=get(gca,'CurrentPoint');
%   rbbox([get(gcf,'CurrentPoint') 0 0],get(gcf,'CurrentPoint'));
%   Pt2=get(gca,'CurrentPoint');
   curraxes=gca;
else
   Pt1=[end_points(1) end_points(2) NaN;
        end_points(1) end_points(2) NaN];
   Pt2=[end_points(3) end_points(4) NaN;
        end_points(3) end_points(4) NaN];
   % Draw line around
   line([Pt1(1) Pt2(1)],[Pt1(3) Pt2(3)],'Tag','Gen Drog Line')
end


     
xstart=Pt1(1);
ystart=Pt1(3);
xend=Pt2(1);
yend=Pt2(3);

dx=(xend-xstart)/nd;
dy=(yend-ystart)/nd;

if abs(dx)<eps
   x=xstart*ones(1,nd);
else
   x=linspace(xstart,xend,nd);
end
if abs(dy)<eps
   y=ystart*ones(1,nd);
else
   y=linspace(ystart,yend,nd);
end

line(x,y,'LineStyle','*','Tag','Gen Drog Line')

if isempty(z)
   outmat=[x(:) y(:)];
else
   keyboard
   X=repmat(x,[1 nlev]);
   Y=repmat(y,[1 nlev]);
   Z=reshape(z(:),1,nlev);
   Z=repmat(Z,[nd 1]);
   outmat=[X(:) Y(:) Z(:)];
end

if exist('/tmp')==7
   fid = fopen('/tmp/init.dat','w');
   [m,n]=size(outmat);
   if n==2
      fprintf(fid,'%f %f\n',outmat(:,1:2)');
   else
      fprintf(fid,'%f %f %f\n',outmat(:,1:3)');
   end
end

if nargout==0
   clear outmat
end

%
%        Brian O. Blanton
%        Department of Marine Sciences
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%        December 1998
 
