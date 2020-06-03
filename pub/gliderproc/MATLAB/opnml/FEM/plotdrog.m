function h=plotdrog(x,y,ndrog,tstride,dstride)
%PLOTDROG plot drogue .pth file output from DROG3D or DROG3DDT.
%   PLOTDROG plots the paths of drogue locations as specified 
%   in the x,y coordinate arrays.  PLOTDROG takes as required
%   arguments the x,y coordinates of the drogue locations AND 
%   the number of drogues in the path file.  The path information
%   from  DROG3D or DROG3DDT can be read into MATLAB with 
%   READ_PTH, which reads .pth files.
%
%   PLOTDROG draws each drogue with a separate line, solid
%   by default.  Each drogue line is referenced with
%   one object handle.  Therefore, to change the linetype or
%   color of the lines, use the MATLAB command SET and the handle
%   returned by PLOTDROG. 
%
%   Even though READ_PTH returns the entire path matrix, only
%   two columns of it are passed to PLOTDROG.  It is up to the 
%   user to make sure the correct ones are passed in.  I.e.,
%   there is no way for PLOTDROG to ensure x,y represent
%   HORIZONTAL coordinates, etc.
%
%   INPUT:
%         x,y	  - x,y coordinates of drogues
%         ndrog   - number of drogues in path matrix;
%         	    this number is returned by READ_PTH 
%         tstride - time stride (optional, def = 1) is 
%         	    the number of timesteps to skip over.  1 would
%         	    mean "plot all timesteps"; 2 would mean "plot
%         	    every other timestep"; i.e., skip every other
%         	    timestep; etc...
%         dstride - drogue stride (optional, def = 1) is
%         	    the number of drogues to skip; see tstride above.
%         	    In order to specify dstride, you must also specify
%         	    tstride.
%
%         Both tstride and dstride can be vectors of specific timesteps
%         or drogue numbers to plot.  In order to plot only ONE drogue
%         or ONE timestep, pass into PLOTDROG the values of tstride
%         and/or dstride enclosed in {}'s.  For example, to
%         plot the initial drogue locations, call PLOTDROG as:
%         >> h=plotdrog(x,y,ndrog,{1});
%         To plot the 3rd drogue for all timesteps, call PLOTDROG as:
%         >> h=plotdrog(x,y,ndrog,1,{3});
% 
% OUTPUT:
%          h       - the handle(s) to the path lines on the current axes
%
%          dstride - the number of drogues to skip, see tstride above.
%                    In order to specify dstride, you must also specify
%                    tstride.
%
%   CALL:  h=plotdrog(x,y,ndrog);
%          h=plotdrog(x,y,ndrog,tstride);
%          h=plotdrog(x,y,ndrog,tstride,dstride);
%          
% Written by: Brian O. Blanton
%

% DEFINE ERROR STRINGS
err1=['PLOTDROG requires 3, 4, or 5 arguments.'];
err2=['tstride argument to PLOTDROG must be a positive integer(s).'];
err3=['dstride argument to PLOTDROG must be a positive integer(s).'];
err4=['Lengths of x,y to PLOTDROG must be equal.'];
err5=['Path length inconsistent with number of drogues specified in PLOTDROG'];
err6=['ndrog argument to PLOTDROG must be a positive integer.'];
err7=['tstride argument to PLOTDROG must be less than number of timesteps.'];
err8=['dstride argument to PLOTDROG must be less than number of drogs.'];
err9=['Cell argument tstride to PLOTDROG must be of length 1'];
err10=['Cell argument dstride to PLOTDROG must be of length 1'];

% check arguments
if nargin < 3 | nargin > 5,error(err1),end

% If we're here, the first 3 required arguments exist.
if ndrog<0 | ~isint(ndrog), error(err6),end   

% Check x,y lengths
if length(x)~=length(y),error(err4),end

% Make sure length(x)/ndrog is an integer.
if ~isint(length(x)/ndrog),error(err5),end

% number of timesteps in length(x)
nts=length(x)/ndrog;

% Check remaining (optional) arguments
if nargin>3
   % Atleast tstride has been specified.
   % Is it a cell array?
   if isa(tstride,'cell')
      temp=tstride{1};
      if length(temp)~=1,error(err9),end
      tstride=temp;
   else
      if length(tstride)==1
         if tstride<1 | ~isint(tstride), error(err2),end 
	 tstride=1:tstride:nts;
      else
         tstride=sort(tstride(:));
         if min(tstride)<1 | ~isint(tstride), error(err2),end 
      end
   end
   
   if nargin==5
      % Is dstride a cell array?
      if isa(dstride,'cell')
	 temp=dstride{1};
	 if length(temp)~=1,error(err9),end
	 dstride=temp;
      else
	 if length(dstride)==1
            if dstride<1 | ~isint(dstride), error(err3),end 
	    dstride=1:dstride:ndrog;
	 else
            dstride=sort(dstride(:));
            if min(dstride)<1 | ~isint(dstride), error(err3),end 
	 end
      end
   else
      dstride=1:ndrog;
   end
else
   tstride=1:nts;
   dstride=1:ndrog;
end

% Check tstride,dstride against nts,ndrog 
if max(tstride)>nts,error(err7),end
if max(dstride)>ndrog,error(err8),end

% reshape x,y into matrices of dimension ndrog x ntimestep 
X=reshape(x,ndrog,nts)';
Y=reshape(y,ndrog,nts)';

% reduce by tstride
X=X(tstride,:);
Y=Y(tstride,:);

% reduce by dstride
X=X(:,dstride);
Y=Y(:,dstride);

% Add NaN row to bottom of X,Y
[m,n]=size(X);
NN=NaN*ones(size(1:n));
X=[X;NN];
Y=[Y;NN];

if length(tstride)==1
   hout=line(X,Y,'Tag','path','LineStyle','.','Marker','.','Color','r');
else
   hout=line(X,Y,'Tag','path');
end

% Fill output argument if returned.
if nargout==1,h=hout;,end

%
%        Brian O. Blanton
%        Department of Marine Science
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
%
%        Summer 1998
%

