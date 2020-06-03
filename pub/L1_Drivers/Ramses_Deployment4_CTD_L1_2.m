% addpath('../gliderproc');
% addpath('../gliderproc/MATLAB/util');
% addpath('../gliderproc/MATLAB/plots');
% %addpath('MATLAB/matutil/');
% addpath('../gliderproc/MATLAB/seawater');
% addpath('../gliderproc/MATLAB/strfun');
% %addpath('MATLAB/opnml/');
% %addpath('MATLAB/opnml/FEM/');
% % Add this in only if you want to use the NEW correctThermalLag (and make
% % sure the old one does not get on the path first e.g. rename it).
% addpath('../../glider_toolbox-master/m/processing_tools');
% addpath('../../glider_toolbox-master/m/mex_tools');
% % idx = find(ptime_datenum>= & ptime_datenum>=);
% % find one set of up and down casts
% subset1=idx(88:165);
% subset2=idx(166:241);
% time1 = ptime(subset1);
% time2 = ptime(subset2);
% t1 = ptime_datenum(subset1);
% t2 = ptime_datenum(subset2);
% cond1 = x.cond(subset1);
% cond2 = x.cond(subset2);
% temp1 = temp(subset1);
% temp2 = temp(subset2);
% pres1 = pres(subset1);
% pres2 = pres(subset2);
% flow1 = x.gliderVelocity(subset1);
% flow2 = x.gliderVelocity(subset2); 
% figure;
% subplot(4,1,1);
% plot(t1,flow1,t2,flow2)
% datetick
% subplot(4,1,2);
% plot(t1,x.pitch(subset1),t2,x.pitch(subset2))
% datetick
% subplot(4,1,3);
% plot(t1,cond1,t2,cond2)
% datetick
% subplot(4,1,4);
% plot(t1,temp1,t2,temp2)
% datetick
% [params, exitflag, residual] = findThermalLagParams(time1,cond1,temp1,pres1,flow1,time2,cond2,temp2,pres2,flow2,'graphics', 'true');
%%
clear all
close all
load Ramses_Deployment4_CTD_L1.mat
load ramsesD4_x.mat
config_ctd = config;
load Ramses_Deployment4_Flight_L1.mat
% idx = find(ptime_datenum>=datenum('2018-06-03 18:00')&ptime_datenum<=datenum('2018-06-03 18:10'));
% idx = find(ptime_datenum>=datenum('2018-05-18 02:25')&ptime_datenum<=datenum('2018-05-18 02:45'));
% idx = find(ptime_datenum>=datenum('2018-06-01 13:25')&ptime_datenum<=datenum('2018-06-01 13:35'));
% idx = find(ptime_datenum>=datenum('2018-05-20 15:00')&ptime_datenum<=datenum('2018-05-20 15:20'));
% idx = find(ptime_datenum>=datenum('2018-05-23 08:15')&ptime_datenum<=datenum('2018-05-23 08:45'));
% idx = find(ptime_datenum>=datenum('2018-05-23 11:20')&ptime_datenum<=datenum('2018-05-23 11:30'));
% idx = find(ptime_datenum>=datenum('2018-05-23 22:25')&ptime_datenum<=datenum('2018-05-23 22:40'));
params = [0.0012 0.0335 12.1415 20.9655;          
                0.1260  0.0027 18.0950 19.8963;
                0.00073,0.050,0.19,7.377;
                0.0497   0.0135  14.6668  28.1738
                0.0825   0.0562   8.3452   8.1968;
                0.2833    0.0432   13.1668   18.3033;
                0.2833    0.0432   8.3452   8.1968;
                0.0784    0.0326    8.3958    5.5424];
% params: 1. 05/18 2. 06/03 3. 06/01 4. 05/20 5. 05/23 6. 05/23
% 7.combination between 5 and 6 8. 05/23
salinCorrected1 = [];
for i = 1:8
[temp_inside, cond_outside] = correctThermalLag(ptime,x.cond,x.temp,x.gliderVelocity,params(i,:));
tempCorrected = temp_inside;
salinCorrected1 = [salinCorrected1,sw_salt(10*x.cond/sw_c3515, tempCorrected, pres)];
end
salinCorrected_new = nan(size(salin));
inx = find(ptime_datenum<=datenum('2018-05-21 21:30'));
salinCorrected_new(inx) = salinCorrected1(inx,4);
inx = find(ptime_datenum>=datenum('2018-05-21 21:30')&ptime_datenum<=datenum('2018-05-23 21:00'));
salinCorrected_new(inx) = salinCorrected(inx);
inx = find(ptime_datenum<=datenum('2018-05-24 12:40')&ptime_datenum>=datenum('2018-05-23 21:00'));
salinCorrected_new(inx) = salinCorrected(inx);
inx = find(ptime_datenum>=datenum('2018-05-26'));
salinCorrected_new(inx) = salinCorrected(inx);
inx = find(ptime_datenum>datenum('2018-05-24 12:40')&ptime_datenum<=datenum('2018-05-26'));
salinCorrected_new(inx) = salinCorrected1(inx,4);
salinCorrected = salinCorrected_new;
densCorrected = sw_pden(salinCorrected, temp, pres, 0);
clear salinCorrected1 salinCorrected_new
%% Flow correction for the messy part
inx = find(ptime_datenum>=datenum('2018-05-21 21:30')&ptime_datenum<=datenum('2018-05-23 21:00'));
ixx = find(abs(x.avgDepthRate(inx))<0.05);
salinCorrected(inx(ixx)) = [];
depth(inx(ixx)) = [];
densCorrected(inx(ixx)) = [];
gpsLat(inx(ixx)) = [];
gpsLon(inx(ixx)) = [];
ptime_datenum(inx(ixx)) = [];
temp(inx(ixx)) = [];
ptime(inx(ixx)) = [];
salin(inx(ixx)) = [];
dens(inx(ixx)) = [];
pres(inx(ixx)) = [];
altitude(inx(ixx)) = [];
avgDepthRate(inx(ixx)) = [];
horizontalVelocity(inx(ixx)) = [];
pitch(inx(ixx)) = [];
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
save Ramses_Deployment4_Flight_L1_2.mat depth ptime_datenum ...
     ptime pres  config altitude horizontalVelocity avgDepthRate angleOfAttack 
 
config = config_ctd;
save Ramses_Deployment4_CTD_L1_2.mat temp ...
     salinCorrected densCorrected depth gpsLon gpsLat ptime_datenum ...
     ptime salin dens pres tempBounds salinBounds densBounds config

% %%
% S = salinCorrected%1(:,7);
% % ccplot_Glider_Data_t(ptime_datenum,depth,salinCorrected,'Salin','Ramses');
% ccplot_Glider_Data_t(ptime_datenum,depth,densCorrected,'Dense','Ramses');
% % ccplot3_Glider_Data(gpsLon, gpsLat,depth,salinCorrected,[min(salinCorrected) max(salinCorrected)],'salinCorrected', 'Ramses');
% % ccplot3_Glider_Data(gpsLon, gpsLat,depth,temp,[min(temp) max(temp)],'temp (Corrected)', 'Ramses');
% % ccplot_Glider_Data_t(S(inx),temp(inx),depth(inx),'Salinity (Corrected)','Ramses');
% 
% 
% 
% function ccplot_Glider_Data_t(time,P,Z,var_Label, platform_Label)
% length(~isnan(Z))
% display_String = sprintf('%s %s %s %s\n','Plotting',var_Label,'from',platform_Label);
% disp(display_String);
% figure; 
% colormap jet
% ccplot(time,P,Z,[nanmin(Z) nanmax(Z)],'.',10);     
% colorbar;
% colormap jet
% xlabel('Time');  
% set(gca,'YDir','reverse'); 
% title_String = sprintf('%s %s %s %s',var_Label,'(from', platform_Label, ')') 
% title(title_String);
% ylabel('Depth (m)');
% datetick('x','keeplimits');
% end
% 
% 
% function ccplot3_Glider_Data(gpsLon, gpsLat,P,Z,bounds,var_Label, platform_Label)
% figure; 
% %me_Try_Map; hold on;
% colormap jet
% hc = ccplot3(gpsLon, gpsLat, -P, Z, bounds, '.', 15);
% title_String = sprintf('%s %s %s %s',var_Label,'(from', platform_Label, ')') 
% title(title_String);
% colormap jet
% colorbar;
% %hold on; map_SECOORA_2016;
% end
