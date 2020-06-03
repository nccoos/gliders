function gtime_str=gregorian_string(julian)
%GREGORIAN  Converts Julian day numbers to corresponding
%       Gregorian calendar dates.  Although formally, 
%       Julian days start and end at noon, here Julian days
%       start and end at midnight for simplicity.
%     
%       In this convention, Julian day 2440000 begins at 
%       0000 hours, May 23, 1968.
%
%     Usage: [gtime_string]=gregorian(julian) 
%
%        julian... input decimal Julian day number
%
%        gtime is a string of the form 'DD MMM YYYY'
%               
%          i.e.   gtime_str= '01 JAN 1992'
%
% THIS IS RICH SIGNELL'S ROUTINE GREGORIAN, MODIFIED BY B. BLANTON
% TO OUTPUT A STRING DATE IN CELLSTR FORMAT, ACCEPTS VECTOR INPUT
 
%        yr........ year (e.g., 1979)
%        mo........ month (1-12)
%        d........ corresponding Gregorian day (1-31)
%        h........ decimal hours
%
      julian=julian+5.e-9;    % kludge to prevent roundoff error on seconds

%      if you want Julian Days to start at noon...
%      h=rem(julian,1)*24+12;
%      i=(h >= 24);
%      julian(i)=julian(i)+1;
%      h(i)=h(i)-24;

      secs=rem(julian,1)*24*3600;

      j = floor(julian) - 1721119;
      in = 4*j -1;
      y = floor(in/146097);
      j = in - 146097*y;
      in = floor(j/4);
      in = 4*in +3;
      j = floor(in/1461);
      d = floor(((in - 1461*j) +4)/4);
      in = 5*d -3;
      m = floor(in/153);
      d = floor(((in - 153*m) +5)/5);
      y = y*100 +j;
      mo=m-9;
      yr=y+1;
      i=(m<10);
      mo(i)=m(i)+3;
      yr(i)=y(i);
      [hour,min,sec]=s2hms(secs);
      
      yr=yr(:);
      mo=mo(:);
      d=d(:);
      hour=hour(:);
      min=min(:);
      sec=sec(:);
      
      months=str2mat('JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC');
      
      for i=1:length(yr)
         if d(i)<10
            gtime_str(i)={['0' int2str(d(i)) ' ' months(mo(i),:) ' ' int2str(yr(i)) ' H=' int2str(hour(i))]};
         else
	    gtime_str(i)={[int2str(d(i)) ' ' months(mo(i),:) ' ' int2str(yr(i)) ' H=' int2str(hour(i))]};
         end
      end
    
      
