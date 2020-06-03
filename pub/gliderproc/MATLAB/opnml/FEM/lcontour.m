function chandle=lcontour(fem_grid_struct,Q,cval,p1,v1,p2,v2,p3,v3,p4,v4,...
                                            p5,v5,p6,v6,p7,v7,p8,v8)
%LCONTOUR contour a scalar on a FEM grid.
%   LCONTOUR contours a scalar field on the input FEM grid.
%   LCONTOUR accepts a vector of values to be contoured 
%   over the provided mesh.  
%
%   INPUT : fem_grid_struct (from LOADGRID, see FEM_GRID_STRUCT)
%           Q    - scalar to be contoured upon; must be a 1-D vector 
%                  or the single character 'z', IN SINGLE QUOTES!!
%           cval - vector of values to contour
%
%           In order to contour the FEM domain bathymetry, pass
%           in the string 'z' in place of an actual scalar field Q.
%           You could, of course, pass in the actual bathymetry as
%           the scalar to contour.  Otherwise, Q must be a 1-D vector
%           with length equal to the number of nodes in the FEM mesh.
%
%           The parameter/value pairs currently allowed in the LCONTOUR  
%           function are as follows (default values appear in {}) :
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
%  OUTPUT :  h - the handle to the contour line(s) drawn
%
%    CALL : >> h=lcontour(fem_grid_struct,Q,cval,p1,v1,p2,v2,...)
%     or
%           >> h=lcontour(fem_grid_struct,'z',cval,p1,v1,p2,v2,...)
%
% Written by : Brian O. Blanton
% 

% VERIFY INCOMING STRUCTURE
%
if ~isstruct(fem_grid_struct)
   msg=str2mat(' ',...
               'First argument to LCONTOUR not a structure.  Perhaps its',...
               'the element list.  If so you should use LCONTOUR4, which',...
               'takes the standard grid arrays (e,x,...).  The first ',...
               'argument to LCONTOUR MUST be a fem_grid_struct.',' ');
   disp(msg)
   error(' ')
end
if ~is_valid_struct(fem_grid_struct)
   error('    fem_grid_struct to LCONTOUR invalid.')
end

e=fem_grid_struct.e;
x=fem_grid_struct.x;
y=fem_grid_struct.y;

% DETERMINE SCALAR TO CONTOUR
%
if ischar(Q)
   Q=fem_grid_struct.z;
else
   % columnate Q
   Q=Q(:);
   [nrowQ,ncolQ]=size(Q);
   if nrowQ ~= length(x)
      error('Length of scalar must be same length as grid coordinates.');
   end   
end

% determine number of pv pairs input
npv = nargin-3;
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
 
for kk=1:length(cval)
   if cval(kk) > Qmax | cval(kk) < Qmin
      disp([num2str(cval(kk)),' not within range of specified scalar field']);
      chandle(kk)=0;
   else
   
% Call cmex function contmex5
%
      C=contmex5(x,y,e,Q,cval(kk));
      if(size(C,1)*size(C,2)~=1)
	 X = [ C(:,1) C(:,3) NaN*ones(size(C(:,1)))]';
	 Y = [ C(:,2) C(:,4) NaN*ones(size(C(:,1)))]';
	 X = X(:);
	 Y = Y(:);
	 chandle(kk)=line(X',Y',...
                	  'Color',color,...
                	  'Linestyle',linestyle,...
                	  'LineWidth',linewidth,...
                	  'MarkerSize',markersize);
      else
         disp(['CVal ' num2str(cval(kk)) ' within range but still invalid.']);
         chandle(kk)=0;
      end
      set(chandle(kk),'UserData',cval(kk));
      set(chandle(kk),'Tag','contour');
      drawnow
  end
end 

return
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
%        Summer 1997
   





 
