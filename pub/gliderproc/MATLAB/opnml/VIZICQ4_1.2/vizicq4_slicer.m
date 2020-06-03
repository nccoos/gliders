function vizicq4_slicer(command,option)

get_VIZICQ4_handles;
setptr(VIZICQ4_Figure,'watch')

switch command

case 'SelRegion'
% Mouse-driven region selection

%   delete(findobj(VIZICQ4_Figure,'Type','line','Tag','VIZICQ4_Transect_Line'))

   %FORCE AXES ROTATION OFF
   set(VIZICQ4_Slicer_Rotation,'ToolTipString','Deactivate 3-D Rotation')
   set(VIZICQ4_Slicer_Rotation,'String','Rotate On')
   axes(VIZICQ4_Slice_Axes)
   rotate3d off

   %Make GRID Axes vis and current
   % move axes off-screen
   invisaxstdpos=get(VIZICQ4_LabCont,'UserData');
   axstdpos=get(VIZICQ4_DelCont,'UserData');
   set(VIZICQ4_Grid_Axes,'Position',axstdpos)
   set(VIZICQ4_Slice_Axes,'Position',invisaxstdpos)
   set(VIZICQ4_Grid_Axes,'Visible','on')
   set(VIZICQ4_Slice_Axes,'Visible','off')
   axes(VIZICQ4_Grid_Axes)
   
   fem_grid_struct=get(VIZICQ4_Grid_Axes,'UserData');
   
   switch option
   case 'ArbSlice'
      str='Click and drag mouse to select region (lower-left to upper-right)';
      vizicq4_guts('Info',str)
      waitforbuttonpress;
      Pt1=get(gca,'CurrentPoint');
      rbbox([get(gcf,'CurrentPoint') 0 0],get(gcf,'CurrentPoint'));
      Pt2=get(gca,'CurrentPoint');
      vizicq4_guts('Info',[''])

      x1=Pt1(1);
      y1=Pt1(3);
      x2=Pt2(1);
      y2=Pt2(3);

   case {'XSlice','YSlice'}
      str='Click mouse at Minimum (X|Y)-Location to make slice';
      vizicq4_guts('Info',str)
      waitforbuttonpress;
      Pt1=get(gca,'CurrentPoint');
      x1=Pt1(1);y1=Pt1(3);
	 
      minx=min(fem_grid_struct.x);
      maxx=max(fem_grid_struct.x);
      miny=min(fem_grid_struct.y);
      maxy=max(fem_grid_struct.y);
      switch option
      case 'XSlice'
         % verify x1
	 if x1<minx | x1>maxx
            vizicq4_guts('Error','Selected X not within Domain X- Range')
            setptr(VIZICQ4_Figure,'arrow')
	    return
	 end
	 x2=x1;
	 y2=max(fem_grid_struct.y);
      case 'YSlice'
	 % verify y
	 if y1<miny | y1>maxy
            vizicq4_guts('Error','Selected Y not within Domain Y- Range')
            setptr(VIZICQ4_Figure,'arrow')
            return
	 end
	 y2=y1;      
	 x2=max(fem_grid_struct.x);
      otherwise,
         vizicq4_guts('Error','Bad option to SelRegion')
         setptr(VIZICQ4_Figure,'arrow')
         return    
      end
   otherwise,
      vizicq4_guts('Error','Bad option to SelRegion')
      setptr(VIZICQ4_Figure,'arrow')
      return    
   end

   % Make sure atleast one end-point is within domain
   if all(isnan([findelem(fem_grid_struct,[x1 y1]);
		 findelem(fem_grid_struct,[x2 y2])]))
      vizicq4_guts('Error',['Both end-points are outsize of domain.' ...
		    ' Try again.'])
      setptr(VIZICQ4_Figure,'arrow')
      return
   end
   % Draw line for transect position
   line([x1 x2],[y1 y2],'Tag','VIZICQ4_Transect_Line')
   set(VIZICQ4_Slice_X1,'String',x1,'Enable','on')
   set(VIZICQ4_Slice_X2,'String',x2,'Enable','on')
   set(VIZICQ4_Slice_Y1,'String',y1,'Enable','on')
   set(VIZICQ4_Slice_Y2,'String',y2,'Enable','on')
   set(VIZICQ4_Slice_DL,'Enable','on')

case 'MakeVSlice'

   % Determine which component of the .icq4 has been selected.
   state=get(VIZICQ4_icq4_select_button,'Value');
   field=[];
   for i=1:length(state)
      if state{i}==1
         field=get(VIZICQ4_icq4_select_button(i),'String');
	 break
      end
   end
   if isempty(field)
      vizicq4_guts('Error','No Icq4 Var selected.');
      break
   end
   vizicq4_guts('Error',['']);
   
   fem_icq4_struct=get(VIZICQ4_Slice_Axes,'UserData');
   eval(['scalar=fem_icq4_struct.' eval('field') ';'])

   fem_grid_struct=get(VIZICQ4_Grid_Axes,'UserData');

   % Get transect endpoints
   x1=get(VIZICQ4_Slice_X1,'String');
   if (isempty(x1) | strcmp(x1,'<>'))
      vizicq4_guts('Error',['No Transect Coords. Defined']);
      setptr(VIZICQ4_Figure,'arrow')    
      break
   end
   x1=eval(x1);
   x2=eval(get(VIZICQ4_Slice_X2,'String'));
   y1=eval(get(VIZICQ4_Slice_Y1,'String'));
   y2=eval(get(VIZICQ4_Slice_Y2,'String'));
   dl=eval(get(VIZICQ4_Slice_DL,'String'));
   nc=eval(get(VIZICQ4_Slice_NC,'String'));

   R=searibbon2(fem_icq4_struct,fem_grid_struct,[x1 x2],[y1 y2],dl);
   
   % move grid axes off-screen, slice axes on screen
   invisaxstdpos=get(VIZICQ4_LabCont,'UserData');
   axstdpos=get(VIZICQ4_DelCont,'UserData');
   set(VIZICQ4_Grid_Axes,'Position',invisaxstdpos)
   set(VIZICQ4_Slice_Axes,'Position',axstdpos)
   set(VIZICQ4_Grid_Axes,'Visible','off')
   set(VIZICQ4_Slice_Axes,'Visible','on')
   axes(VIZICQ4_Slice_Axes)

   hold on
   eval(['scalar=R.' eval('field') ';'])  
   h=surf(R.x,R.y,R.ZMID,scalar);
   colormap(jet(nc))
   set(h,'Tag','VIZICQ4_Ribbon_VSlice')
   
   % Compute some rotated velocity information
   %%%%%%%%%%%%%%  ROTATE VELOCITY INTO TRANSECT PLANE %%%%%%%%%%%%%%%%%
   ind=find(~isnan(R.UZMID(:,1)));
   ind1=find(~isnan(R.UZMID(:)));
   if (abs(x2-x1)<1e-7)   % x-cut basically vertical (constant x)
      tgv=pi/2;
   else
      tgv=atan((y2-y1)/(x2-x1));
   end
   u=R.UZMID(ind,:);
   v=R.VZMID(ind,:);
   [u,v]=rot(u,v,tgv);
   xx=R.x(:);yy=R.y(:);zz=R.ZMID(ind1);
   uu=R.UZMID(ind,:);uu=uu(:);
   vv=R.VZMID(ind,:);vv=vv(:);
   ww=R.WZMID(ind,:);ww=ww(:);
   
   if (get(VIZICQ4_Slice_VVectors,'Value'))
      hvec=quiver3(xx,yy,zz,uu,vv,ww,2);
      set(hvec,'Tag','VIZICQ4_Vectors','Color','k')
   end 
   % Also display transect in a new figure, dist vs. depth
   figure
   set(gcf,'Name','VIZICQ4 - Slice')

   % U POSITIVE TO RIGHT OF TRANSECT DIRECTION (OUT OF SCREEN)
   % V POSITIVE ALONG TRANSECT
   pcolor(R.d(ind,:),R.ZMID(ind,:),reshape(u,size(R.ZMID(ind,:))))
   xlabel('Distance along transect (meters)')
   ylabel('Depth (meters)')
   shading interp
   hcb=colorbar;
   curax=gca;
   axes(hcb)
   ylabel('Through-Transect Velocity (m/sec)')
   axes(curax)
   ind1=find(~isnan(R.UZMID(:)));
   hvec=vecplotstick(R.d(ind1),R.ZMID(ind1),v,R.WZMID(ind1),.5,'k',10,'m/s');
   title('Transect ')
   line(R.d(:,1),R.ZMID(:,1),'Color','k','LineStyle','-','linewidth',2)
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   hold on
   [c,h]=contour(R.d(ind,:),R.ZMID(ind,:),R.TMPMID(ind,:),[5:.5:15],'y');
   if ~isempty(h)
      ht=clabel(c,h);
      set(ht,'FontSize',15,'FontWeight','bold')
      set(h,'linewidth',2)
   end
   [c,h]=contour(R.d(ind,:),R.ZMID(ind,:),R.SALMID(ind,:),[20:.5:40],'w');
   if ~isempty(h)
      ht=clabel(c,h);
      set(ht,'FontSize',15,'FontWeight','bold')
      set(h,'linewidth',2)
   end 
   % Add KILL button
   uicontrol(gcf,'Style','push',...
                 'Units','normalized',...
	         'Position',[.9 0 .1 .1],'String','KILL','CallBack','close(gcf)');
   drawnow 

case 'MakeHSlice'
   % Determine which component of the .icq4 has been selected.
   state=get(VIZICQ4_icq4_select_button,'Value');
   field=[];
   for i=1:length(state)
      if state{i}==1
         field=get(VIZICQ4_icq4_select_button(i),'String');
	 break
      end
   end
   if isempty(field)
      vizicq4_guts('Error','No Icq4 Var selected.');
      break
   end
   vizicq4_guts('Error',['']);
   
   fem_icq4_struct=get(VIZICQ4_Slice_Axes,'UserData');
   eval(['scalar=fem_icq4_struct.' eval('field') ';'])
   fem_grid_struct=get(VIZICQ4_Grid_Axes,'UserData');

   % Loop over depth vector zval
   % Get slice depth
   zval=get(VIZICQ4_Slice_Z,'String');
   if isempty(zval)| strcmp(zval,'<>')
      vizicq4_guts('Error','No depth values specified.')
      setptr(VIZICQ4_Figure,'arrow')
      return      
   end
   zval=eval(zval);
      
   % Make sure zval between zmax,zmin
   maxz=max(max(fem_icq4_struct.ZMID));
   minz=min(min(fem_icq4_struct.ZMID));
   if zval<minz | zval>maxz
      str=['Zval of ' num2str(zval) ' not within' ...
		    ' Depth Range; [' num2str(minz) ',' num2str(maxz) ']'];
      vizicq4_guts('Error',str)
      setptr(VIZICQ4_Figure,'arrow')
      return
   end
   
   qlev=horzslicefem(fem_icq4_struct.ZMID,scalar,zval);
   qlevu=horzslicefem(fem_icq4_struct.ZMID,fem_icq4_struct.UZMID,zval);
   qlevv=horzslicefem(fem_icq4_struct.ZMID,fem_icq4_struct.VZMID,zval);
   qlevw=horzslicefem(fem_icq4_struct.ZMID,fem_icq4_struct.WZMID,zval);
   
   % move grid axes off-screen, slice axes on screen
   invisaxstdpos=get(VIZICQ4_LabCont,'UserData');
   axstdpos=get(VIZICQ4_DelCont,'UserData');
   set(VIZICQ4_Grid_Axes,'Position',invisaxstdpos)
   set(VIZICQ4_Slice_Axes,'Position',axstdpos)
   set(VIZICQ4_Grid_Axes,'Visible','off')
   set(VIZICQ4_Slice_Axes,'Visible','on')
   axes(VIZICQ4_Slice_Axes)

   nc=eval(get(VIZICQ4_Slice_NC,'String'));
   colormap(jet(nc))
   hp=colormesh2d(fem_grid_struct,qlev,nc);
   set(hp,'ZData',zval*ones(size(get(hp,'XData'))));
   set(hp,'Tag','VIZICQ4_Ribbon_HSlice')
   if (get(VIZICQ4_Slice_HVectors,'Value'))
      hold on
      hvec3=quiver3(fem_grid_struct.x,...
 	   fem_grid_struct.y,...
           zval*ones(size(fem_grid_struct.x)),...
           qlevu,qlevv,qlevw);
      hold off
      set(hvec3,'Color','k','Tag','VIZICQ4_Vectors')
   end 
   
case 'Rotate_Toggle'
   state=get(VIZICQ4_Rotation,'String');
   if strcmp(state,'Rotate On') 
      % move axes off-screen
      invisaxstdpos=get(VIZICQ4_LabCont,'UserData');
      axstdpos=get(VIZICQ4_DelCont,'UserData');
      set(VIZICQ4_Grid_Axes,'Position',invisaxstdpos)
      set(VIZICQ4_Slice_Axes,'Position',axstdpos)
      set(VIZICQ4_Grid_Axes,'Visible','off')
      set(VIZICQ4_Slice_Axes,'Visible','on')
      set(VIZICQ4_Slicer_Rotation,'String','Rotate Off')
      set(VIZICQ4_Slicer_Rotation,'ToolTipString','Activate 3-D Rotation')
      axes(VIZICQ4_Slice_Axes)
      rotate3d on
   else     
      set(VIZICQ4_Slicer_Rotation,'ToolTipString','Deactivate 3-D Rotation')
      set(VIZICQ4_Slicer_Rotation,'String','Rotate On')
      axes(VIZICQ4_Slice_Axes)
      rotate3d off
   end

case 'Reset_View'
   axes(VIZICQ4_Grid_Axes);view(2)
   axes(VIZICQ4_Slice_Axes);view(2)
 
case 'Shading' 
   % move axes off-screen
   invisaxstdpos=get(VIZICQ4_LabCont,'UserData');
   axstdpos=get(VIZICQ4_DelCont,'UserData');
   set(VIZICQ4_Grid_Axes,'Position',invisaxstdpos)
   set(VIZICQ4_Slice_Axes,'Position',axstdpos)
   set(VIZICQ4_Grid_Axes,'Visible','off')
   set(VIZICQ4_Slice_Axes,'Visible','on')
   axes(VIZICQ4_Slice_Axes)
   switch option
     case 'Flat'
       shading flat
       set(VIZICQ4_Slicer_Shading_Faceted,'Value',0)
       set(VIZICQ4_Slicer_Shading_Interp,'Value',0)
     case 'Interp'
       shading interp
       set(VIZICQ4_Slicer_Shading_Faceted,'Value',0)
       set(VIZICQ4_Slicer_Shading_Flat,'Value',0)
     case 'Faceted'
       shading faceted
       set(VIZICQ4_Slicer_Shading_Interp,'Value',0)
       set(VIZICQ4_Slicer_Shading_Flat,'Value',0)
   end
   
case 'Pop'
   % Toggle the visibility of the slicer popup figure
   % Get current visibility state.
   state=get(VIZICQ4_Slicer_Fig,'Visible');
   if strcmp(state,'on')
     set(VIZICQ4_Slicer_Fig,'Visible','off');
   else
     set(VIZICQ4_Slicer_Fig,'Visible','on');
   end  
 
case 'Colorbar' 
   delete(VIZICQ4_Colorbar_Axes)
   h=axes('Parent',VIZICQ4_Figure,...
         'Units','normalized',...
 	 'Position',[.825 .15 .15 .025],...
	 'Tag','VIZICQ4_Colorbar_Axes');
   
   axes(VIZICQ4_Slice_Axes)
   colorbar(h)
   set(h,'Tag','VIZICQ4_Colorbar_Axes')

case 'DelSlice' 
   VIZICQ4_Slice=findobj(VIZICQ4_Slice_Axes,'Tag','VIZICQ4_Ribbon_HSlice');
   VIZICQ4_Slice=[VIZICQ4_Slice;findobj(VIZICQ4_Slice_Axes,'Tag','VIZICQ4_Ribbon_VSlice')];
   if isempty(VIZICQ4_Slice)
      vizicq4_guts('Info','No Slices to Delete');
   else
      set(VIZICQ4_Rotation,'ToolTipString','Deactivate 3-D Rotation')
      set(VIZICQ4_Rotation,'String','Rotate On')
      rotate3d off
      switch option
      case 'one'
         vizicq4_guts('Info','Click on Slice to Delete');
         waitforbuttonpress;
         target=get(gco,'Tag');
         if strcmp(target,'VIZICQ4_Ribbon_HSlice') | strcmp(target,'VIZICQ4_Ribbon_VSlice')
            delete(gco)
         else
            vizicq4_guts('Info','Target NOT a VIZICQ4_Ribbon_{H|V}Slice');
         end
      case 'all'
         delete(VIZICQ4_Slice)
      end
   end
case 'Close'
   set(VIZICQ4_Slicer_Fig','Visible','off')
   
case 'Help'
   disp('Help on Slicer not yet available')

otherwise
   disp('Argument fallthrough in vizicq4_slicer')
end
setptr(VIZICQ4_Figure,'arrow')
