function vizicq4_volume(command,option)

get_VIZICQ4_handles;
setptr(VIZICQ4_Figure,'watch')

switch command

case 'SelRegion'
% Mouse-driven region selection

%FORCE AXES ROTATION OFF
   set(VIZICQ4_Slicer_Rotation,'ToolTipString','Deactivate 3-D Rotation')
   set(VIZICQ4_Slicer_Rotation,'String','Rotate On')
   axes(VIZICQ4_Slice_Axes)
   rotate3d off

   delete(findobj(VIZICQ4_Figure,'Type','line','Tag','VIZICQ4_Region_Box'))
   %Make GRID Axes vis and current
   % move axes off-screen
   invisaxstdpos=get(VIZICQ4_LabCont,'UserData');
   axstdpos=get(VIZICQ4_DelCont,'UserData');
   set(VIZICQ4_Grid_Axes,'Position',axstdpos)
   set(VIZICQ4_Slice_Axes,'Position',invisaxstdpos)
   set(VIZICQ4_Grid_Axes,'Visible','on')
   set(VIZICQ4_Slice_Axes,'Visible','off')
   axes(VIZICQ4_Grid_Axes)
   str='Click and drag mouse to select region (lower-left to upper-right)';
   vizicq4_guts('Info',str)
   waitforbuttonpress;
   Pt1=get(gca,'CurrentPoint');
   rbbox([get(gcf,'CurrentPoint') 0 0],get(gcf,'CurrentPoint'));
   Pt2=get(gca,'CurrentPoint');
   vizicq4_guts('Info',[''])

   % Draw box around drogue grid
   line([Pt1(1) Pt2(1) Pt2(1) Pt1(1) Pt1(1)],...
        [Pt1(3) Pt1(3) Pt2(3) Pt2(3) Pt1(3)],'Tag','VIZICQ4_Region_Box')
     
   xmin=Pt1(1);
   ymin=Pt1(3);
   xmax=Pt2(1);
   ymax=Pt2(3);
 
   set(VIZICQ4_Region_Xmin,'String',xmin,'Enable','on')
   set(VIZICQ4_Region_Xmax,'String',xmax,'Enable','on')
   set(VIZICQ4_Region_Ymin,'String',ymin,'Enable','on')
   set(VIZICQ4_Region_Ymax,'String',ymax,'Enable','on')

case 'MapScalar'
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
   
   badlist={'HMID';'UMID';'VMID';'HOLD';'UOLD';'VOLD';'ZMID';'ZOLD'};
   if any(strcmp(badlist,field))
      vizicq4_guts('Error',['Field ' field ' not yet supported.']);
      break
   end       
   
   vizicq4_guts('Error',['']);
   
   % If the basis is not yet computed, compute it.
   basis_struct=get(VIZICQ4_Comp_Basis,'UserData');
   if isempty(basis_struct)
     vizicq4_volume('CompBasis')
     basis_struct=get(VIZICQ4_Comp_Basis,'UserData');
   end  
   
       jXY=basis_struct.jXY;
       X3D=basis_struct.X3D;
       Y3D=basis_struct.Y3D;
       Z3D=basis_struct.Z3D;
       phi=basis_struct.phi;
        N1=basis_struct.N1_3D;
        N2=basis_struct.N2_3D;
        B1=basis_struct.B1_3D;
        B2=basis_struct.B2_3D;
   FDZgrid=basis_struct.sgrid;
          
   fem_icq4_struct=get(VIZICQ4_Slice_Axes,'UserData');
   eval(['scalar=fem_icq4_struct.' eval('field') ';'])

   fem_grid_struct=get(VIZICQ4_Grid_Axes,'UserData');

   [m,n,p]=size(X3D);
   ztemp=reshape(Z3D(1,1,:),1,p)';
   S=map_scalar_mex5(phi,N1,N2,...
                     B1,B2,FDZgrid,...
		     ztemp,scalar,fem_grid_struct.e,jXY);
   
   % Store FD volume
   set(VIZICQ4_Map_Scalar,'UserData',S)
   
   vizicq4_guts('Info',['Field ' field ' mapped to FD grid.']);
   set(VIZICQ4_Ix_GO,'ForeGroundColor','g');
   set(VIZICQ4_Iy_GO,'ForeGroundColor','g');
   set(VIZICQ4_Iz_GO,'ForeGroundColor','g');
   set(VIZICQ4_ALL_GO,'ForeGroundColor','g');
  
case 'MakeVolume'
   basis_struct=get(VIZICQ4_Comp_Basis,'UserData');
   S=get(VIZICQ4_Map_Scalar,'UserData');
   if isempty(S)
      vizicq4_guts('Error','No Scalar Mapped');
   else  
   
      % move axes off-screen
      invisaxstdpos=get(VIZICQ4_LabCont,'UserData');
      axstdpos=get(VIZICQ4_DelCont,'UserData');
      set(VIZICQ4_Grid_Axes,'Position',invisaxstdpos)
      set(VIZICQ4_Slice_Axes,'Position',axstdpos)
      set(VIZICQ4_Grid_Axes,'Visible','off')
      set(VIZICQ4_Slice_Axes,'Visible','on')
      
      % Get current shade setting
      shadeval=find([get(VIZICQ4_Volume_Shading_Interp,'Value');
		    get(VIZICQ4_Volume_Shading_Flat,'Value');
		    get(VIZICQ4_Volume_Shading_Faceted,'Value')]);
      
      if isempty(shadeval),shadeval=3;,end
      switch shadeval
	 case 1
	    ec='none';fc='interp';
	 case 2
	    ec='none';fc='flat';
         case 3
	    ec='flat';fc='flat';
      end
      
      axes(VIZICQ4_Slice_Axes)
      hold on
      colormap(jet(16))
      jXY=basis_struct.jXY;
      X3D=basis_struct.X3D;
      Y3D=basis_struct.Y3D;
      Z3D=basis_struct.Z3D;
      ix=eval(get(VIZICQ4_Ix,'String'));
      iy=eval(get(VIZICQ4_Iy,'String'));
      iz=eval(get(VIZICQ4_Iz,'String'));
      xunique=X3D(1,:,1);
      yunique=Y3D(:,1,1);
      zunique=Z3D(1,1,:);
      if any(ix>length(xunique))
         vizicq4_guts('Error',['Ix exceeds x-discretization']);
      elseif any(iy>length(yunique))
         vizicq4_guts('Error',['Iy exceeds y-discretization']);
      elseif any(iz>length(zunique)) 
         vizicq4_guts('Error',['Iz exceeds z-discretization']);
      else
	 xslice=xunique(ix);
	 yslice=yunique(iy);
	 zslice=zunique(iz);
	 switch option
	 case 'X'
	    h=slice(X3D,Y3D,Z3D,S,xslice,0,0,'linear');
	    l=length(h);
	    delete(h([l-1 l]));h([l-1 l])=[];
         case 'Y'  
	    h=slice(X3D,Y3D,Z3D,S,0,yslice,0,'linear');
	    l=length(h);
	    delete(h([1 l]));h([1 l])=[];
         case 'Z'
	    h=slice(X3D,Y3D,Z3D,S,0,0,zslice,'linear');
	    delete(h(1:2));h(1:2)=[];
         case 'ALL'
	    h=slice(X3D,Y3D,Z3D,S,xslice,yslice,zslice,'linear');
	 otherwise,  
	    disp('Hole on Make Slice switch')   
	 end
	 set(h,'Tag','VIZICQ4_Volume');	    
	 set(h,'EdgeColor',ec,'FaceColor',fc);
      end
   end

case 'CompBasis'

   fem_grid_struct=get(VIZICQ4_Grid_Axes,'UserData');
   fem_icq4_struct=get(VIZICQ4_Slice_Axes,'UserData');
   if isempty(fem_grid_struct)
      vizicq4_guts('Error','No Domain Loaded');
   elseif isempty(fem_icq4_struct)
      vizicq4_guts('Error','No Icq4 File Loaded');
   else
   
      % Set "GO!!" buttins to RED
      set(VIZICQ4_Ix_GO,'ForeGroundColor','r');
      set(VIZICQ4_Iy_GO,'ForeGroundColor','r');
      set(VIZICQ4_Iz_GO,'ForeGroundColor','r');
      set(VIZICQ4_ALL_GO,'ForeGroundColor','r');
      drawnow
      
      vizicq4_guts('Info','Computing 3-D interp basis...');
      % Get Nx, Ny, Nz
      nx=eval(get(VIZICQ4_Nx,'String'));
      ny=eval(get(VIZICQ4_Ny,'String'));
      nz=eval(get(VIZICQ4_Nz,'String'));

      % Get region limits from Volume Popup
      minx=eval(get(VIZICQ4_Region_Xmin,'String'));
      maxx=eval(get(VIZICQ4_Region_Xmax,'String'));
      miny=eval(get(VIZICQ4_Region_Ymin,'String'));
      maxy=eval(get(VIZICQ4_Region_Ymax,'String'));
      minz=min(fem_grid_struct.z);
      maxz=0;
      
      S=fd_cube([nx ny nz],[minx maxx miny maxy minz maxz]);
      X3D=S.X3D;Y3D=S.Y3D;Z3D=S.Z3D;
      X2D=squeeze(X3D(:,:,1));
      Y2D=squeeze(Y3D(:,:,1));
      
      jXY=findelem(fem_grid_struct,[X2D(:) Y2D(:)]);
      jXY=reshape(jXY,nx+1,ny+1);
      phi=basis2d(fem_grid_struct,[X2D(:) Y2D(:)],jXY(:)) ;

      zmesh=fem_icq4_struct.ZMID;
      nnv=fem_icq4_struct.nnv;

      % Get bottom depth below X2D,Y2D
      temp=interp_scalar(fem_grid_struct,fem_grid_struct.z,X2D,Y2D,jXY);
      zbot=reshape(temp,nx+1,ny+1);
      temp=interp_scalar(fem_grid_struct,zmesh(:,nnv),X2D,Y2D,jXY);
      zeta=reshape(temp,nx+1,ny+1);
      
      dzbl=zmesh(1,2)-zmesh(1,1);
      FDZgrid=-sinegrid(zbot(:),zeta(:),nnv,dzbl);
      FDZgrid=reshape(FDZgrid,nx+1,ny+1,nnv);
      
      N1_3D=NaN*ones(size(X3D));
      B1_3D=NaN*ones(size(X3D));
      N2_3D=NaN*ones(size(X3D));
      B2_3D=NaN*ones(size(X3D));

%      [N1_3D,B1_3D,N2_3D,B2_3D]=comp_basis3d_mex5(FDZgrid,jXY,Z3D);
%      hwaitbar=waitbar(0.,'Computing Basis...');
      tic;
      for i=1:(nx+1)
%         waitbar((i-1)/nx)
         for j=1:(ny+1)
            if ~isnan(jXY(i,j))
               zref=FDZgrid(i,j,:);
               for k=1:nz+1
                  [b2,n2,b1,n1]=basis1d2(zref,Z3D(i,j,k));
                  N1_3D(i,j,k)=n1;
                  B1_3D(i,j,k)=b1;
                  N2_3D(i,j,k)=n2;
                  B2_3D(i,j,k)=b2;
               end
            end
         end
      end
      elapsed_time=toc;
%      delete(hwaitbar)
      
      % Store basis information on "Comp Basis" button UserData
      basis_struct.jXY=jXY;
      basis_struct.X3D=X3D;
      basis_struct.Y3D=Y3D;
      basis_struct.Z3D=Z3D;
      basis_struct.phi=phi;
      basis_struct.sgrid=FDZgrid;
      basis_struct.N1_3D=N1_3D;
      basis_struct.N2_3D=N2_3D;
      basis_struct.B1_3D=B1_3D;
      basis_struct.B2_3D=B2_3D;
      set(VIZICQ4_Comp_Basis,'UserData',basis_struct)
      str=['Done: elapsed time (sec) = ' num2str(elapsed_time) '. Map Scalar.'];
      vizicq4_guts('Info',str);
            
    %   otherwise,
    %      vizicq4_guts('Error','No mouse selection yet enabled');
    %   end
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
      set(VIZICQ4_Rotation,'String','Rotate Off')
      set(VIZICQ4_Rotation,'ToolTipString','Activate 3-D Rotation')
      axes(VIZICQ4_Slice_Axes)
      rotate3d on
   else     
      set(VIZICQ4_Rotation,'ToolTipString','Deactivate 3-D Rotation')
      set(VIZICQ4_Rotation,'String','Rotate On')
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
       set(VIZICQ4_Volume_Shading_Faceted,'Value',0)
       set(VIZICQ4_Volume_Shading_Interp,'Value',0)
     case 'Interp'
       shading interp
       set(VIZICQ4_Volume_Shading_Faceted,'Value',0)
       set(VIZICQ4_Volume_Shading_Flat,'Value',0)
     case 'Faceted'
       shading faceted
       set(VIZICQ4_Volume_Shading_Interp,'Value',0)
       set(VIZICQ4_Volume_Shading_Flat,'Value',0)
   end
   
case 'Pop'
   % Toggle the visibility of the volume popup figure
   % Get current visibility state.
   state=get(VIZICQ4_Volume_Fig,'Visible');
   if strcmp(state,'on')
     set(VIZICQ4_Volume_Fig,'Visible','off');
   else
     set(VIZICQ4_Volume_Fig,'Visible','on');
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

case 'DelVolume' 
   VIZICQ4_Slice=findobj(VIZICQ4_Slice_Axes,'Tag','VIZICQ4_Slice');
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
         if strcmp(target,'VIZICQ4_Slice')
            delete(gco)
         else
            vizicq4_guts('Info','Target NOT a VIZICQ4_Slice');
         end
      case 'all'
         delete(VIZICQ4_Slice)
      end
   end
case 'Close'
   set(VIZICQ4_Volume_Fig','Visible','off')
   
case 'Help'
   disp('Help on Volume not yet available')

otherwise
   disp('argument fallthrough in vizicq4_volume')
end
setptr(VIZICQ4_Figure,'arrow')
