function y2label(string)

%Y2LABEL Y-axis label for second y-axis created using PLOTYY
% 	 Y2LABEL('text') adds text beside the Y2-axis on the current axis.
%
%	See also PLOTYY
%
% Calls: none

%	Written by Samson H. Lee (shl0@lehigh.edu)

if isempty(get(gca,'UserData')),
  error('There is no Y2 axis.');
else,
  ax2 = get(gca,'UserData');
  hy2l = get(ax2,'UserData');
  set(hy2l,'String',string);
end;
