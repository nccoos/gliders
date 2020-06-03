function hpatch=shade_line(x,y,color,y0)
%SHADE_LINE - shade a line object about a horizontal line
%   SHADE_LINE shades a line about a horizontal line.
%
%    INPUT :  x,y  - data abcissa and ordinate
%             c    - optional color in [R G B] or 'c' form
%                    default = [.75 .75 .75] (gray)
%             y0   - optional horizontal line about which 
%                    to shade. default = y=0; 
%   OUTPUT :  hpatch - handle to patch object drawn.
%
%     CALL :  hpatch=shade_line(x,y,c,y0);
%
% Calls: none
%
% Written by : Brian O. Blanton
% Spring 1999

if nargin<2 | nargin>4
  error('Wrong number of arguments to SHADE_LINE')
end
% 
% Assume 1-d data
x=x(:);
y=y(:);
if length(x)~=length(y)
  error('Lengths of x,y must be equal')
end

if nargin==2
  color=[1 1 1]*.75;
  y0=0;
else
   if isstr(color)
      if length(color)~=1
         error('Color string to SHADE_LINE must be ''r'', ...')
      end
      if nargin==3
	 y0=0;
      else
         [m,n]=size(y0);
         if m*n~=1
           error('Size of y0 must be 1x1')
         end
      end 
   else
      [m,n]=size(color);
      if m*n==1   % Assume this is y0
	y0=color;
	color=[1 1 1]*.75;
      elseif m*n~=3
        error('Size of color vector must be 1x3')
      end
      if max(color)>1 | min(color)<0
         error('RGB colors must be >0 & <1')
      end
   end
   if nargin==3,y0=0;,end 
   if nargin==4
      [m,n]=size(y0);
      if m*n~=1
        error('Size of y0 must be 1x1')
      end
   end
end

% patch data
px=zeros(1,length(x)+2);
py=zeros(size(px));
px(2:length(px)-1)=x;
py(2:length(px)-1)=y;
% Connect end points with y=0;  % y0 should be input
px(length(px))=x(length(x));
py(length(py))=y0;
px(1)=x(1);
py(1)=y0;

hp=patch(px,py,color);

if nargout==1,hpatch=hp;,end

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
%
%        Spring 1999
%
