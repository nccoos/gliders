%%
clear all
close all
load Ramses_Deployment3_CTD_L1.mat
config_ctd = config;
load Ramses_Deployment3_Flight_L1.mat
%% Flow correction 
inx = find(avgDepthRate>0 & pitch>-5);
salinCorrected(inx) = [];
depth(inx) = [];
densCorrected(inx) = [];
gpsLat(inx) = [];
gpsLon(inx) = [];
ptime_datenum(inx) = [];
temp(inx) = [];
ptime(inx) = [];
salin(inx) = [];
dens(inx) = [];
pres(inx) = [];
altitude(inx) = [];
avgDepthRate(inx) = [];
horizontalVelocity(inx) = [];
pitch(inx) = [];

%% density inversion
[pks,locs] = findpeaks(depth,'MinPeakHeight',5);
den = densCorrected([1:locs(1)]);
den(den-den(end)>0) = nan;
for i = 1:length(locs)-1
    d = densCorrected([locs(i)+1:locs(i+1)]);
    d(d-densCorrected(locs(i))>0.05&d-d(end)>0.05) = nan;
    den = [den;d];
end
d = densCorrected([locs(i+1)+1:end]);
d(d-d(1)>0) = nan;
den = [den;d];
salinCorrected(isnan(den)) = [];
depth(isnan(den)) = [];
densCorrected(isnan(den)) = [];
gpsLat(isnan(den)) = [];
gpsLon(isnan(den)) = [];
ptime_datenum(isnan(den)) = [];
temp(isnan(den)) = [];
ptime(isnan(den)) = [];
salin(isnan(den)) = [];
dens(isnan(den)) = [];
pres(isnan(den)) = [];
altitude(isnan(den)) = [];
avgDepthRate(isnan(den)) = [];
horizontalVelocity(isnan(den)) = [];
pitch(isnan(den)) = [];
%% 

save Ramses_Deployment3_Flight_L1_2.mat depth ptime_datenum ...
     ptime pres  config altitude horizontalVelocity avgDepthRate angleOfAttack 
 
config = config_ctd;
save Ramses_Deployment3_CTD_L1_2.mat temp ...
     salinCorrected densCorrected depth gpsLon gpsLat ptime_datenum ...
     ptime salin dens pres tempBounds salinBounds densBounds config
