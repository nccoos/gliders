function [cout, hand] = contourpm(x,y,z,ci,col)
% function [cout, hand] = contourpm(x,y,z,ci,col)
%
% draw positive, negative and zero contours
%
% input  :		see contour
%			with the exception of the number of contourlevels
%			it's used here as contourinterval !!!
%		col	overides 'gkr' colors
%			give 'rrr' for all red lines
%		 	'gray' gives a shaded negative area and solid lines 
%
% output :		see contour
%
% uses :	nmin, nmax
%
% version 0.1.4		last change 22.11.1999

% Gerd Krahmann, LDEO June 1999
% removed flaw in graphics	G.K.		8.6.1999	0.1.0-->0.1.1
% check for empty matrices 	G.K.		10.8.1999	0.1.1-->0.1.2
% can use ci-vector		G.K.		9.9.1999	0.1.2-->0.1.3
% added 'gray'			G.K.		22.11.1999	0.1.3-->0.1.4

lip = '-';
liz = ':';
lin = '--';
if nargin<5
  col = 'gkr';
end

if nargin==3 & isstr(z)
  col = z;
  [mc,nc] = size(x);
  z = x;
  lims = [1 nc 1 mc];
  x = [1:nc];
  y = [1:mc];
end
if nargin <= 2,
    [mc,nc] = size(x);
    lims = [1 nc 1 mc];
    z = x;
    if nargin == 1
      ci = (nmax(x(:))-nmin(x(:)))/20;
    else
      ci = y;
    end
    x = [1:nc];
    y = [1:mc];
else
    lims = [min(x(:)),max(x(:)), ...
            min(y(:)),max(y(:))];
    if nargin == 3
      ci = (nmax(z(:))-nmin(z(:)))/20;
    end
end

% check for gray shaded plot
if strcmp(col,'gray')
  gr = 1;
  col = 'kkk';
  zlw = 0.5;
  lin = '-';
else
  gr = 0;
  zlw = 1.5;
end


if length(ci)==1
  cim = fliplr([-ci:-ci:nmin(z(:))]);
  ciz = [0,0];
  cip = [ci:ci:nmax(z(:))];
else
  cim = ci(find(ci<0));
  ciz = [0,0];
  cip = ci(find(ci>0));
end

% plot zero contours
if gr==1
  contourf(x,y,z,ciz);
  colormap(gray)
  caxis([-1,0.5])
end
hold on
[c2,h2,msg] = contour3(x,y,z,ciz,[liz,col(2)]);
for i = 1:length(h2)
  set(h2(i),'linewidth',zlw);
end
if ~isempty(msg) 
  error(msg); 
end

% plot positive contours
if ~isempty(cip)
  [c3,h3,msg] = contour3(x,y,z,cip,[lip,col(3)]);
%  if ~isempty(msg) 
%    error(msg); 
%  end
  hold on
else
  c3 = [];
  h3 = [];
end

% plot negative contours
if ~isempty(cim)
  [c1,h1,msg] = contour3(x,y,z,cim,[lin,col(1)]);
  if ~isempty(msg) 
    error(msg); 
  end
  hold on
else
  c1 = [];
  h1 = [];
end
c = [c1,c2,c3];
h = [h1;h2;h3];

for i = 1:length(h)
  set(h(i),'Zdata',[]);
end

view(2);
set(gca,'box','on');

if nargout > 0
    cout = c;
    hand = h;
end
