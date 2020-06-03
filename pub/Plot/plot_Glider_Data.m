
function plot_Glider_Data(target_Struct, t_Min_String, t_Max_String, platform_Label, dataset_Code, x)

t_Min = datenum(t_Min_String);
t_Max = datenum(t_Max_String);
subset=find(  (target_Struct.ptime_datenum >= t_Min) & (target_Struct.ptime_datenum < t_Max));

% Variables that should be common to all datasets
time = target_Struct.ptime_datenum(subset);
length(time)
P = target_Struct.depth(subset);



% Call routines to gen plots per variable
switch dataset_Code
    case 'FLIGHT'
        altitude = target_Struct.altitude(subset); 
        pitch = target_Struct.pitch(subset); 
        figure; plot(time,altitude,'bo-'); datetick('x',6,'keeplimits'); title('Altitude (from bottom)');
        figure; plot(time,-P,'bo-'); datetick('x',6,'keeplimits'); title('Depth');
        figure; plot(time,pitch,'bo-'); datetick('x',6,'keeplimits'); title('Pitch');
    case 'CTD'
        gpsLat = target_Struct.gpsLat(subset);
        gpsLon = target_Struct.gpsLon(subset);
        % Look at data with the goal of handling salinity spiking
        try
            %{
            ib=find(abs(diff(x.tempCorrected))>1.);
            ib2=find(abs(diff(x.cond))>0.15);
            ibb=union(ib,ib2);
            %}
            %ibb = find( (abs(x.hv)<0.1) & (abs(x.pitch) < 5.) );
            
            
            salinCorrectedMedFilt = medfilt1(x.salinCorrected,15);
            ibbDiff = x.salinCorrected - salinCorrectedMedFilt;
%             figure; plot(x.ptime_datenum,ibbDiff); title('ibbDiff'); datetick('x',0,'keeplimits');
            ibb = find( (x.ptime_datenum >= t_Min) & (x.ptime_datenum < t_Max) & (abs(ibbDiff))>0.2 );
%             subsetx = find(  (x.ptime_datenum >= t_Min) & (x.ptime_datenum < t_Max));
%             
%             figure; plot(x.ptime_datenum(subsetx),x.hv(subsetx),'bo'); title('hv'); datetick('x',0,'keeplimits'); hold on; plot(x.ptime_datenum(ibb),x.hv(ibb),'ro');
%             figure; plot(x.ptime_datenum(subsetx),x.pitch(subsetx),'bo'); title('pitch'); datetick('x',0,'keeplimits'); hold on; plot(x.ptime_datenum(ibb),x.pitch(ibb),'ro');
%             figure; plot(x.ptime_datenum(subsetx),x.cond(subsetx),'bo'); title('cond'); datetick('x',0,'keeplimits'); hold on; plot(x.ptime_datenum(ibb),x.cond(ibb),'ro');
%             figure; plot(x.ptime_datenum(subsetx),x.temp(subsetx),'bo'); title('temp'); datetick('x',0,'keeplimits'); hold on; plot(x.ptime_datenum(ibb),x.temp(ibb),'ro');
%             figure; plot(x.ptime_datenum(subsetx),x.tempCorrected(subsetx),'bo'); title('tempCorrected'); datetick('x',0,'keeplimits'); hold on; plot(x.ptime_datenum(ibb),x.tempCorrected(ibb),'ro');
%             figure; plot(x.ptime_datenum(subsetx),x.salinCorrected(subsetx),'bo'); title('salinCorrected'); datetick('x',0,'keeplimits'); hold on; 
%                     plot(x.ptime_datenum(ibb),x.salinCorrected(ibb),'ro'); hold on;
%                     plot(x.ptime_datenum(subsetx),salinCorrectedMedFilt(subsetx),'k+');
%             figure; plot(x.salinCorrected(subsetx),x.tempCorrected(subsetx),'bo'); title('T-S (Corrected)'); hold on;
%                     plot(x.salinCorrected(ibb),x.tempCorrected(ibb),'r+'); 
        catch err
            %throw(err)
        end
        %return
        % For temperature
        try
            T = target_Struct.temp(subset);
%             figure; plot(time,T,'bo-'); datetick('x',6,'keeplimits'); title('Temperature');
%             figure; plot(time,-P,'bo-'); datetick('x',6,'keeplimits'); title('Depth');
            ccplot_Glider_Data_t(time,P,T,target_Struct.tempBounds,'Temperature',platform_Label);
            ccplot3_Glider_Data(gpsLon, gpsLat,P,T,target_Struct.tempBounds,'Temperature', platform_Label);
        catch err
            throw(err)
        end
        % For salinity
        try
            S = target_Struct.salinCorrected(subset);
%             figure; plot(time,S,'bo-'); datetick('x',6,'keeplimits'); title('Salinity (Corrected)');
            ccplot_Glider_Data_t(time,P,S,target_Struct.salinBounds,'Salinity (Corrected)',platform_Label);
            ccplot3_Glider_Data(gpsLon, gpsLat,P,S,target_Struct.salinBounds,'Salinity (Corrected)', platform_Label);
        catch err
            throw(err)
        end
        try
            S = target_Struct.salinCorrected(subset);
%             figure; plot(time,S,'bo-'); datetick('x',6,'keeplimits'); title('Salinity (Corrected)');
            ccplot_Glider_Data_t(time,P,S,target_Struct.salinBounds,'Salinity (Corrected)',platform_Label);
            ccplot3_Glider_Data(gpsLon, gpsLat,P,S,target_Struct.salinBounds,'Salinity (Corrected)', platform_Label);
        catch err
            throw(err)
        end
        try
            dens = target_Struct.densCorrected(subset);
            ccplot_Glider_Data_t(time,P,dens,target_Struct.densBounds,'Density (Corrected)',platform_Label);
            ccplot3_Glider_Data(gpsLon, gpsLat,P,dens,target_Struct.densBounds,'Density (Corrected)', platform_Label);
        catch err
            throw(err)
        end
%      
        slim = [target_Struct.salinBounds(1) - range(target_Struct.salinBounds)*0.1 ...
            target_Struct.salinBounds(2) + range(target_Struct.salinBounds)*0.1];
        tlim = [target_Struct.tempBounds(1) - range(target_Struct.tempBounds)*0.1 ...
            target_Struct.tempBounds(2) + range(target_Struct.tempBounds)*0.1];
        figure; 
        tsdiagrm(slim,tlim,[0],[16:1:32])
        hold on
        h1 = plot(target_Struct.salin(subset),target_Struct.temp(subset),'.');
        h2 = plot(S,T,'r.');
        legend([h1,h2],{'Uncorrected','Corrected'})
        ylabel('T(^oC)');xlabel('S')
        title('T-S Diagram');  
            
        
        figure;
        h = histogram2(S,T,'BinWidth',[0.1,0.02],'facecolor','flat')
        colormap jet;
        colorbar;
        xlabel('S');
        ylabel('T');
        xlim(slim)
        ylim(tlim)
        title('Histogram of corrected T-S')

    case 'ECO'
        gpsLat = target_Struct.gpsLat(subset);
        gpsLon = target_Struct.gpsLon(subset);
        % For chlorophyll
        try   
            chlor = target_Struct.chlor(subset); 
            figure; plot(time,chlor,'bo-'); datetick('x',6,'keeplimits'); title('Chlorophyll');
            figure; plot(time,-P,'bo-'); datetick('x',6,'keeplimits'); title('Depth');
            
            chlor_Clean = target_Struct.chlor(subset); 
            figure; plot(time,log10(chlor_Clean),'bo-'); datetick('x',6,'keeplimits'); title('Log of Chlorophyll, Clean');

            ccplot_Glider_Data_t(time,P,log10(chlor_Clean),[min(log10(chlor_Clean)) max(log10(chlor_Clean))],'Log of Chlorophyll, Clean',platform_Label);
            ccplot3_Glider_Data(gpsLon, gpsLat,P,log10(chlor_Clean),[min(log10(chlor_Clean)) max(log10(chlor_Clean))],'Log of Chlorophyll, Clean', platform_Label);
            hist_Glider_Data(log10(chlor_Clean),'Log of Chlorophyll, Clean', platform_Label)

        catch err
            throw(err)
        end
        % For scatter
        try
            scatter = target_Struct.scatter(subset); 
            figure; plot(time,scatter,'bo-'); datetick('x',6,'keeplimits'); title('Scatter');

            idx_Clean = find(scatter>0 & ~isnan(P) );
            scatter_Clean = scatter(idx_Clean);
            time_Clean = time(idx_Clean);
            P_Clean = P(idx_Clean);
            gpsLon_Clean = gpsLon(idx_Clean);
            gpsLat_Clean = gpsLat(idx_Clean);
            figure; plot(time_Clean,log10(scatter_Clean),'bo-'); datetick('x',6,'keeplimits'); title('Log of Scatter, Clean');

            ccplot_Glider_Data_t(time_Clean,P_Clean,log10(scatter_Clean),[min(log10(scatter_Clean)) max(log10(scatter_Clean))],'Log of Scatter, Clean',platform_Label);
            ccplot3_Glider_Data(gpsLon_Clean, gpsLat_Clean,P_Clean,log10(scatter_Clean),[min(log10(scatter_Clean)) max(log10(scatter_Clean))],'Log of Scatter, Clean', platform_Label);
            hist_Glider_Data(log10(scatter_Clean),'Log of Scatter, Clean', platform_Label)
        catch err
            %throw(err)
        end
        % For cdom
        try
            cdom = target_Struct.cdom(subset); 
            figure; plot(time,cdom,'bo-'); datetick('x',6,'keeplimits'); title('CDOM');

            idx_Clean = find(cdom>0 & ~isnan(P) );
            cdom_Clean = cdom(idx_Clean);
            time_Clean = time(idx_Clean);
            P_Clean = P(idx_Clean);
            gpsLon_Clean = gpsLon(idx_Clean);
            gpsLat_Clean = gpsLat(idx_Clean);
            figure; plot(time_Clean,log10(cdom_Clean),'bo-'); datetick('x',6,'keeplimits'); title('Log of CDOM, Clean');

            ccplot_Glider_Data_t(time_Clean,P_Clean,log10(cdom_Clean),[min(log10(cdom_Clean)) max(log10(cdom_Clean))],'Log of CDOM, Clean',platform_Label);
            ccplot3_Glider_Data(gpsLon_Clean, gpsLat_Clean,P_Clean,log10(cdom_Clean),[min(log10(cdom_Clean)) max(log10(cdom_Clean))],'Log of CDOM, Clean', platform_Label);
            hist_Glider_Data(log10(cdom_Clean),'Log of CDOM, Clean', platform_Label)
        catch err
            %throw(err)
        end
    case 'DO'
        gpsLat = target_Struct.gpsLat(subset);
        gpsLon = target_Struct.gpsLon(subset);
        % For o2 sat
        try
            o2_sat = target_Struct.o2_sat(subset);
%             figure; plot(time,o2_sat,'bo-'); datetick('x',15,'keeplimits'); title('o2 sat (Corr)');
            figure; 
            subplot(2,1,1);
            plot(time,target_Struct.tempi(subset),'-+')
            hold on;
            plot(time,target_Struct.oxyw_temp(subset),'-+')
            legend('tempi','oxyw\_temp');
            xlabel('Time');
            ylabel('Temperature (^oC)')
            datetick
%             figure
%             plot(target_Struct.oxyw_oxygen(subset),target_Struct.oxyw_temp(subset),'*-')
%             hold on
%             plot(target_Struct.oxyw_oxygen(subset),target_Struct.tempi(subset),'+-')
%             legend('oxyw\_temp','tempi');
%             title('oxyw\_oxygen')
%             figure
%             plot(target_Struct.o2_tspcorr(subset),target_Struct.oxyw_temp(subset),'*-')
%             hold on
%             plot(target_Struct.o2_tspcorr(subset),target_Struct.tempi(subset),'+-')
%             legend('oxyw\_temp','tempi');
%             title('o2\_tspcorr')
            subplot(2,1,2);
            plot(target_Struct.oxyw_oxygen(subset),target_Struct.tempi(subset),'*-')
            hold on
            plot(target_Struct.o2_tspcorr(subset),target_Struct.tempi(subset),'+-')
            legend('oxyw\_oxygen','o2\_tspcorr');
%             title('External Temperature (tempi)')
            xlabel('Dissolved Oxygen (10^{-6}mol/dm^3)');
            ylabel('Temperature (^oC)')
%             figure
%             plot(target_struct.depthi(subset),target_Struct.tempi(subset));
%             title('depth vs tepi')
%             figure
%             plot(target_struct.depthi(subset),target_Struct.o2_tspcorr(subset));
%             title('depth vs tepi')
%             ccplot_Glider_Data_t(time,P,target_Struct.o2_tspcorr(subset),'o2 tsp(Corr)',platform_Label);
%             ccplot_Glider_Data_t(time,P,target_Struct.o2_sat(subset),[min(o2_sat) max(o2_sat)],'o2 sat(Corr)',platform_Label);
%             ccplot_Glider_Data_t(time,P,o2_sat,'o2 sat (Corr)',platform_Label);
%             ccplot3_Glider_Data(gpsLon, gpsLat,P,o2_sat,[min(o2_sat) max(o2_sat)],'o2 sat (Corr)', platform_Label);
%             ccplot_Glider_Data_t(time,P,target_Struct.oxyw_oxygen(subset),'UnCorr)',platform_Label);
%             hist_Glider_Data(o2_sat,'o2 sat (Corr)', platform_Label)
            figure
            Z = target_Struct.o2_tspcorr;
            colormap jet
            ccplot(target_Struct.salini,target_Struct.tempi,Z,[nanmin(Z) nanmax(Z)],'.',10); 
            title('T-S with O_2 tsp');
            c = colorbar;
            c.Label.String = 'O_2 tsp';
            colormap jet
            xlabel('S');
            ylabel('T');
            
            figure
            Z = target_Struct.o2_sat;
            colormap jet
            ccplot(target_Struct.salini,target_Struct.tempi,Z,[nanmin(Z) nanmax(Z)],'.',10);
            c = colorbar;
            c.Label.String = 'O_2 sat';
            title('T-S with O_2 sat');
            colormap jet
            xlabel('S');
            ylabel('T');
        catch err
        end
    otherwise
        error('Unknown dataset type');
end
%{
% For nitrate
try
    no3 = target_Struct.no3(subset);
    ccplot_Glider_Data_t(time,P,no3,'Nitrate',platform_Label);
catch err
end
%}


function ccplot_Glider_Data_t(time,P,Z,bounds,var_Label, platform_Label)
length(~isnan(Z))
display_String = sprintf('%s %s %s %s\n','Plotting',var_Label,'from',platform_Label);
disp(display_String);
figure; 
colormap jet
ccplot(time,P,Z,bounds,'.',10);     
colorbar;
colormap jet
xlabel('Time');  
set(gca,'YDir','reverse'); 
title_String = sprintf('%s %s %s %s',var_Label,'(from', platform_Label, ')') 
title(title_String);
ylabel('Depth (m)');
datetick('x',6,'keeplimits');


function ccplot3_Glider_Data(gpsLon, gpsLat,P,Z,bounds,var_Label, platform_Label)
figure; 
%me_Try_Map; hold on;
colormap jet
hc = ccplot3(gpsLon, gpsLat, -P, Z, bounds, '.', 15);
title_String = sprintf('%s %s %s %s',var_Label,'(from', platform_Label, ')') 
title(title_String);
colormap jet
colorbar;
%hold on; map_SECOORA_2016;

function hist_Glider_Data(Z,var_Label, platform_Label)
% plot histograms
[N_Gliders,X_Gliders] =hist(Z,15); 
N_Gliders_Norm = N_Gliders/sum(N_Gliders);
figure; plot(X_Gliders, N_Gliders_Norm,'bo-'); xlabel(var_Label); ylabel('N (Normalized)'); 
%figure; plot(X_Gliders, log10(N_Gliders_Norm),'bo-'); xlabel(var_Label); ylabel('log10 of N'); 

%{
%% Partition
CFG.nozeros = true;
num_Window_Samples = 31;
[chl_Maxminfiltered_Gliders, chl_Spikes_Gliders, medfiltered]  = minmaxfilter_Alt( chlor', time', num_Window_Samples, CFG );

% Ccplot of partitions for this time period (assume you select a transect)
% Chl small
figure; ccplot(Xr,P,chl_Maxminfiltered_Gliders,[],'.',10); colorbar; xlabel('Cross-shelf distance (km)');  set(gca,'YDir','reverse'); title_String = sprintf('%s %s %s %s %s %s','Chlor SMALL       (from', target, '), from',t_Min_String,'to',t_Max_String); title(title_String);
hold on;
for mooring_Num = 1:3
    plot(x_r_Avg_Array(mooring(mooring_Num).x_Bin),depth_Avg_Array(mooring(mooring_Num).depth_Bin),'s','MarkerEdgeColor','k','MarkerFaceColor','k'); hold on;
end
% Chl large
if sum(~isnan(chl_Spikes_Gliders)) > 0
    figure; ccplot(Xr,P,chl_Spikes_Gliders,[],'.',10);         colorbar; xlabel('Cross-shelf distance (km)');  set(gca,'YDir','reverse'); title_String = sprintf('%s %s %s %s %s %s','Chlor LARGE       (from', target, '), from',t_Min_String,'to',t_Max_String); title(title_String);
    hold on;
    for mooring_Num = 1:3
        plot(x_r_Avg_Array(mooring(mooring_Num).x_Bin),depth_Avg_Array(mooring(mooring_Num).depth_Bin),'s','MarkerEdgeColor','k','MarkerFaceColor','k'); hold on;
    end
end


        
% Profiles of partition as well as total
figure; plot(time,P); set(gca,'YDir','reverse');
figure; plot(P(2:end),diff(P)); set(gca,'XDir','reverse'); title('Distance between samples'); xlabel('Depth (m)'); ylabel('Distance between Samples (m)'); 
figure; plot(time(2:end),diff(P),'bo-'); title('Distance between samples'); xlabel('Time'); ylabel('Distance between Samples (m)'); 
figure; plot(chl_Maxminfiltered_Gliders,P,'bo-'); ylabel('Depth (m)'); xlabel('Chl ug/l');  set(gca,'YDir','reverse'); title_String = sprintf('%s %s %s %s %s %s','Chlor Partitioned       (from', target, '), from',t_Min_String,'to',t_Max_String); title(title_String);
if sum(~isnan(chl_Spikes_Gliders)) > 0
    hold on; plot(chl_Spikes_Gliders,P,'ro-'); legend('small','large');
else
    legend('small');
end
figure; plot(chlor,P,'ko-'); ylabel('Depth (m)'); xlabel('Chl ug/l');  set(gca,'YDir','reverse'); title_String = sprintf('%s %s %s %s %s %s','Chlor Total       (from', target, '), from',t_Min_String,'to',t_Max_String); title(title_String);

%}



%{
%% ccplot of T,S,Chl
% Chl Small
figure; ccplot(S, T, chl_Maxminfiltered_Gliders, [], '.', 12); 
title_String = sprintf('%s %s %s %s','T-S color-coded by Chl Small, between',datestr(t_Min), 'and',datestr(t_Max));
        title(title_String);
        colorbar;
        %xlim([35.8 37.2]);              % for 3/7 to 3/14
        %ylim([17 24]);                  % for 3/7 to 3/14
        %caxis([0.0144    4.2552]);      % for 3/7 to 3/14
        %caxis([ 0.2394    3.0744]);    % for 2/3 to 2/15
% Chl Large
if sum(~isnan(chl_Spikes_Gliders)) > 0
    figure; ccplot(S, T, chl_Spikes_Gliders, [], '.', 12); 
    title_String = sprintf('%s %s %s %s','T-S color-coded by Chl Large, between',datestr(t_Min), 'and',datestr(t_Max));
            title(title_String);
            colorbar;
            %xlim([35.8 37.2]);              % for 3/7 to 3/14
            %ylim([17 24]);                  % for 3/7 to 3/14
            %caxis([0.3528   29.3760]);      % for 3/7 to 3/14
            %caxis([0.6552   23.8518]);     % for 2/3 to 2/15
end
% Log of Chl
% Range for 1/28 to 1/31
%figure; ccplot(S, T, log10(chlor), [-1.0214 0.6976], '.', 12); 
figure; ccplot(S, T, log10(chlor), [], '.', 12); 
title_String = sprintf('%s %s %s %s','T-S color-coded by log(Chl), between',datestr(t_Min), 'and',datestr(t_Max));
        title(title_String);
        colorbar;
        %xlim([35.8 37.2]);              % for 3/7 to 3/14
        %ylim([17 24]);                  % for 3/7 to 3/14
        %caxis([0.3528   29.3760]);      % for 3/7 to 3/14
        %caxis([0.6552   23.8518]);     % for 2/3 to 2/15

%% ccplot of T,S,no3
if no3_OK
    m = (-30)/(14);     % est. slope of T vs no3 curve
    b = 48;
    %no3_Above_Curve = no3_subset2_Medfiltered>m*T_subset2+b;
    %no3_Below_Curve = no3_subset2_Medfiltered<m*T_subset2+b-1;
    %figure; ccplot(S_subset2, T_subset2, no3_subset2_Medfiltered, [], '.', 12); 
    no3_Above_Curve = no3>m*T+b;
    no3_Below_Curve = no3<m*T+b-1;
    figure; ccplot(S(no3_Above_Curve), T(no3_Above_Curve), no3(no3_Above_Curve), [], '.', 12); 
    title_String = sprintf('%s %s %s %s','T-S color-coded by no3 (not cleaned up), between',datestr(t_Min), 'and',datestr(t_Max));
            title(title_String);
            colorbar;
            ylim([16 22]);
            xlim([36 36.7]);

    % Add density contours
    minS=36;
    maxS=36.7;
    minT=17.5;
    maxT=22;
    Sg=minS+[0:30]/30*(maxS-minS);
    Tg=minT+[0:30]'/30*(maxT-minT);
    % Use seawater state equation to return specific volume
    % anomaly SV (m^3/kg*1e-8) and the density anomaly SG (kg/m^3) 
    pdens=sw_pden(ones(size(Tg))*Sg,Tg*ones(size(Sg)),0*ones(31,31),0);
    sigma=8;
    % plot isopycnal contours
    hold on;
    [CS,H]=contour(Sg,Tg,pdens-1000,sigma,':k');
end
if no3_OK
    figure; ccplot(oxysat, T, no3, [], '.', 12); 
    title_String = sprintf('%s %s %s %s','T-oxysat color-coded by no3 (not cleaned up), between',datestr(t_Min), 'and',datestr(t_Max));
            title(title_String);
            colorbar;
            
    figure; plot(oxysat, no3, 'ko'); xlabel('oxysat'); ylabel('Nitrate');
    
    figure; plot3(oxysat, no3, S, 'ko'); 
    title_String = sprintf('%s %s %s %s','oxysat,nitrate,S (no3 not cleaned up), between',datestr(t_Min), 'and',datestr(t_Max));
            title(title_String);
            xlabel('oxysat'); ylabel('nitrate'); zlabel('S');
end


%% Rm path
rmpath('C:\Users\slockhar\Projects\LongBay\External\from_Chris_Calloway\gliderproc\MATLAB\plots')

%}
