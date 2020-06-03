function h=ccplot3(x,y,z,c,c_axis,symbol,marker_size)
%
%---------------------------------------------------------------------------
% CCPLOT3(X,Y,Z,C,C_AXIS,SYMBOL,MARKER_SIZE)
% ccplot        Creates a color-coded plot.
%
%       H=CCPLOT(X,Y,Z,C,C_AXIS,SYMBOL,MARKER_SIZE) creates a color-coded plot of
%               vector Z with respect to vectors X and Y using C_AXIS to map
%               values of Z to the colormap of the current figure. Data is
%               plotted using SYMBOL's of MARKER_SIZE.
%
%               If C_AXIS is an empty vector CCPLOT calculates C_AXIS to be
%               [min(z) max(z)].
%
%       example...
%                       x = [0:.1:100];               
%                       y = sin(x);                   
%                       z = rand(1,length(y)) + 10.^y;
%                       subplot(2,1,1);plot3(x,y,z)                  
%                       subplot(2,1,2);ccplot(x,y,z,[],'.',20);      
%
  
  % Author:       Trevor Cooper, Marine Life Research Group/SIO
  %               tcooper@ucsd.edu
  %               December 8, 1995.
    
  if(length(c_axis) == 0)
    isfin = find(finite(z));
    c_axis = [min(c(isfin)) max(c(isfin))]
  end
  
  cmap = get(gcf,'colormap'); 
  
  index = floor( (c-c_axis(1)) / ((c_axis(2)-c_axis(1)) / size(cmap,1)));
  
  too_small = find(index<1);
  if(length(too_small) > 0)
    index(too_small)=ones(length(too_small),1);
  end
  
  too_big = find(index>size(cmap,1));
  if(length(too_big) > 0)
    index(too_big)=ones(length(too_big),1)*size(cmap,1);
  end
  
  for j=1:size(cmap,1)
    matched=find(index == j);
    if(length(matched) > 0)
      h=plot3(x(matched), y(matched), z(matched), symbol, 'color', cmap(j,:), ...
           'markersize', marker_size, 'tag', 'ccplot');
      hold on;
    end
  end
  patch(nan,nan,nan); set(gca,'clim',c_axis);
  hold off;
