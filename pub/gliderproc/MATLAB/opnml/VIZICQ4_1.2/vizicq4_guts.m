function vizicq4_guts(command,option)
%THIS IS THE guts OF VIZICQ4;  IT IS NOT CALLED DIRECTLY,
%BUT IS CALLED VIA CALLBACKS AND BUTTON DEFINITIONS
% 

get_VIZICQ4_handles;

setptr(VIZICQ4_Figure,'watch')

switch command

case 'initialize',       
%%%
%%%  INITIALIZATION CALLS 
%%%
   % option must exist and be a structure as:
   % option.grid=fem_grid_struct;
   % option.icq4=icq4name;
   % on initialization
   if ~exist('option')
      error('vizicq4_guts improperly called on init with non-struct option.')
   elseif ~isstruct(option)
      error('option to vizicq4_guts on init is not a structure')
   else
      if ~isfield(option,'grid')| ~isfield(option,'icq4')
         disp('option struct to vizicq4_guts does not contain ')
         disp('a fem_grid_struct and/or an icq4 filename')
	 return
      end
   end
   
case 'Load_Grid'   
   % Load the grid, and set the VIZICQ4_Grid_Axes  UserData to contain
   % the fem_grid_struct
   % Get the domain name typed into the "Domain :" ui
   domainname=get(VIZICQ4_Current_Domain,'String');
   if strcmp(domainname,'<enter domain name>')
      vizicq4_guts('Error','Domain Name not set.');
      return
   end
   % Try to load the grid files
   set(VIZICQ4_Info_Text,'String',['Loading grid for ' domainname])
   drawnow
   fem_grid_struct=loadgrid(domainname);
   if isempty(fem_grid_struct)
      vizicq4_guts('Error',['Grid files not found for ' domainname]);
      return
   end
   % Ensure fem_grid_struct is valid
   if ~is_valid_struct(fem_grid_struct)
      errstr=['Invalid fem_grid_struct in VIZICQ4_Current_Domain for '  domainname];
      vizicq4_guts('Error',errstr);
      return
   end

   % Force negative depths!!
   fem_grid_struct.z=-fem_grid_struct.z;
   
   % Attach element finding arrays
   fem_grid_struct=belint(fem_grid_struct);
   
   % Attach valid fem_grid_struct to figure UserData
   set(VIZICQ4_Grid_Axes,'UserData',fem_grid_struct)
   axes(VIZICQ4_Grid_Axes);
   drawelems(fem_grid_struct);
   plotbnd(fem_grid_struct);
   set(VIZICQ4_Error_Text,'String','')
   axes(VIZICQ4_Slice_Axes);
   drawelems3d(fem_grid_struct);
   plotbnd(fem_grid_struct);
%   hb=plotbnd(fem_grid_struct);

   % Load default region limits into place
   xmin=min(fem_grid_struct.x);
   xmax=max(fem_grid_struct.x);
   ymin=min(fem_grid_struct.y);
   ymax=max(fem_grid_struct.y);
   set(VIZICQ4_Region_Xmin,'String',xmin,'Enable','on')
   set(VIZICQ4_Region_Xmax,'String',xmax,'Enable','on')
   set(VIZICQ4_Region_Ymin,'String',ymin,'Enable','on')
   set(VIZICQ4_Region_Ymax,'String',ymax,'Enable','on')
   axes(VIZICQ4_Grid_Axes)
   line([xmin xmax xmax xmin xmin],...
        [ymin ymin ymax ymax ymin],'Tag','VIZICQ4_Region_Box')
   set(VIZICQ4_Info_Text,'String','Load in a .icq4 file.')
   
case 'Clear'
   switch option
      case 'Vectors'
	 delete(findobj(VIZICQ4_Figure,'Tag','VIZICQ4_Vectors'))
      case 'Volumes'
	 delete(findobj(VIZICQ4_Figure,'Tag','VIZICQ4_Volume'))
      case 'HSlices'
         delete(findobj(VIZICQ4_Figure,'Tag','VIZICQ4_Ribbon_HSlice'))
      case 'VSlices'
         delete(findobj(VIZICQ4_Figure,'Tag','VIZICQ4_Ribbon_VSlice'))
      otherwise,
         vizicq4_guts('Error','Bad Option to VIZICQ4_GUTS -->> Clear')
         setptr(VIZICQ4_Figure,'arrow')
         return      
   end    
   
case 'RotateRegion'

   theta=eval(get(VIZICQ4_DELTA_THETA,'String'))*pi/180;
   if abs(theta)<1e-3
      vizicq4_guts('Error','Theta too small.');
      break;
   end
   sign=-1;
   if strcmp(option,'CCW'),sign=1;,end


case 'Error'
   set(VIZICQ4_Error_Text,'String',option)
   set(VIZICQ4_Info_Text,'String','')
   
case 'Info'
   set(VIZICQ4_Info_Text,'String',option)
   set(VIZICQ4_Error_Text,'String','')
   
case 'Load_Icq4'   
   dirname=get(VIZICQ4_Current_Icq4_Dir,'String');
   set(VIZICQ4_Error_Text,'String','')
   set(VIZICQ4_Info_Text,'String','Reading .icq4 file...')
   drawnow
   switch option
   case 'Directory'
      % get directory name from VIZICQ4_Current_Icq4_Dir
      if exist(dirname)~=7
   	 vizicq4_guts('Info','');
   	 vizicq4_guts('Error',[dirname ' does not exist.']);
         return
      end
      % if dirname DOES exist, create a filelist of *.icq4 contents,
      % and change the style of VIZICQ4_Current_Icq4_Name to listbox
      % to allow mouse selection of .icq4 filename.
      d=dir([dirname '/*.icq4']);
      filenames={d.name}';
      if isempty(filenames)
   	 vizicq4_guts('Info','');
         set(VIZICQ4_Error_Text,'String','No .icq4 files in directory.')
        return
      end
      set(VIZICQ4_Current_Icq4_Name,'Style','listbox',...
                                    'String',filenames,...
				    'UserData',filenames,...
				    'Position',[0.78 .875 .18 .08])
				       
   case 'Name'
      %
      % Determine style of VIZICQ4_Current_Icq4_Name ui
      %
      style=get(VIZICQ4_Current_Icq4_Name,'Style');
      if strcmp(style,'edit')
         icq4name=get(VIZICQ4_Current_Icq4_Name,'String');
      else
         filelist=get(VIZICQ4_Current_Icq4_Name,'UserData');
	 value=get(VIZICQ4_Current_Icq4_Name,'Value');
	 icq4name=filelist{value};
      end
      
      % Load the .icq4 file, and set the VIZICQ4_Slice_Axes UserData to contain
      % the fem_icq4_struct
      % Get the icq4 filename typed into the "Icq4 name: " ui
      
      fullname=[dirname '/' icq4name];
      
      if ~exist(fullname)
   	 vizicq4_guts('Error',[icq4name ' does not exist.']);
	 % Enable uigetfile
	 [fname,fpath]=uigetfile('*.icq4','Select .icq4 file');
	 if fname==0
   	    vizicq4_guts('Info','No .icq4 file selected.');
      	    return
	 else
            fullname=[fpath '/' fname];
   	    set(VIZICQ4_Current_Icq4_Name,'String',fname);
      	    vizicq4_guts('Error','');
	    icq4name=fname;
	 end
      end
      fem_icq4_struct=read_icq4(fullname);
      
      
      % Compute density from Q4_EQNSTATE2
      fem_icq4_struct.RHO=q4_eqnstate2(fem_icq4_struct.TMPMID,fem_icq4_struct.SALMID);
      set(VIZICQ4_Info_Text,'String',[icq4name ' read.'])
      set(VIZICQ4_icq4_select_button,'enable','on')
      set(VIZICQ4_Slice_Axes,'UserData',fem_icq4_struct);
    otherwise
       disp('Option hole in switch in vizicq4_guts, LoadIcq4')
    end
case 'Icq4_Info'
   fem_icq4_struct=get(VIZICQ4_Slice_Axes,'UserData');
   if isempty(fem_icq4_struct)
      set(VIZICQ4_Icq4_Info_Fig,'Visible','off');
   else
      % Toggle visibility of info figure
      state=get(VIZICQ4_Icq4_Info_Fig,'Visible');
      if strcmp(state,'on')
         set(VIZICQ4_Icq4_Info_Fig,'Visible','off');
         setptr(VIZICQ4_Figure,'arrow')
         break;
      else
         set(VIZICQ4_Icq4_Info_Fig,'Visible','on');
      end
      nn=fem_icq4_struct.nn;
      nnv=fem_icq4_struct.nnv;
      
      set(VIZICQ4_Icq4_Info_Line(1),'String',fem_icq4_struct.codename)
      set(VIZICQ4_Icq4_Info_Line(2),'String',fem_icq4_struct.casename)
      set(VIZICQ4_Icq4_Info_Line(3),'String',fem_icq4_struct.inqfilename)
      set(VIZICQ4_Icq4_Info_Line(4),'String',fem_icq4_struct.initcondname)
      set(VIZICQ4_Icq4_Info_Line(5),'String',int2str(nn))
      set(VIZICQ4_Icq4_Info_Line(6),'String',int2str(nnv))
      set(VIZICQ4_Icq4_Info_Line(7),'String',int2str(fem_icq4_struct.day))
      set(VIZICQ4_Icq4_Info_Line(8),'String',int2str(fem_icq4_struct.month))
      set(VIZICQ4_Icq4_Info_Line(9),'String',int2str(fem_icq4_struct.year))
      set(VIZICQ4_Icq4_Info_Line(10),'String',int2str(fem_icq4_struct.curr_seconds))
      string2d=['[' int2str(nn)  ' double]'];
      string3d=['[' int2str(nn) 'x' int2str(nnv) ' double]'];
      set(VIZICQ4_Icq4_Info_Line(11),'String',string3d)
      set(VIZICQ4_Icq4_Info_Line(12),'String',string3d)
      set(VIZICQ4_Icq4_Info_Line(13),'String',string3d)
      set(VIZICQ4_Icq4_Info_Line(14),'String',string3d)
      set(VIZICQ4_Icq4_Info_Line(15),'String',string3d)
      set(VIZICQ4_Icq4_Info_Line(16),'String',string3d)
      set(VIZICQ4_Icq4_Info_Line(17),'String',string3d)
      set(VIZICQ4_Icq4_Info_Line(18),'String',string3d)
      set(VIZICQ4_Icq4_Info_Line(19),'String',string3d)

   end
   
case 'Toggle_Axes'
   % Determine which axes is currently visible
   state=get(VIZICQ4_Grid_Axes,'Visible');
   invisaxstdpos=get(VIZICQ4_LabCont,'UserData');
   axstdpos=get(VIZICQ4_DelCont,'UserData');
   if strcmp(state,'on')
      set(VIZICQ4_Grid_Axes,'Visible','off')
      set(VIZICQ4_Slice_Axes,'Visible','on')
      set(VIZICQ4_Grid_Axes,'Position',invisaxstdpos)
      set(VIZICQ4_Slice_Axes,'Position',axstdpos)
   else
      set(VIZICQ4_Grid_Axes,'Visible','on')
      set(VIZICQ4_Slice_Axes,'Visible','off')
      set(VIZICQ4_Grid_Axes,'Position',axstdpos)
      set(VIZICQ4_Slice_Axes,'Position',invisaxstdpos)
   
   end
   
case 'Terminate'
   delete([VIZICQ4_Figure VIZICQ4_Volume_Fig VIZICQ4_Slicer_Fig VIZICQ4_Icq4_Info_Fig])
   return
case 'print'
   disp('No print function yet')
case 'Help'
%   switch option
   disp('No help yet')    

case 'ZContours'
   fem_grid_struct=get(VIZICQ4_Grid_Axes,'UserData');
   if isempty(fem_grid_struct)
      vizicq4_guts('Error','No grid defined yet.')
      break
   end
   vals=get(VIZICQ4_Contour_Vals,'String');
   if strcmp(vals,'linspace(zmin,zmax,7)')
     % Determine default depth contour values
      zmax=max(fem_grid_struct.z);
      zmin=min(fem_grid_struct.z);
      vals=linspace(zmin,zmax,7);
      vals([1 7])=[];
   else     
      vals=['[' vals ']'];
      vals=eval(vals);
   end   
   lcontour(fem_grid_struct,'z',vals); 
   vizicq4_guts('Error','')
   vizicq4_guts('Info','')
case 'DelCont'
   ch_gca=get(VIZICQ4_Grid_Axes,'Ch');        %  children of the current axes
   cont_objs=findobj(ch_gca,'Tag','contour');
   delete(cont_objs);
   ch_gca=get(VIZICQ4_Grid_Axes,'Ch');        %  children of the current axes
   textobjs=findobj(ch_gca,'Type','text');
   delete(textobjs);

case 'LabCont'
   fem_grid_struct=get(VIZICQ4_Grid_Axes,'UserData');
   if isempty(fem_grid_struct)
      vizicq4_guts('Error','No grid defined yet.')
   % Search for contours to label
   elseif isempty(findobj(VIZICQ4_Grid_Axes,'Tag','contour'))
      vizicq4_guts('Error','No contours to label yet.')
   else

   private_lc(VIZICQ4_Figure,VIZICQ4_Grid_Axes,VIZICQ4_Info_Text,VIZICQ4_Error_Text)
      vizicq4_guts('Error','')
      vizicq4_guts('Info','')
   end
   
otherwise,
   disp('Command hole in switch in vizicq4_guts')
end

setptr(VIZICQ4_Figure,'arrow')
