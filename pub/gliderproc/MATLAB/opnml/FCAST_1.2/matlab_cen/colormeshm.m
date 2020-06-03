%
% COLORMESH2D draw a FEM mesh in 2-d colored by a scalar quantity.
%
%     Input : elems     - element list (.ele or .tri type) (required)
%             x         - x-coordinate list (required)
%             y         - y-coordinate list (required)
%             Q         - scalar to color with (optional)
%             "nofill"  - flag (optional)
%
%    Output : hp - vector of handles, one for each element patch drawn.
%
%             COLORMESH2D colors the mesh using the scalar Q.  If Q
%             is omitted from the argument list, COLORMESH2D draws
%             the element connectivity in black and white.
%
%             The flag "nofill" will prevent COLORMESH3D from filling 
%             the interior of surface triangles.
%
% NOTE: This is one of the few (2 or 3) OPNML MATLAB functions that 
%       deletes existing patch objects in  the current axes before 
%       rendering the surface.  This is to avoid having an unmanageable 
%       number of patch objects on the screen.  
%
%       COLORMESH2D sets the colormap to jet if it has not already
%       been done.  This colormap does not "wrap" around. 
%
%   Call as : hp=colormesh2d(elems,x,y,Q,'nofill')
%
function rv1=colormesh2d(elems,x,y,Q,sarg)

% DEFINE ERROR STRINGS
err1=['more than 1 column in x-coordinate vector.'];
err2=['more than 1 column in y-coordinate vector.'];
err3=['node coordinate vectors must be the same length'];
err4=['scalar used to color must be 1-D'];
err5=['length of scalar must be the same length as coordinate vectors'];
err9=str2mat(' ','??? Error using ==> colormesh2d',...
             'COLORMESH2D needs 3, 4, or 5 input arguments:',...
             'Input : elems - element list (.ele or .tri type)',...
             '        x     - x-coordinate list',...
             '        y     - y-coordinate list',...
             '        Q     - scalar to color with (optional)',...
             '    "nofill"  - no-interior triangles flag (optional)',...
             ' ');
err10=str2mat(' ','??? Error using ==> colormesh2d',...
             'COLORMESH2D optional flag argument must',...
             'be the string "nofill".',...
             'Type "help colormesh2d"',...
             ' ');
err11=str2mat(' ','??? Error using ==> colormesh2d',...
             'COLORMESH2D optional flag argument "nofill"',...
             'can only be used along with Q-specification.',...
             'Type "help colormesh2d"',...
             ' ');
                          
if nargin <3|nargin >5
   disp(err9)
   return
end

% CHECK SIZE OF X-COORDINATE VECTOR
% NX = NUMBER OF X-COORDINATE VALUES, S = # OF COLS
%
[nx,s]=size(x);           
if s~=1&nx~=1
   error(err1);
end
 
% CHECK SIZE OF Y-COORDINATE VECTOR
% NY = NUMBER OF Y-COORDINATE VALUES, S = # OF COLS
%
[ny,s]=size(y);           
if s~=1&ny~=1
   error(err2);
end
x=x(:);
y=y(:);

if length(x) ~= length(y)
   error(err3)
end

if exist('Q')
   if isstr(Q)
      disp(err11)
      return
   end
   if exist('sarg')
      if ~strcmp(sarg,'nofill')
         disp(err10)
         return
      end
   end

   [nrowQ,ncolQ]=size(Q);
   if ncolQ>1,error(err4);,end
   if nrowQ ~= length(x)
      error(err5)
   end
   Q=Q(:);

   [nelems,ncol]=size(elems);   % nelems,ncol = number of elements, columns
   if ncol==4
      elems=elems(:,2:4);
   elseif ncol~=3
      errstr=str2mat(['COLORMESH2D is confused by the number of columns in '],...
                     ['the element file.  It must be only three (i1 i2 i3) '],...
                     ['or four (node# i1 i2 i3)']);
      disp('??? Error using ==> colormesh2d');
      disp(errstr);
      return;
   end 

   elems=elems';
   [m,n]=size(elems);
   xt=x(elems);
   xt=reshape(xt,m,n);
   yt=y(elems);
   yt=reshape(yt,m,n);
   Qt=Q(elems);
   Qt=reshape(Qt,m,n);

   % delete previous colorsurf objects
%   delete(findobj(gca,'Type','patch','Tag','colorsurf'))
   rh_ch=get(0,'Children');
   ColorsurfFigure=findobj(rh_ch,'flat','Type','figure','Tag','ColorsurfFigure');
   if ~isempty(ColorsurfFigure)
      ud=get(ColorsurfFigure,'UserData');
      if ~isempty(ud)
         if isobj(ud(1)),delete(ud);,end
         delete(ColorsurfFigure);
      end
   end  
  
   colormap(jet);
%   colormenu2;
   if exist('sarg')
      if strcmp(sarg,'nofill')
         hp=patch(xt,yt,Qt,'EdgeColor','interp',...
                  'FaceColor','none','Tag','colorsurf');
      end
   else
      hp=patch(xt,yt,Qt,'EdgeColor','none','FaceColor','interp','Tag','colorsurf');
   end

%   hp=patch(xt,yt,Qt,'EdgeColor','none','FaceColor','interp','Tag','colorsurf');
% Create invisible figure; store patch handles in figure's UserData.
%   fig=gcf;
%   figure('Visible','off','UserData',hp,'Tag','ColorsurfFigure');
%   figure(fig);
   
%   if isempty(findobj(gcf,'Type','axes','Tag','colorbar'))
%      hc=colorbar('horiz');
%      set(hc,'Tag','colorbar');
%   else
%      colorbar;
%   end
else
   hp=drawelems(elems,x,y);
end

% Output if requested.
if nargout==1,rv1=hp;,end

