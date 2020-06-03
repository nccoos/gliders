
function ind=findstrcell(cel,str);

celstr=char(cel);[nr,nc]=size(celstr);

% add a fakeout newline char
celstr(:,nc+1)=char(1959);
ind=unique(floor(findstr(str,celstr)/(nc+1))+1);
