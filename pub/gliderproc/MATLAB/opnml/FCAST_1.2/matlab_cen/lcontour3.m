%
% [cs,h]=lcontour3(elems,x,y,Q,cval,p1,v1,p2,v2,...)
%
% lcontour3 contour a vector of scalar values across a FEM grid.
%           lcontour3 accepts a vector of values to be contoured 
%           over the provided mesh.  
%
% 	    lcontour3 expects the element file to be either 3 or 
%           4 columns wide.  If elems is 4 columns wide, lcontour3 
%           assumes the first column is the element number and strips 
%           it away.
%
% Input:    elems - list of nodes per element
%           x,y - xy locations of nodes; each must be 1-D
%           Q - scalar to be contoured upon; must be 1-D
%           cval - vector of values to contour
%
%           The parameter/value pairs currently allowed in the lcontour3  
%           function are as follows ( default values appear in {} ) :
%
%                Color       {'r' = red}
%                LineStyle   {'-' = solid}
%                LineWidth   {0.5 points; 1 point = 1/72 inches}
%                MarkerSize  {6 points}
%
%           See the Matlab Reference Guide entry on the LINE command for
%           a complete description of parameter/value pair specification.
%
%           The idea and some of the constructs used in pv decoding
%           in this routine come from an unreleased MathWorks function 
%           called polar2.m written by John L. Galenski III  
%           and provided by Jeff Faneuff.
%
% Output:  lcontour3 returns the handle to the contour line drawn
%
% Call as: [cs,h]=lcontour3(elems,x,y,Q,cval,p1,v1,p2,v2,...)
%
% Written by : Brian O. Blanton
%
function [cs,chandle]=lcontour3(elems,x,y,Q,cval,p1,v1,p2,v2,p3,v3,p4,v4,...
                                            p5,v5,p6,v6,p7,v7,p8,v8)                                           
% DEFINE ERROR STRINGS
err1=['matrix of elements must be either 3 or 4 columns wide' ];
err2=['node coordinate vectors must be the same length'];
err3=['length of scalar must be the same length as coordinate vectors'];
err4=['scalar to be contoured must be 1-D'];
err5=['insufficient number of parameters or values'];

% check number of arguments
N=nargin;
msg=nargchk(1,21,N);
if ~isempty(msg)
   disp(msg);
   disp('Routine: lcontour3');
   return
end

% check array sizes
[nelems,s]=size(elems);   % m = number of elements
if s<3 | s>4
   error(err1);
end
if s==4,elems=elems(:,2:4);,end

if length(x) ~= length(y)
   error(err2);
end

[nrowQ,ncolQ]=size(Q);
if nrowQ*ncolQ~=length(Q),error(err4),end

% columnate Q
Q=Q(:);
[nrowQ,ncolQ]=size(Q);

if nrowQ ~= length(x)
   error(err3);
end   

% determine number of pv pairs input
npv = N-5;
if rem(npv,2)==1,error(err5);,end
 
% process parameter/value pair argument list, if needed
PropFlag = zeros(1,4);
limt=npv/2;
for X = 1:limt
  p = eval(['p',int2str(X)]);
  v = eval(['v',int2str(X)]);
  if X == 1
    Property_Names = p;
    Property_Value = v;
  else
    Property_Names = str2mat(Property_Names,p);
    Property_Value = str2mat(Property_Value,v);
  end
  if strcmp(lower(p),'color')
    PropFlag(1) = 1;
    color = v;
  elseif strcmp(lower(p),'linestyle')
    PropFlag(2) = 1;
    linestyle = v;
  elseif strcmp(lower(p),'linewidth')
    PropFlag(3) = 1;
    linewidth = v;
  elseif strcmp(lower(p),'markersize')
    PropFlag(4) = 1;
    markersize = v;
  end
end

% Determine which properties have not been set by
% the user
Set    = find(PropFlag == 1);
NotSet = find(PropFlag == 0);
 
% Define property names and assign default values
Default_Settings = ['''r''   ';
                    '''- ''  ';
                    '0.5   ';
                    '6     '];
Property_Names =   ['color     ';
                    'linestyle ';
                    'linewidth ';
                    'markersize'];
for I = 1:length(NotSet)
  eval([Property_Names(NotSet(I),:),'=',Default_Settings(NotSet(I),:),';'])
end
 
% range of scalar quantity to be contoured; columnate cval
Qmax=max(Q);
Qmin=min(Q);
cval=cval(:);
 
jj=0;
clear cs;
sb=0;
for kk=1:length(cval)
   if cval(kk) > Qmax | cval(kk) < Qmin
      disp([num2str(cval(kk)),' not within range of specified scalar field']);
   else
   
% Call cmex function contour
%
      C=contmex(x,y,elems,Q,cval(kk));
      X = [ C(:,1) C(:,3) NaN*ones(size(C(:,1)))]';
      Y = [ C(:,2) C(:,4) NaN*ones(size(C(:,1)))]';
      X = X(:);
      Y = Y(:);
%  Differences from lcontour2.m
%  cs is the same cs you would get from using
%  matlab's contour command.  This is necessary for labeling -
%  because we need contiguous lines.
%
      ndim=size(C,1);
      save c.dat C -ascii -tabs;
      cv=cval(kk);
      save cv.dat cv -ascii;
      !/usr4/people/naimie/matlab/sortv
      load cxy.dat;
      sc=size(cxy,1);
      se=sb+sc;
      cxy=cxy';
      for i=1:sc
        cs(1,i+sb)=cxy(3,i);
        cs(2,i+sb)=cxy(4,i);
      end
      chandle(kk)=line(X',Y',...
                       'Color',color,...
                       'Linestyle',linestyle,...
                       'LineWidth',linewidth,...
                       'MarkerSize',markersize);
      set(chandle(kk),'UserData',cval(kk));
      set(chandle(kk),'Tag','contour');
      drawnow
      dold=se;
      sb=se;
  end
end 

return
%
%        Brian O. Blanton
%        Curr. in Marine Science
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu

   





 
