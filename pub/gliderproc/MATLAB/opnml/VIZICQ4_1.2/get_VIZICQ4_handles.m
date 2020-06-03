% Script for VIZICQ4 to retrieve all needed handles starting
% from (and including) the VIZICQ4 parent figure

VIZICQ4_Figure=findobj(0,'Type','figure','Tag','VIZICQ4_Figure');
VIZICQ4_Grid_Axes=findobj(VIZICQ4_Figure,'Type','axes','Tag','VIZICQ4_Grid_Axes');
VIZICQ4_Slice_Axes=findobj(VIZICQ4_Figure,'Type','axes','Tag','VIZICQ4_Slice_Axes');
VIZICQ4_Toggle_Axes_Button=findobj(VIZICQ4_Figure,'Type','uicontrol','Tag','VIZICQ4_Toggle_Axes_Button');
VIZICQ4_Current_Domain=findobj(VIZICQ4_Figure,'Type','uicontrol','Tag','VIZICQ4_Current_Domain');
VIZICQ4_Current_Icq4_Dir=findobj(VIZICQ4_Figure,'Type','uicontrol','Tag','VIZICQ4_Current_Icq4_Dir');
VIZICQ4_Current_Icq4_Name=findobj(VIZICQ4_Figure,'Type','uicontrol','Tag','VIZICQ4_Current_Icq4_Name');
VIZICQ4_Error_Text=findobj(VIZICQ4_Figure,'Type','uicontrol','Tag','VIZICQ4_Error_Text');
VIZICQ4_Info_Text=findobj(VIZICQ4_Figure,'Type','uicontrol','Tag','VIZICQ4_Info_Text');
VIZICQ4_icq4_select_button=findobj(VIZICQ4_Figure,'Type','uicontrol','Tag','VIZICQ4_icq4_select_button');
VIZICQ4_icq4_select_button_RHO=findobj(VIZICQ4_Figure,'Type','uicontrol','Tag','VIZICQ4_icq4_select_button_RHO');
VIZICQ4_Contour_Vals=findobj(VIZICQ4_Figure,'Type','uicontrol','Tag','VIZICQ4_Contour_Vals');
VIZICQ4_LabCont=findobj(VIZICQ4_Figure,'Type','uicontrol','Tag','VIZICQ4_LabCont');
VIZICQ4_DelCont=findobj(VIZICQ4_Figure,'Type','uicontrol','Tag','VIZICQ4_DelCont');
VIZICQ4_Colorbar_Axes=findobj(VIZICQ4_Figure,'Type','axes','Tag','VIZICQ4_Colorbar_Axes');

% Slicer handles
VIZICQ4_Slicer_Fig=findobj(0,'Type','figure','Tag','VIZICQ4_Slicer_Fig');
% Slicer Region limits handles
VIZICQ4_Slice_X1=findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slice_X1');
VIZICQ4_Slice_X2=findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slice_X2');
VIZICQ4_Slice_Y1=findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slice_Y1');
VIZICQ4_Slice_Y2=findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slice_Y2');
VIZICQ4_Slice_Z =findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slice_Z');
VIZICQ4_Slice_DL=findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slice_DL');
VIZICQ4_Slice_NC=findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slice_NC');
VIZICQ4_Slicer_Shading_Flat=...
    findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slicer_Shading_Flat');
VIZICQ4_Slicer_Shading_Interp=...
    findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slicer_Shading_Interp');
VIZICQ4_Slicer_Shading_Faceted=...
    findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slicer_Shading_Faceted');
VIZICQ4_Slicer_Rotation=...
    findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slicer_Rotation');
VIZICQ4_Slice_HVectors=findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slice_HVectors');
VIZICQ4_Slice_VVectors=findobj(VIZICQ4_Slicer_Fig,'Type','uicontrol','Tag','VIZICQ4_Slice_VVectors');


% Volume handles
VIZICQ4_Volume_Fig=findobj(0,'Type','figure','Tag','VIZICQ4_Volume_Fig');
VIZICQ4_Nx=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Nx');
VIZICQ4_Ny=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Ny');
VIZICQ4_Nz=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Nz');
VIZICQ4_Ix=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Ix');
VIZICQ4_Iy=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Iy');
VIZICQ4_Iz=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Iz');
VIZICQ4_Ix_GO=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Ix_GO');
VIZICQ4_Iy_GO=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Iy_GO');
VIZICQ4_Iz_GO=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Iz_GO');
VIZICQ4_ALL_GO=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_ALL_GO');
VIZICQ4_Comp_Basis=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Comp_Basis');
VIZICQ4_Map_Scalar=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Map_Scalar');
VIZICQ4_Rotation=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Rotation');
VIZICQ4_Volume_Shading_Flat=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Volume_Shading_Flat');
VIZICQ4_Volume_Shading_Interp=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Volume_Shading_Interp');
VIZICQ4_Volume_Shading_Faceted=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Volume_Shading_Faceted');


% Icq4 Info Figure handles
VIZICQ4_Icq4_Info_Fig=findobj(0,'Type','figure','Tag','VIZICQ4_Icq4_Info_Fig');
for i=1:19
   VIZICQ4_Icq4_Info_Line(i)=...
         findobj(VIZICQ4_Icq4_Info_Fig,'Type','uicontrol','Tag',['VIZICQ4_Icq4_Info_Line' int2str(i)]);
end

clear i

% Volume Region limits handles
VIZICQ4_Region_Xmin=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Region_Xmin');
VIZICQ4_Region_Xmax=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Region_Xmax');
VIZICQ4_Region_Ymin=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Region_Ymin');
VIZICQ4_Region_Ymax=findobj(VIZICQ4_Volume_Fig,'Type','uicontrol','Tag','VIZICQ4_Region_Ymax');
