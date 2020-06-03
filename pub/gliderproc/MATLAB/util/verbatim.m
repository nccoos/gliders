%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Add back slashes to get Latex *verbatim* form of character strings %
%% newstring=verbatim(oldstring)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newstring=verbatim(oldstring)
size(oldstring);
nchar=ans(2);
%
% find locations and number of *_* entries
%
for i=1:nchar
   if oldstring(1,i) == '_'
      dash(i,1)=1;
   else
      dash(i,1)=0;
   end
end
newstring=oldstring;
for i=nchar+1:nchar+sum(dash)
   newstring(1,i)=' ';
end
index=0;
for i=1:nchar
   index=index+1;
   if dash(i) == 1
      for ii=nchar+sum(dash):-1:index+1
         newstring(1,ii)=newstring(1,ii-1);
      end
      newstring(1,index)='\';
      index=index+1;
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
