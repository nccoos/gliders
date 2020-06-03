function SaveTemplate(path, filename)
%
% Abstract:
%    Save current figure template as an m-file function.
%
% Usage:
%    >> SaveTemplate([path], filename)
% 
%    where [<path>] is the directory path string of the location to store the
%    function by the name provided with <filename>.  If no [path] is specified
%    then the current path is taken.  '.m' is appended if only the prefix of
%    the name is given in <filename>.
%
%    A MATLAB script function is created from the skeletal elements
%    that make up a figure window, which reproduces the following:
%
%       o all the figure properties from the original figure
%       o all the axes and their properties 
%       o all text children of each of the axes and properties of each
%         text item.
%
%    The SaveAs function does not save any inforamation about any graphical
%    user interfaces actions, such as any button down functions or uicontrols
%    or uimenus and their call backs.  It also does not save any user data nor
%    does it retain xdata, ydata, zdata and hence does not plot lines,
%    patches, surfaces, and images.

% 
% History:
%    o 15 August 1995 created function SaveTemplate as part of Prmenu,
%          by Sara Haines.
%

global LASTFIGURE
if isempty(LASTFIGURE)
    curfig = gcf;
else
    curfig = LASTFIGURE;
end
set(curfig,'Pointer','watch');

% 
if nargin == 1
 filename = path;
 path = '.';
elseif nargin > 2
  disp('SaveAs:  Too many input parameters');
  return;
elseif nargin == 0
  disp('SaveAs:  Too many input parameters');
  return;
end

figprop = [ ...
           'Color           ';...
           'InvertHardcopy  ';...
           'Name            ';...
           'NextPlot        ';...
           'NumberTitle     ';...
           'PaperUnits      ';...
           'PaperOrientation';...
           'PaperPosition   ';...
           'PaperType       ';...
           'Position        ';...
           'Units           ';...
           'Visible         ';...
           'Clipping        ';...
           'Tag             '...
                              ];
		     
axesprop = [...
	'AspectRatio         ';...
        'Box                 ';...
        'CLim                ';...
        'CLimMode            ';...
        'Color               ';...
        'ColorOrder          ';...
        'DrawMode            ';...
        'ExpFontAngle        ';...
        'ExpFontName         ';...
        'ExpFontSize         ';...
        'ExpFontStrikeThrough';...
        'ExpFontUnderline    ';...
        'ExpFontWeight       ';...
        'FontAngle           ';...
        'FontName            ';...
        'FontSize            ';...
        'FontStrikeThrough   ';...
        'FontUnderline       ';...
        'FontWeight          ';...
        'GridLineStyle       ';...
        'Layer               ';...
        'LineStyleOrder      ';...
        'LineWidth           ';...
        'MinorGridLineStyle  ';...
        'NextPlot            ';...
        'TickLength          ';...
        'TickDir             ';...
        'View                ';...
        'XColor              ';...
        'XDir                ';...
        'XGrid               ';...
        'XLim                ';...
        'XLimMode            ';...
        'XMinorGrid          ';...
        'XMinorTicks         ';...
        'XScale              ';...
        'XTick               ';...
        'XTickLabels         ';...
        'XTickLabelMode      ';...
        'XTickMode           ';...
        'YColor              ';...
        'YDir                ';...
        'YGrid               ';...
        'YLim                ';...
        'YLimMode            ';...
        'YMinorGrid          ';...
        'YMinorTicks         ';...
        'YScale              ';...
        'YTick               ';...
        'YTickLabels         ';...
        'YTickLabelMode      ';...
        'YTickMode           ';...
        'ZColor              ';...
        'ZDir                ';...
        'ZGrid               ';...
        'ZLim                ';...
        'ZLimMode            ';...
        'ZMinorGrid          ';...
        'ZMinorTicks         ';...
        'ZScale              ';...
        'ZTick               ';...
        'ZTickLabels         ';...
        'ZTickLabelMode      ';...
        'ZTickMode           ';...
        'Clipping            ';...
        'Tag                 ';...
        'Visible             ';...
	                     ];
			 

textprop = [...
	'Color              '; ...
        'EraseMode          '; ...
        'FontAngle          '; ...
        'FontName           '; ...
        'FontSize           '; ...
        'FontStrikeThrough  '; ...
        'FontUnderline      '; ...
        'FontWeight         '; ...
        'HorizontalAlignment'; ...
        'Position           '; ...
        'Rotation           '; ...
        'String             '; ...
        'Units              '; ...
        'VerticalAlignment  '; ...
        'Tag                '; ...
        'Visible            '; ...
                            ];
			
labeltype = [...
	'Title '; ...
        'Xlabel'; ...
	'Ylabel'; ...
	'Zlabel'; ...
	          ];

% append or change suffix to dot-m if not found in filename  
prefixname = strtok(filename, '.');
if isempty(findstr(filename, '.m'))
  filename = [prefixname '.m'];
end

% remove any file with same name and path
if (exist([path '/' filename]) == 2 )
  eval(['delete ''' sprintf('%s',[path '/' filename]) '''']);
end

[fid, mesg] = fopen([path '/' filename], 'wt');
if (fid) < 0 
  disp(['SaveAs:  Error opening file: ' mesg]);
  return;
end

% write function and header comments
fprintf(fid, '%s\n', ['function ' prefixname '()']);
fprintf(fid, '%s\n', ['% This function was generated by another '...
	'function. It regenerates']);
fprintf(fid, '%s\n', ['% a figure template as saved by function SaveAs.']);
fprintf(fid, '%s\n', ['% ']);
fprintf(fid, '%s\n', ['% Usage: Type the name of the function. ']);
fprintf(fid, '%s\n', ['%   >> ' prefixname]);
fprintf(fid, '%s\n\n', ['% ']);

fprintf(fid, '%s\n\n', ['A = figure;']);

[Nfigprop, Mfigprop] = size(figprop);
for element=1:Nfigprop
  prop = deblank(figprop(element,:));
  propvalue = get(curfig, prop);
  if ~isstr(propvalue)
    [n,m] = size(propvalue);
    str = '[';
    for i=1:n
      if i>1
	str = [str, sprintf('\t\t')];
      end
      for j=1:m
	str = [str, sprintf('%s,', num2str(propvalue(i,j)))];
      end
      if i<n
	str = [str, sprintf(';...\n')];
      else
	str = [str, ']' ];
      end
    end
    propstr = [str];
  else
    propstr = ['''' propvalue ''''];  
  end
  printstr = ['set(A, ''' prop ''', ' propstr ');'];
  fprintf(fid, '%s\n', printstr);
end

fprintf(fid, '\n'); 			% blank line separator
figAxes = findobj(curfig, 'type', 'axes');
Naxes = length(figAxes);

for eachAxis=1:Naxes
  % write command to open axes with position and units from original graph
  % also get and write commands to set labels and title
  % but since they are text objects set their text properties after all axes
  % properties are taken care of
  posstr = sprintf('[%f %f %f %f]', get(figAxes(eachAxis), 'Position'));
  unitsstr = sprintf('''%s''', get(figAxes(eachAxis), 'Units'));
  
  fprintf(fid, '%s\n', 'B = axes(''Parent'', A, ...');
  fprintf(fid, '\t%s\n', ['''Position'', ' posstr ', ...']);
  fprintf(fid, '\t%s\n', ['''Units'', ' unitsstr ');']);
  
  % write set commands for each property of axes (except
  % for those already set above for each axis
  [Naxesprop, Maxesprop] = size(axesprop);
  for element=1:Naxesprop
    prop = deblank(axesprop(element,:));
    propvalue = get(figAxes(eachAxis), prop);
    [n,m] = size(propvalue);
    if ~isstr(propvalue)
      str = '[';
	  for i=1:n
	    if i>1
	      str = [str, sprintf('\t\t')];
	    end
	    for j=1:m
	      str = [str, sprintf('%s,', num2str(propvalue(i,j)))];
	    end
	    if i<n
	      str = [str, sprintf('; ...\n')];
	    else
	      str = [str, ']' ];
	end
      end
      propstr = [str];
    else
      if n>1
	str = '[';
	for i=1:n
	    if i>1
	      str = [str, sprintf('\t\t')];
	    end
	    str = [str, sprintf(['''%' int2str(m) 's'''], propvalue(i,1:m))];
	    if i<n
	      str = [str, sprintf(';...\n')];
	    else
	      str = [str, ']' ];
	    end
	
	end %for
	propstr = [str];
      else
	propstr = ['''' propvalue ''''];  
      end
    end
    printstr = ['set(B, ''' prop ''', ' propstr ');'];
    fprintf(fid, '%s\n', printstr);
  end
  
  fprintf(fid, '\n');			% blank line separatro
  
  % find all text objects of the current axes
  TextObjs = findobj(figAxes(eachAxis), 'type', 'text');
  
  % determine which ones are added text childern or title or x-,
  % y-, or z-labels
  titlHndl = get(figAxes(eachAxis), 'title');
  xlabHndl = get(figAxes(eachAxis), 'xlabel');
  ylabHndl = get(figAxes(eachAxis), 'ylabel');
  zlabHndl = get(figAxes(eachAxis), 'zlabel');
  LabelObjs = [titlHndl  xlabHndl ylabHndl zlabHndl];
  TextObjs(find(TextObjs==titlHndl)) = [];
  TextObjs(find(TextObjs==xlabHndl)) = [];
  TextObjs(find(TextObjs==ylabHndl)) = [];
  TextObjs(find(TextObjs==zlabHndl)) = [];
  
  % update the properties for title, and labels
  for eachText=1:4
    Hndlstr = deblank(labeltype(eachText,:));
    fprintf(fid, '%s\n', [Hndlstr 'Hndl = text;']);
    [Ntextprop, Mtextprop] = size(textprop);
    for element=1:Ntextprop
      prop = deblank(textprop(element,:));
      propvalue = get(LabelObjs(eachText), prop);
      if ~isstr(propvalue)
	[n,m] = size(propvalue);
	str = '[';
	    for i=1:n
	      if i>1
		str = [str, sprintf('\t\t')];
	      end
	      for j=1:m
		str = [str, sprintf('%s,', num2str(propvalue(i,j)))];
	      end
	      if i<n
		str = [str, sprintf(';...\n')];
	      else
		str = [str, ']' ];
	  end
	end
	propstr = [str];
      else
	propstr = ['''' propvalue ''''];  
      end
      printstr = ['set(' Hndlstr 'Hndl, ''' prop ''', ' propstr ');'];
      fprintf(fid, '%s\n', printstr);
    end

    fprintf(fid, '\n'); 		% blank line separator
    
  end
  
  % now write commands that set the axes title and labels to contain
  % the new handles of the text objects just created
  fprintf(fid, '%s\n', 'set(B, ''Title'', TitleHndl);');
  fprintf(fid, '%s\n', 'set(B, ''Xlabel'', XlabelHndl);');
  fprintf(fid, '%s\n', 'set(B, ''Ylabel'', YlabelHndl);');
  fprintf(fid, '%s\n', 'set(B, ''Zlabel'', ZlabelHndl);');
  
  fprintf(fid, '\n'); 			% blank line separator

  % now write commands to set  all the text children and their properties
  for eachText=1:length(TextObjs)
    fprintf(fid, '%s\n', ['C = text;']);
    [Ntextprop, Mtextprop] = size(textprop);
    for element=1:Ntextprop
      prop = deblank(textprop(element,:));
      propvalue = get(TextObjs(eachText), prop);
      if ~isstr(propvalue)
	[n,m] = size(propvalue);
	str = '[';
	    for i=1:n
	      if i>1
		str = [str, sprintf('\t\t')];
	      end
	      for j=1:m
		str = [str, sprintf('%s,', num2str(propvalue(i,j)))];
	      end
	      if i<n
		str = [str, sprintf(';...\n')];
	      else
		str = [str, ']' ];
	  end
	end
	propstr = [str];
      else
	propstr = ['''' propvalue ''''];  
      end
      printstr = ['set(C, ''' prop ''', ' propstr ');'];
      fprintf(fid, '%s\n', printstr);
    end

    fprintf(fid, '\n'); 		% blank line separator
    
  end
  
end					% for each axis

fclose(fid);

% restore pointer
if ~isnan(curfig),
    set(curfig,'Pointer','arrow');
end
