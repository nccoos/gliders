%
% DRAWPERPVEC draw vectors perpendicular to axis
%
% DRAWVEC drawvec(xo,yo,wx,wy,lcolor) is a routine to 
%         draw perp vectors. This is a fairly low-level routine
%         in that in does no scaling to the vectors.  This function
%         is called primarily by PERPVECPLOT and returns the handle
%         of the vector object drawn.  Diameter of the object drawn
%	  is the magnitude of the perpendicular vector.
%
% Inputs: xo,yo  - vector origins; arrow eminates from this point
%         wm     - vector magnitudes
%         lcolor - linecolor , 'r' = red, etc.
%
% Outputs: hc	 - the handle to the ellipse drawn
%	   hp    - the handle to the dot/x object drawn
%
% Call as:  [hc,hp]=drawperpvec(xo,yo,wx,wy,lcolor)
%
% Calls: plots/ell_east
%
% Catherine R. Edwards
% Last modified: 31 Jan 2004
%
   function [hc,hp]=drawperpvec(xo,yo,wx,wy,lcolor)

% columnate the input vectors 
   xo=xo(:);
   yo=yo(:);
   wx=wx(:); wy=wy(:);

% get hold status of figure
   holdstr=get(gca,'nextplot');
   if(strcmp(holdstr,'replace'))
     hold on;
   end

% compute and draw circle - diameter of circle=wm
   hc=ell_east(xo,yo,abs(wx)/2,abs(wy)/2,zeros(size(xo)),lcolor,300);
   set(hc,'color',lcolor);
   
% draw dot, lines from dot outward (if negative)
   lt0=find(wx<0); ge0=find(wx>=0);
   
   hp(ge0)=plot(xo(ge0),yo(ge0),'.'); set(hp(ge0),'color',lcolor);
   
%  get x/y points at angle equivalent to pi/2 on a circle

   dx=(wx/2)*cos(pi/4); dy=(wy/2)*sin(pi/4);
   x=[xo(lt0)-dx xo(lt0)+dx nan*xo(lt0) xo(lt0)-dx xo(lt0)+dx nan*xo(lt0)]';
   y=[yo(lt0)-dy yo(lt0)+dy nan*xo(lt0) yo(lt0)+dy yo(lt0)-dy nan*xo(lt0)]';

   x=x(:);
   y=y(:);
   hp(lt0)=line(x,y,'LineStyle','-','Color',lcolor);
   set(hp,'color',lcolor);
   
   set(gca,'nextplot',holdstr);
