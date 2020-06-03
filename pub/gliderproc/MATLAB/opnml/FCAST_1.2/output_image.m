function output_image(fname)
% Output a set of images for the current figure
% The outputs are
%    1) <fname>.ps
%    2) <fname>.jpg (640X480)
%    3) <fname>.jpg.small (320X240)
%
% Call as: output_image(fname)


drawnow %  just in case

orig_size=get(gcf,'position');
orig_unit=get(gcf,'units');

%fnameps=[fname '.ps'];
%eval(['print -depsc ' fnameps])

set(gcf,'units','pixels','position',[orig_size(1) orig_size(2) 640 480])
drawnow
shg
[X,MAP] = getframe(gcf);
imwrite(X,MAP,[fname '.jpg'],'jpeg')

%set(gcf,'units','pixels','position',[orig_size(1) orig_size(2) 320 240])
set(gcf,'units','pixels','position',[orig_size(1) orig_size(2) 240 180])
drawnow
shg
[X,MAP] = getframe(gcf);
imwrite(X,MAP,[fname '.jpg.small'],'jpeg')



set(gcf,'Units',orig_unit,'Position',orig_size)
