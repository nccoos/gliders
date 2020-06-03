function hes=ellscale(htel,unitn,scale_xor,scale_yor)
%ELLSCALE  draw a speed scale on an ellipse plot 
% ELLSCALE  draw a speed scale on an ellipse picture.  Typically
% called after TELLIPSE, passing the object handle returned 
% by TELLIPSE.  If TELLIPSE was used in "particle-excursion"
% mode, then ELLSCALE cannot draw a vector scale, as there is 
% to draw.
%
% htel MUST be the handle returned by TELLIPSE.
% TELLIPSE returns this number to the main
% workspace.
%
% unitn (optional) is the flag that indicates which
% units-text ELLSCALE should put on the figure to 
% correspond to the vector magnitudes:
% 
% If omitted, ELLSCALE uses the string 'units'.
% If unitn=1, ELLSCALE uses the string 'm/sec'.
% If unitn=2, ELLSCALE uses the string 'cm/sec'.
% If unitn='text', ELLSCALE uses the string 'text'.
%   
% This last option provides for the user to specify
% the string of choice for units.
%  
% If unitn is anything other than one of the possibilities
% specified above, ELLSCALE aborts.
%
% Call as: >>  ellscale(h,unitn)
%
% Written by : Brian O. Blanton
%
err1=['UserData associated with the object handle supplied to ELLSCALE',...
      ' is empty. ELLSCALE cannot draw the ellipse scale.'];
err2=['Improper unit specification in unitn; type "help ELLSCALE"'];
err3=['TELLIPSE was used in "particle-excursion" mode. No scaling.'];

if nargin<2 | nargin > 5
   error('Wrong number of input arguments to ELLSCALE')
end

if nargin==2
   if isstr(htel)
      error('Arg 1 to ELLSCALE cannot be a string.')
   end
end
   
parent_of_htel=get(htel,'Parent');      % the axes
parent_of_parent_of_htel=get(parent_of_htel,'Parent');  % the figure
children_of_parent_of_htel=get(parent_of_htel,'Children');

X=get(parent_of_htel,'XLim');
Y=get(parent_of_htel,'YLim');
xrange=X(2)-X(1);
yrange=Y(2)-Y(1);

% ensure that the current axes is the parent
% of the vector handle passed to ELLSCALE
axes(parent_of_htel);
 
% clear previous scales from this axes
for i=1:length(children_of_parent_of_htel)
   if strcmp(get(children_of_parent_of_htel(i),'UserData'),'scaletext')==1
      delete(children_of_parent_of_htel(i));
   elseif strcmp(get(children_of_parent_of_htel(i),'UserData'),'scalearrow')==1
      delete(children_of_parent_of_htel(i));
   end
end

data=get(htel,'UserData');
if isempty(data)== 1
   error(err1);
end

% determine which text to use for units-string
if ~exist('unitn')
   unitstring='units';
else
   if unitn==1
      unitstring='m/sec';
   elseif unitn==2
      unitstring='cm/sec';
   elseif isstr(unitn)
      unitstring=unitn;
   else
      error(err2);
   end
end

% The last line of "data" is the scaling information.  If TELLIPSE
% was used in "particle-excursiuon" mode, the 2nd and 3rd values in the
% last line will both be NaN.  "Check this and return if so.
magscale=data(length(data(:,1)),2);
vecscale=data(length(data(:,1)),3);
if (isnan(magscale)|isnan(vecscale))
   error(err3)
end

%FILTER DATA THROUGH VIEWING WINDOW
filt=find(data(:,1)>=X(1)&data(:,1)<=X(2)&data(:,2)>=Y(1)&data(:,2)<=Y(2));
umaj=data(filt,3);

% now working with umaj
maxell=max(umaj);

%
% save the current value of the current figure's WindowButtonDownFcn,
% WindowButtonMotionFcn, and WindowButtonUpFcn
%
WindowButtonDownFcn=get(gcf,'WindowButtonDownFcn');
WindowButtonMotionFcn=get(gcf,'WindowButtonMotionFcn');
WindowButtonUpFcn=get(gcf,'WindowButtonUpFcn');
set(gcf,'WindowButtonDownFcn','');
set(gcf,'WindowButtonMotionFcn','');
set(gcf,'WindowButtonUpFcn','');

if ~exist('scale_xor')| ~exist('scale_yor')
   disp('place scale on plot with a mouse button');
   [scale_xor,scale_yor]=ginput(1);
end 
hp=drawvec(scale_xor,scale_yor,maxell,0.,25,'r');
set(hp,'UserData','scalearrow');
set(hp,'Tag','scalearrow');
tnum=num2str(magscale);
tnum=[tnum ' ' unitstring];

scaletext=text(scale_xor,scale_yor-(Y(2)-Y(1))*(.05),tnum);
set(scaletext,'HorizontalAlignment','center');
set(scaletext,'UserData','scaletext');
set(scaletext,'Tag','scaletext');

hes=[hp; scaletext];

%
% return the saved values of the current figure's WindowButtonDownFcn,
% WindowButtonMotionFcn, and WindowButtonUpFcn to the current figure
%
set(gcf,'WindowButtonDownFcn',WindowButtonDownFcn);
set(gcf,'WindowButtonMotionFcn',WindowButtonMotionFcn);
set(gcf,'WindowButtonUpFcn',WindowButtonUpFcn);
%
%LabSig  Brian O. Blanton
%        Department of Marine Sciences
%        12-7 Venable Hall
%        CB# 3300
%        University of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        brian_blanton@unc.edu
%


