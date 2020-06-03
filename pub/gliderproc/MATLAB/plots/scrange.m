%
% SCRANGE return the min and max of the input array
%
%         scrange(x) returns the min and max of the input array.
%         If x is a vector, SCRANGE returns the minimum and
%         maximum values. 
%         If x is a matrix, SCRANGE returns the minimum and
%         maximum values of each column.  
%
%         SCRANGE is most useful in determining the range of vector 
%         data to be passed to LCONTOUR2.
%
%         Example: >> x = 1:10;
%                  >> scrange(x)
%                  min = 1
%                  max = 10
%
% Calls: none
%
% Written by : Brian O. Blanton
%      
function scrange(data)

[m,n]=size(data);

if m==1 | n==1 
   data=data(:);
   disp(' ')
   disp(['min = ' num2str(min(data),8)]);
   disp(['max = ' num2str(max(data),8)]);
   disp(' ')
else
   minimum=min(data)
   maximum=max(data)
end

return
%
%        Brian O. Blanton
%        Curr. in Marine Science
%        15-1A Venable Hall
%        CB# 3300
%        Uni. of North Carolina
%        Chapel Hill, NC
%                 27599-3300
%
%        919-962-4466
%        blanton@marine.unc.edu
