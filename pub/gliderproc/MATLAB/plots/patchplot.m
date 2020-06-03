
	function [hplot,hleg] = patchplot(varargin)

%
%   PATCHPLOT plots up to three sets of data as patches on a current axis
% 
%   PATCHPLOT requires the following arguments:
%		data (up to 3)	- array in the format [x y q]
%			  	  where q is the scalar to be displayed
%		leg (opt)	- string of legend text
%				  if leg1 specified, legends must
%				  be specified for all input datasets
%		pctsc (opt)	- percent scale of axis for patch objects
%				  (default is 2)
%				
%   [hplot,hleg] = patchplot(data1, leg1, data2, leg2, data3, leg3, pctsc);
%   [hplot,hleg] = patchplot(data1, data2, data3, pctsc);
%   [hplot,hleg] = patchplot(data1, leg1, data2, leg2);
%
% Calls: none
%
%  Catherine R. Edwards
%  Last modified: 12 Apr 2000
%


% PROCESS THE INPUT ARGUMENTS -- Copy incoming cell array
input_cell=varargin;
nargs=length(input_cell);

% DEFINE ERROR STRINGS
err1=['Incorrect number of arguments to PATCHPLOT'];
err2=['Each set of data must have a legend.'];
err3=['Incorrect ordering of arguments.'];

% Length of input_cell must be between 1 and 7, inclusive.
if nargs<1 |  nargs>7
   error(err1)
end 

% Set num patches and part out input_cell
if nargs==1
  npatch=1; data1=input_cell{1}; 
elseif nargs==2
  npatch=1; data1=input_cell{1};
  if isstr(input_cell{2})
    leg1=input_cell{2};
  elseif prod(size(input_cell{2}))<2
    pctsc=input_cell{2};
  else
    npatch=2; data2=input_cell{2};
  end
elseif nargs==3
  if isstr(input_cell{2})
    npatch=1;data1=input_cell{1}; leg1=input_cell{2}; pctsc=input_cell{3};
  elseif prod(size(input_cell{3}))==1
    npatch=2;data1=input_cell{1};data2=input_cell{2}; pctsc=input_cell{3};
  else
    npatch=3; data1=input_cell{1}; data2=input_cell{2}; data3=input_cell{3};
  end
elseif nargs==4
  npatch=1; data1=input_cell{1};  
  if isstr(input_cell{2})
    npatch=2; leg1=input_cell{2}; data2=input_cell{3}; leg2=input_cell{4};
  else
    npatch=3; data2=input_cell{2}; data3=input_cell{3}; pctsc=input_cell{3};
  end
elseif nargs==5
  npatch=2; data1=input_cell{1}; leg1=input_cell{2}; 
  data2=input_cell{3}; leg2=input_cell{4}; pctsc=input_cell{5};
elseif nargs==6
  npatch=3; data1=input_cell{1}; leg1=input_cell{2}; data2=input_cell{3}; 
  leg2=input_cell{4}; data3=input_cell{5}; leg3=input_cell{6};
else
  npatch=3; data1=input_cell{1}; leg1=input_cell{2}; data2=input_cell{3}; 
  leg2=input_cell{4}; data3=input_cell{5}; leg3=input_cell{6};
  pctsc=input_cell{7};
end

if ~exist('pctsc'); pctsc=2; end
if isstr(pctsc); error(err3); end
if ~exist('leg1'); nargout=1;
 end

% SCALE VELOCITY DATA TO RENDERED WINDOW SCALE 

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
  xsqr1=x1-pct; xsqr2=x1+pct; xsqr3=0.5*(xsqr1+xsqr2);
  ysqr1=y1-pct; ysqr2=y1+pct; ysqr3=0.5*(ysqr1+ysqr2);
  xsqr=[xsqr1; xsqr2; xsqr2; xsqr1]; ysqr=[ysqr1; ysqr1; ysqr2; ysqr2];
  hold on;
end
hbox=plot(5,5,'sb','visible','off');

if npatch>=2
  if isempty(data2); else;
    s2=size(data2); if s2(1)~=3; data2=data2'; end
    x2=data2(1,:); y2=data2(2,:); q2=data2(3,:); Q=[q1 q2];
    xtri1=x2-pct; xtri2=x2+pct; xtri3=0.5*(xtri1+xtri2);
    ytri1=y2-pct; ytri2=y2+pct; ytri3=0.5*(ytri1+ytri2);
    xtri=[xtri1; xtri2; xtri3]; ytri=[ytri1; ytri1; ytri2];
  end 
  htr=plot(1,1,'^b','visible','off'); 
end 
if npatch==3
  if isempty(data3); else;
    s3=size(data3); if s3(1)~=3; data3=data3'; end
    x3=data3(1,:); y3=data3(2,:); q3=data3(3,:);Q=[q1 q2 q3];
    pct=sqrt(2)*pct;		% make diamond xy a little bigger 
    xdia1=x3-pct; xdia2=x3+pct; xdia3=0.5*(xdia1+xdia2);
    ydia1=y3-pct; ydia2=y3+pct; ydia3=0.5*(ydia1+ydia2);
    xdia=[xdia3; xdia2; xdia3; xdia1]; ydia=[ydia1; ydia3; ydia2 ;ydia3];
  end
  hdb=plot(7,7,'db','visible','off');
end

cl=[fix(10*min(Q))/10 ceil(10*max(Q))/10];
hsqr=patch(xsqr,ysqr,q1); set(gca,'clim',cl); 
if npatch>=2
  htri=patch(xtri,ytri,q2); set(gca,'clim',cl);
end
if npatch==3
  hdia=patch(xdia,ydia,q3); set(gca,'clim',cl); 
end
colorbar;

% assign handles to plots

if npatch==1
  hplot=hsqr;
  if exist('leg1'); 
    hleg=legend(hbox,leg1); 
  end
elseif npatch==2
  hplot=[hsqr,htri];
  if exist('leg1'); 
    if ~isstr(leg2); error(err2); end
    hleg=legend([hbox,htr],leg1,leg2); 
  end
elseif npatch==3
  hplot=[hsqr,htri,hdia];
  if exist('leg1');
    if ~isstr(leg2) | ~isstr(leg3); error(err2); end
    hleg=legend([hbox,htr,hdb],leg1,leg2,leg3); 
  end
end

return;
