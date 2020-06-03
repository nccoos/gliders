%% SCRIPT TO CREATE CONTEXT MENUS
%% DEFINE CONTEXT MENUS
%% LINE OBJECT CONTEXT ITEMS
lineobjcontextmenu=uicontextmenu('Tag','Line_Obj_Context_Menu');
   cb8 = ['set(gco,''Color'',''r'')'];
   cb9 = ['set(gco,''Color'',''g'')'];
   cb10 = ['set(gco,''Color'',''b'')'];
   cb11 = ['set(gco,''Color'',''k'')'];
   item1 = uimenu(lineobjcontextmenu, 'Label', 'LineStyle');
      cb = ['set(gco,''LineStyle'',''--'')'];
           uimenu(item1, 'Label', 'dash', 'Callback', cb);
      cb = ['set(gco,''LineStyle'','':'')'];
           uimenu(item1, 'Label', 'dot', 'Callback', cb);
      cb = ['set(gco,''LineStyle'',''-.'')'];
           uimenu(item1, 'Label', 'dot-dash', 'Callback', cb);
      cb = ['set(gco,''LineStyle'',''-'')'];
          uimenu(item1, 'Label', 'solid', 'Callback', cb);
      cb = ['set(gco,''LineStyle'',''none'')'];
          uimenu(item1, 'Label', 'none', 'Callback', cb);
   item2 = uimenu(lineobjcontextmenu, 'Label', 'LineWidth');
      cb = ['set(gco,''LineWidth'',.25)'];
           uimenu(item2, 'Label', '.25', 'Callback', cb);
      cb = ['set(gco,''LineWidth'',.5)'];
           uimenu(item2, 'Label', '.5', 'Callback', cb);
      cb = ['set(gco,''LineWidth'',1)'];
           uimenu(item2, 'Label', '1', 'Callback', cb);
      cb = ['set(gco,''LineWidth'',2)'];
           uimenu(item2, 'Label', '2', 'Callback', cb);
   item3 = uimenu(lineobjcontextmenu, 'Label', 'LineColor','ForeGroundColor','r');
      cb = ['set(gco,''Color'',''r'')'];
           uimenu(item3, 'Label', 'red', 'Callback', cb,'ForeGroundColor','r');
      cb = ['set(gco,''Color'',''g'')'];
           uimenu(item3, 'Label', 'green','Callback', cb,'ForeGroundColor','g');
      cb = ['set(gco,''Color'',''b'')'];
           uimenu(item3, 'Label', 'blue', 'Callback', cb,'ForeGroundColor','b');
      cb = ['set(gco,''Color'',''k'')'];
           uimenu(item3, 'Label', 'black', 'Callback', cb,'ForeGroundColor','k');
      cb = ['set(gco,''Color'',[.8 .8 .8])'];
           uimenu(item3, 'Label', 'grey', 'Callback', cb,'ForeGroundColor',[.8 .8 .8]);
   item4 = uimenu(lineobjcontextmenu, 'Label', 'Marker','Separator','on');
      cb = ['set(gco,''Marker'',''*'')'];
           uimenu(item4, 'Label', '*', 'Callback', cb,'ForeGroundColor','r');
      cb = ['set(gco,''Marker'',''.'')'];
           uimenu(item4, 'Label', '.','Callback', cb,'ForeGroundColor','g');
      cb = ['set(gco,''Marker'',''x'')'];
           uimenu(item4, 'Label', 'x', 'Callback', cb,'ForeGroundColor','b');
      cb = ['set(gco,''Marker'',''o'')'];
           uimenu(item4, 'Label', 'o', 'Callback', cb,'ForeGroundColor','k');
      cb = ['set(gco,''Marker'',''d'')'];
           uimenu(item4, 'Label', 'diamond', 'Callback', cb,'ForeGroundColor',[.8 .8 .8]);
   item5 = uimenu(lineobjcontextmenu, 'Label', 'MarkerSize');
      cb = ['set(gco,''MarkerSize'',4)'];
           uimenu(item5, 'Label', '4', 'Callback', cb);
      cb = ['set(gco,''MarkerSize'',8)'];
           uimenu(item5, 'Label', '8','Callback', cb);
      cb = ['set(gco,''MarkerSize'',12)'];
           uimenu(item5, 'Label', '12', 'Callback', cb);
      cb = ['set(gco,''MarkerSize'',16)'];
           uimenu(item5, 'Label', '16', 'Callback', cb);
      cb = ['set(gco,''MarkerSize'',20)'];
           uimenu(item5, 'Label', '20', 'Callback', cb);
   
%% TEXT OBJECT CONTEXT ITEMS
textobjcontextmenu=uicontextmenu('Tag','Text_Obj_Context_Menu');
   item1 = uimenu(textobjcontextmenu, 'Label', 'FontSize');
      cb = ['set(gco,''FontSize'',6)'];
           uimenu(item1, 'Label', '6', 'Callback', cb);
      cb = ['set(gco,''FontSize'',10)'];
           uimenu(item1, 'Label', '10', 'Callback', cb);
      cb = ['set(gco,''FontSize'',14)'];
           uimenu(item1, 'Label', '14', 'Callback', cb);
      cb = ['set(gco,''FontSize'',18)'];
           uimenu(item1, 'Label', '18', 'Callback', cb);
      cb = ['set(gco,''FontSize'',22)'];
           uimenu(item1, 'Label', '22', 'Callback', cb);
   item2= uimenu(textobjcontextmenu, 'Label', 'FontWeight');
      cb = ['set(gco,''FontWeight'',''light'')'];
           uimenu(item2, 'Label', 'light', 'Callback', cb);
      cb = ['set(gco,''FontWeight'',''normal'')'];
           uimenu(item2, 'Label', 'normal', 'Callback', cb);
      cb = ['set(gco,''FontWeight'',''demi'')'];
           uimenu(item2, 'Label', 'demi', 'Callback', cb);
      cb = ['set(gco,''FontWeight'',''bold'')'];
           uimenu(item2, 'Label', 'bold', 'Callback', cb);
   item3= uimenu(textobjcontextmenu, 'Label', 'FontAngle');
      cb = ['set(gco,''FontAngle'',''normal'')'];
           uimenu(item3, 'Label', 'normal', 'Callback', cb);
      cb = ['set(gco,''FontAngle'',''italic'')'];
          uimenu(item3, 'Label', 'italic', 'Callback', cb);
      cb = ['set(gco,''FontAngle'',''oblique'')'];
          uimenu(item3, 'Label', 'oblique', 'Callback', cb);
   item4= uimenu(textobjcontextmenu, 'Label', 'Color');
      cb = ['set(gco,''Color'',''r'')'];
          uimenu(item4, 'Label', 'red', 'Callback', cb);
      cb = ['set(gco,''Color'',''italic'')'];
          uimenu(item4, 'Label', 'blue', 'Callback', cb);
      cb = ['set(gco,''Color'',''g'')'];
          uimenu(item4, 'Label', 'green', 'Callback', cb);
      cb = ['set(gco,''Color'',''k'')'];
          uimenu(item4, 'Label', 'black', 'Callback', cb);
 