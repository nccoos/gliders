function labelab1(asc,loc,ftsz)
%% function labelab1(asc,loc,ftsz)
%
%%asc: the ascii string for labeling plotting panel
%%loc: location code, default (1) is at upper right, (-1) if x-axis is reversed
%%     (2) Lower right; (-2) if y-axis reverse, others  Center up (title position)
%%ftsz: font size
%% use negative(loc) for reversed x-axis plots

if(nargin<3); ftsz=14; end %use default
if(nargin<1); asc=' '; end
if(nargin<2); loc=1; end

ax=axis; zoff=0.02*(ax(4)-ax(3)); xoff=0.02*(ax(2)-ax(1)); %*sign(loc); 
axis(ax); %make sure axis does not change when printing
%loc=abs(loc);
if(loc==1);
 text(ax(2)+xoff,ax(4)-3*zoff,asc,'FontSize',ftsz); %produce a label at upper right corner of plot
elseif(loc==-1); %xaxis reverse
 text(ax(1)-xoff,ax(4)-2*zoff,asc,'FontSize',ftsz);
elseif(loc==-2); %yaxis reverse
 text(ax(2),ax(3),asc,'FontSize',ftsz);
elseif(loc==2);
 text(ax(2)+xoff,ax(3)+zoff,asc,'FontSize',ftsz);
else
 text((ax(1)+ax(2))/2,ax(3),asc,'FontSize',ftsz)
end
%if(ftsz>0); 