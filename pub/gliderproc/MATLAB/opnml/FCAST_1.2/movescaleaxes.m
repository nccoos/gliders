function movescaleaxes(arg)
%MOVEAXIS Used to grab and move vecplot sclae axes.
%   To use, click and hold down a mouse button while
%   the cursor is near the lower left corner of the
%   axis you want to move. Wait for the cursor to change
%   to a fleur (4 way arrows), then drag the legend or axis
%   to the desired location and release the mouse button.
%
%            set(gca,'ButtonDownFcn','movescaleaxes(1)')



global OLDCA DELTA HL FIGUTS;
if arg==1,

    OLDCA=gca;  

    cur_obj_tag=get(gco,'Tag');
    if ~strcmp(cur_obj_tag,'vecscaleaxes')
       disp('axes not a scale axes')
       break;
    end
    ax=axis;
    DELTA=sqrt((ax(2)-ax(1)).^2+(ax(4)-ax(3)).^2)/10;
    OLDCA=gca;  
    FIGUTS = get(gcf,'units');
    set(gcf,'pointer','fleur');
    if strcmp(FIGUTS,'normalized'),
        pnt = get(gcf,'currentpoint');
        set(gcf,'units','normalized');  
        pos = get(gcf,'position');
        pnt = [pnt(1) * pos(3) pnt(2) * pos(4)];
    else,
        set(gcf,'units','normalized');
        pnt=get(gcf,'currentpoint');
    end
    set(gcf,'windowbuttonmotionfcn','movescaleaxes(2)')
    set(gcf,'windowbuttonupfcn','movescaleaxes(3)');
elseif arg==2,
    pos=get(get(gcf,'currentobject'),'position');
    cp=get(gcf,'CurrentPoint');
    dirx=cp(1)-pos(1);diry=cp(2)-pos(2);
    newpos= [pos(1)+dirx pos(2)+diry pos(3) pos(4)];
    set(get(gcf,'currentobject'),'units','normalized','drawmode','fast',...
    'position',newpos);
elseif arg==3,
    set(gcf,'WindowButtonMotionfcn','', ...
        'pointer','arrow','currentaxes',OLDCA, ...
        'windowbuttonupfcn','');
    set(gcf,'units',FIGUTS);
end



