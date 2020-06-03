
	function [hplot,hleg] = colordots(varargin)

%
%   colordots plots data as dot-patches on a current axis
% 
%   colordots requires the following arguments:
%		data 		- array in the format [x y q]
%			  	  where q is the scalar to be displayed
%		leg (opt)	- string of legend text
%		pctsc (opt)	- percent scale for colordots
%				  (default is 2)
%				
%   [hplot,hleg] = colordots(data1, leg1, pctsc);
%
% Calls: none
%
%  Catherine R. Edwards
%  Last modified: 31 Jul 2001
%


% PROCESS THE INPUT ARGUMENTS -- Copy incoming cell array
input_cell=varargin;
nargs=length(input_cell);

% DEFINE ERROR STRINGS
err1=['Incorrect number of arguments to COLORDOTS'];
err2=['Each set of data must have a legend.'];
err3=['Incorrect ordering of arguments.'];

% Length of input_cell must be between 1 and 3, inclusive.
if nargs<1 |  nargs>3
   error(err1)
end 

% Set num patches and part out input_cell
if nargs==1
  data1=input_cell{1}; 
elseif nargs==2
  data1=input_cell{1};
  if isstr(input_cell{2})
    leg1=input_cell{2};
  elseif sum(size(input_cell{2}))>2
    pctsc=input_cell{2};
  end
elseif nargs==3
  data1=input_cell{1}; leg1=input_cell{2}; pctsc=input_cell{3};
end

if ~exist('pctsc'); pctsc=2; end
if isstr(pctsc); error(err3); end
if ~exist('leg1'); nargout=1; end

% SCALE DATA TO RENDERED WINDOW SCALE 

RLs= get(gca,'XLim');xr=RLs(2)-RLs(1);
RLs= get(gca,'YLim');yr=RLs(2)-RLs(1);

if(xr==0|yr==0)
   error('Axes must have been previously set for PATCHPLOT to work');
end
pct=0.5*pctsc*sqrt(xr*xr+yr*yr)/100;

% arrange data 

if isempty(data1); else;
  s1=size(data1); if s1(1)~=3; data1=data1'; end
  x1=data1(1,:); y1=data1(2,:); q1=data1(3,:); Q=q1;
  hold on;
end
hdot=plot(5,5,'ob','visible','off');

cl=get(gca,'clim'); qmax=ceil(10*max(Q))/10; qmin=fix(10*min(Q))/10;
dq=qmax-qmin;
if(cl==[0 1])
  cl=[qmin qmax];
else
  cl=[min(qmin,cl(1)) max(qmax,cl(2))];
end

the=repmat(linspace(0,2*pi,501),length(x1),1)';
xx=repmat(x1,501,1); yy=repmat(y1,501,1); qq=repmat(q1,501,1);
hdots=patch(pct*cos(the)+xx,pct*sin(the)+yy,qq);
set(hdots,'edgecolor','none');
colorbar;

% assign handles to plots

hplot=hdots;
if exist('leg1'); 
  hleg=legend(hdot,leg1); 
end

return;
