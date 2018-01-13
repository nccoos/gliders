function science = gliderOptode_Generate_L1_Data(deploymentInfo,myBounds,coefficient_Struct,my_Delay_Secs,timeBase_is_oxyw_time,debug_Level)

%  gliderOptode_Generate_L1_Data.m
%
%  Purpose: Generate Level 1 data mat files that include optode DO data.
%
%  Requires:
%  MATLAB folder - contains util
%
%  Authors:  Adapted from William Stark by Harvey Seim and Chris Calloway
%            Marine Sciences Department
%            UNC-Chapel Hill
%
%  Created: March 2013
%
%///////////////////////////////////////////////////////////////////////////////

% 20150816: SBL
%{
The code was changed to generate Level-2 data sets as follows:
-I filtered T,S and delayed all of the CTD variables before using them to calculate o2_tspcorr; 
-I applied the calibration curves (slope, intercept) to calculate o2_sat.
-I output L2 mat file instead of L1 for DO.

See the writeup on DO corrections. All my changes are preceded by a comment, tagged with the string [SBL].

To run in your environment, reset datadir and strMatFilePath to your paths, commenting out or removing my paths.

Even though the only good data sets are Ramses1, Ramses2, and Pelagia3, this program generates an output mat file per deployment, per gliders. 

I have a debug_Level that you can set to generate plots. Some of the plots are
rather large, so you should set it > 0 just for one glider, one
deployment (unless you have a lot of memory).
%}
%20161017: SBL
%{
-In prep for PEACH, this is now the new L1 code i.e. reverted back to L1 instead of L2. I'm also making it a
function, putting the glider- and deployment-specific stuff into a caller so that the function is more reusable, easier to maintain.
-Some of the glider- and deployment-specific stuff is still here e.g.g in the section on APPLY CAL, there is a switch on glider as well 
as project/deploymemnt.
-Provided an option to use sensor's timestamp instead of science timestamp.
Choosing this option does not change the format of the output mat file. In other words, the attributes ptime_ebd and ptime_ebd_datenum get 
set to oxyw_time (and its datenum) prior to interp of CTD. Hopefully, this is not too confusing. It preserved the output format. 
%}

%INPUTS:
%{
-deploymentInfo: struct for custom strings including the following atrributes:
                        -projectLabel
                        -strDeploymentNumber
                        -strStartDate
                        -strEndDate
                        -strGliderName
                        -ebddir
                        -L1_CTD_Dir
myBounds: struct for bounds per variable, including the following attributes:
                        -oxyBounds
                        -satBounds
coefficient_Struct: struct for coefficients, including the following attributes: 
                        -C0coef
                        -C1coef
                        -C2coef
                        -C3coef
                        -C4coef
my_Delay_Secs: Number of seconds to delay CTD data before using it for TSP Correction

timeBase_is_oxyw_time: Boolean indicates whether to use oxyw_time or "science" time

debug_Level: 0, 1, or 2
%}

% OUTPUTS
%{
The main output is a mat file (writtent to cwd, storing DO (and related) data for the
glider/deployment specified in deploymentInfo. It also returns the last
processed science struct (which was useful for debugging at one point).

%}
% NOTES
%{
-This code is currently limited to one specific sensor, the Aanderaa Oxygen Optode 3835.
%}

% TO DO:
%{
-Shouldn't we remove points out of bounds AFTER TSP Coreection (instead of
BEFORE)?
%}


%% UNPACK
% myBounds
oxyBounds = myBounds.oxyBounds;
satBounds = myBounds.satBounds;
% deploymentInfo
projectLabel = deploymentInfo.projectLabel;
strDeploymentNumber = deploymentInfo.strDeploymentNumber;
strStartDate = deploymentInfo.strStartDate;
strEndDate = deploymentInfo.strEndDate;
strGliderName = deploymentInfo.strGliderName;
ebddir = deploymentInfo.ebddir;
L1_CTD_Dir = deploymentInfo.L1_CTD_Dir;
% Corefficients
C0coef = coefficient_Struct.C0coef;
C1coef = coefficient_Struct.C1coef;
C2coef = coefficient_Struct.C2coef;
C3coef = coefficient_Struct.C3coef;
C4coef = coefficient_Struct.C4coef;

disp(['Processing DO for ', strGliderName, ' Deployment ', strDeploymentNumber]);
disp(['lo_oxy filter = ', num2str(oxyBounds(1))]);
disp(['hi_oxy filter = ', num2str(oxyBounds(2))]);
disp(['lo_sat filter = ', num2str(satBounds(1))]);
disp(['hi_sat filter = ', num2str(satBounds(2))]);


%% READ IN EBD DATA
% declare arrays for accumulating data
oxyw_oxygen = [];
oxyw_saturation = [];
oxyw_temp = [];
oxyw_dphase = [];
% oxyw_bphase = [];
% oxyw_rphase = [];
% oxyw_bamp = [];
% oxyw_bpot = [];
% oxyw_ramp = [];
% oxyw_rawtemp = [];
oxyw_time = [];
% oxyw_installed = [];
ptime_ebd = [];

% try to load all *.ebdasc files at once...
[files, Dstruct] = wilddir(ebddir, '.ebdasc');
nfile = size(files, 1);

for i=1:nfile-1
    % protect against empty ebd file
    if(Dstruct(i).bytes>0)
        science = read_gliderasc2([ebddir, files(i,:)]);

        % if the number of values (in science.data) is less than the number
        % of vars (in science.vars), this means that the data were not
        % completely read in. To correct this, pad science.data with NaNs
        % until its length equals that of science.vars...
        if (length(science.data) < length(science.vars))
            science.data = padarray(science.data, ...
                [0 length(science.vars)-length(science.data)], ...
                NaN, 'post');
        end

        % concatenate variables with data...
        if(~isempty(science.data))
            oxyw_oxygen = [oxyw_oxygen; ...
                science.data(:,strmatch('sci_oxy3835_wphase_oxygen',...
                                     science.vars, 'exact'))];
            oxyw_saturation = [oxyw_saturation; ...
                science.data(:,strmatch('sci_oxy3835_wphase_saturation',...
                                     science.vars, 'exact'))];
            oxyw_temp = [oxyw_temp; ...
                science.data(:,strmatch('sci_oxy3835_wphase_temp',...
                                     science.vars, 'exact'))];
            oxyw_dphase = [oxyw_dphase; ...
                science.data(:,strmatch('sci_oxy3835_wphase_dphase',...
                                     science.vars, 'exact'))];
            % oxyw_bphase = [oxyw_bphase; ...
            %     science.data(:,strmatch('sci_oxy3835_wphase_bphase',...
            %                          science.vars, 'exact'))];
            % oxyw_rphase = [oxyw_rphase; ...
            %     science.data(:,strmatch('sci_oxy3835_wphase_rphase',...
            %                          science.vars, 'exact'))];
            % oxyw_bamp = [oxyw_bamp; ...
            %     science.data(:,strmatch('sci_oxy3835_wphase_bamp',...
            %                          science.vars, 'exact'))];
            % oxyw_bpot = [oxyw_bpot; ...
            %     science.data(:,strmatch('sci_oxy3835_wphase_bpot',...
            %                          science.vars, 'exact'))];
            % oxyw_ramp = [oxyw_ramp; ...
            %     science.data(:,strmatch('sci_oxy3835_wphase_ramp',...
            %                          science.vars, 'exact'))];
            % oxyw_rawtemp = [oxyw_rawtemp; ...
            %     science.data(:,strmatch('sci_oxy3835_wphase_rawtemp',...
            %                          science.vars, 'exact'))];
            if timeBase_is_oxyw_time
                oxyw_time = [oxyw_time; ...
                    science.data(:,strmatch('sci_oxy3835_wphase_timestamp',...
                                      science.vars, 'exact'))];
            end
            % oxyw_installed = [oxyw_installed; ...
            %     science.data(:,strmatch('sci_oxy3835_wphase_is_installed',...
            %                          science.vars, 'exact'))];
            ptime_ebd = [ptime_ebd; ...
                science.data(:,strmatch('sci_m_present_time',...
                                     science.vars, 'exact'))];
        end

        science = [];
    end  
end


%% WHICH TIME BASE TO USE
if timeBase_is_oxyw_time
    display_String = sprintf('%s %s %s %s\n','len(sci_m_present_time)=',int2str(length(~isnan(ptime_ebd))),'; len(sci_oxy3835_wphase_timestamp)=',int2str(length(~isnan(oxyw_time))));
    disp(display_String)
    % science time or oxyw time
    display_String = sprintf('%s %s %s %s\n','len(ptime_ebd)=',int2str(length(ptime_ebd)),'; len(oxyw_time)=',int2str(length(oxyw_time)));
    disp(display_String)
    display_String = sprintf('%s %s %s %s\n','len(~isnan(ptime_ebd))=',int2str(length(~isnan(ptime_ebd))),'; len(~isnan(oxyw_time))=',int2str(length(~isnan(oxyw_time))));
    disp(display_String)
end
sampleInterval_Centers = [-1 0 0.1 1 2 3 4 5 10 30 100 300 1000 3000];

% Look at science time
figure; plot(ptime_ebd,'bo-'); title('Sample time for sci-m-present-time, before sorting'); xlabel('Sample Number'); ylabel('Secs since 1/1/1970');
ptime_ebdgt0 = ptime_ebd(ptime_ebd>0);
plot0 = zeros(1,length(ptime_ebdgt0));
figure; plot(ptime_ebdgt0,plot0,'bo-'); title('Sample time for sci-m-present-time>0, before sorting'); xlabel('Secs since 1/1/1970');
figure; plot(diff(ptime_ebdgt0),'bo-'); title('Sample interval for sci-m-present-time>0, before sorting'); xlabel('Sample Number'); ylabel('Secs');
[N,X] = hist(diff(ptime_ebdgt0)); 
figure; plot(X,N,'ko-'); title('Histogram of sample interval for sci-m-present-time>0, before sorting'); xlabel('Secs');

if timeBase_is_oxyw_time
    % Look at oxyw time
    figure; plot(oxyw_time,'bo-'); title('Sample time for oxyw'); xlabel('Sample Number'); ylabel('Secs since 1/1/1970');
    oxyw_timegt0 = oxyw_time(oxyw_time>0);
    plot0 = zeros(1,length(oxyw_timegt0));
    figure; plot(oxyw_timegt0,plot0,'ro-'); title('Sample time>0 for oxyw, before sorting'); xlabel('Secs since 1/1/1970');
    figure; plot(diff(oxyw_timegt0),'bo-'); title('Sample interval for oxyw>0, before sorting'); xlabel('Sample Number'); ylabel('Secs');
    [N,X] = hist(diff(oxyw_timegt0)); 
    figure; plot(X,N,'ko-'); title('Histogram of sample interval for oxyw, before sorting'); xlabel('Secs');

    % Compare time bases
    plot0 = zeros(1,length(ptime_ebdgt0));
    figure; plot(ptime_ebdgt0,plot0,'bo-'); hold on;
    plot0 = zeros(1,length(oxyw_timegt0));
    plot(oxyw_timegt0,plot0,'ro-'); hold on;
    plot0 = zeros(1,length(ptime_ebdgt0(oxyw_time<=0)));
    plot(ptime_ebdgt0(oxyw_time<=0),plot0,'k+-'); 
    legend('sci','oxyw_time>0','oxyw_time<=0'); xlabel('Secs since 1/1/1970');
end


%% GET STATS ON L0 DATA
bin_Centers_oxyw_oxygen = [10:10:300];
[N1_oxyw_oxygen,X1_oxyw_oxygen] = hist(oxyw_oxygen,bin_Centers_oxyw_oxygen);
bin_Centers_oxyw_saturation = [10:10:150];
[N1_oxyw_saturation,X1_oxyw_saturation] = hist(oxyw_saturation,bin_Centers_oxyw_saturation);


%% QC
% remove nans from EBD data...
i = find(~isnan(oxyw_dphase));
disp_String = sprintf('%s %s %s','Keeping',int2str(length(i)),'~isnan');
disp(disp_String);
oxyw_dphase = oxyw_dphase(i);
ptime_ebd = ptime_ebd(i);
oxyw_oxygen = oxyw_oxygen(i);
oxyw_saturation = oxyw_saturation(i);
oxyw_temp = oxyw_temp(i);
% oxyw_bphase = oxyw_bphase(i);
% oxyw_rphase = oxyw_rphase(i);
% oxyw_bamp = oxyw_bamp(i);
% oxyw_bpot = oxyw_bpot(i);
% oxyw_ramp = oxyw_ramp(i);
% oxyw_rawtemp = oxyw_rawtemp(i);
if timeBase_is_oxyw_time
    oxyw_time = oxyw_time(i);
end
% oxyw_installed = oxyw_installed(i);

% remove unreasonably low oxygen values from EBD data...
i = find(gt(oxyw_oxygen, oxyBounds(1)));
disp_String = sprintf('%s %s %s','Keeping',int2str(length(i)),'samples above Low Val');
disp(disp_String);
oxyw_oxygen = oxyw_oxygen(i);
ptime_ebd = ptime_ebd(i);
oxyw_saturation = oxyw_saturation(i);
oxyw_dphase = oxyw_dphase(i);
oxyw_temp = oxyw_temp(i);
% oxyw_bphase = oxyw_bphase(i);
% oxyw_rphase = oxyw_rphase(i);
% oxyw_bamp = oxyw_bamp(i);
% oxyw_bpot = oxyw_bpot(i);
% oxyw_ramp = oxyw_ramp(i);
% oxyw_rawtemp = oxyw_rawtemp(i);
if timeBase_is_oxyw_time
    oxyw_time = oxyw_time(i);
end
% oxyw_installed = oxyw_installed(i);

% remove unreasonably high oxygen values from EBD data...
i = find(lt(oxyw_oxygen, oxyBounds(2)));
disp_String = sprintf('%s %s %s','Keeping',int2str(length(i)),'samples below Hi Val');
disp(disp_String);        
oxyw_oxygen = oxyw_oxygen(i);
ptime_ebd = ptime_ebd(i);
oxyw_saturation = oxyw_saturation(i);
oxyw_dphase = oxyw_dphase(i);
oxyw_temp = oxyw_temp(i);
% oxyw_bphase = oxyw_bphase(i);
% oxyw_rphase = oxyw_rphase(i);
% oxyw_bamp = oxyw_bamp(i);
% oxyw_bpot = oxyw_bpot(i);
% oxyw_ramp = oxyw_ramp(i);
% oxyw_rawtemp = oxyw_rawtemp(i);
if timeBase_is_oxyw_time
    oxyw_time = oxyw_time(i);
end
% oxyw_installed = oxyw_installed(i);

% remove unreasonably low saturation values from EBD data...
i = find(gt(oxyw_saturation, satBounds(1)));
disp_String = sprintf('%s %s %s','Keeping',int2str(length(i)),'samples above Low Sat Val');
disp(disp_String);        
oxyw_saturation = oxyw_saturation(i);
ptime_ebd = ptime_ebd(i);
oxyw_oxygen = oxyw_oxygen(i);
oxyw_dphase = oxyw_dphase(i);
oxyw_temp = oxyw_temp(i);
% oxyw_bphase = oxyw_bphase(i);
% oxyw_rphase = oxyw_rphase(i);
% oxyw_bamp = oxyw_bamp(i);
% oxyw_bpot = oxyw_bpot(i);
% oxyw_ramp = oxyw_ramp(i);
% oxyw_rawtemp = oxyw_rawtemp(i);
if timeBase_is_oxyw_time
    oxyw_time = oxyw_time(i);
end
% oxyw_installed = oxyw_installed(i);

% remove unreasonably high saturation values from EBD data...
i = find(lt(oxyw_saturation, satBounds(2)));
disp_String = sprintf('%s %s %s','Keeping',int2str(length(i)),'samples below Hi Sat Val');
disp(disp_String);  
oxyw_saturation = oxyw_saturation(i);
ptime_ebd = ptime_ebd(i);
oxyw_oxygen = oxyw_oxygen(i);
oxyw_dphase = oxyw_dphase(i);
oxyw_temp = oxyw_temp(i);
% oxyw_bphase = oxyw_bphase(i);
% oxyw_rphase = oxyw_rphase(i);
% oxyw_bamp = oxyw_bamp(i);
% oxyw_bpot = oxyw_bpot(i);
% oxyw_ramp = oxyw_ramp(i);
% oxyw_rawtemp = oxyw_rawtemp(i);
if timeBase_is_oxyw_time
    oxyw_time = oxyw_time(i);
end
% oxyw_installed = oxyw_installed(i);

% apply the sort() function to ptime_oxy
% to make sure it increases monotonically...
[Y,I] = sort(ptime_ebd);
ptime_ebd = Y;
oxyw_oxygen = oxyw_oxygen(I);
oxyw_saturation = oxyw_saturation(I);
oxyw_temp = oxyw_temp(I);
oxyw_dphase = oxyw_dphase(I);
% oxyw_bphase = oxyw_bphase(I);
% oxyw_rphase = oxyw_rphase(I);
% oxyw_bamp = oxyw_bamp(I);
% oxyw_bpot = oxyw_bpot(I);
% oxyw_ramp = oxyw_ramp(I);
% oxyw_rawtemp = oxyw_rawtemp(I);
if timeBase_is_oxyw_time
    oxyw_time = oxyw_time(I);
end
% oxyw_installed = oxyw_installed(I);


%% DECIDE ON TIME BASE
if timeBase_is_oxyw_time
    ptime = oxyw_time;    
    ptime_Descrip = 'oxy time';
else
    ptime = ptime_ebd;
    ptime_Descrip = 'science time';
end

% remove samples where ptime is zero or NaN
i = find(ptime>0);
disp_String = sprintf('%s %s %s','Keeping',int2str(length(i)),'samples where ptime>0');
disp(disp_String);  
oxyw_saturation = oxyw_saturation(i);
ptime_ebd = ptime_ebd(i);
oxyw_oxygen = oxyw_oxygen(i);
oxyw_dphase = oxyw_dphase(i);
oxyw_temp = oxyw_temp(i);
% oxyw_bphase = oxyw_bphase(i);
% oxyw_rphase = oxyw_rphase(i);
% oxyw_bamp = oxyw_bamp(i);
% oxyw_bpot = oxyw_bpot(i);
% oxyw_ramp = oxyw_ramp(i);
% oxyw_rawtemp = oxyw_rawtemp(i);
ptime = ptime(i);
% oxyw_installed = oxyw_installed(i);

ptime_datenum = (ptime/3600/24) + datenum(1970, 1, 1, 0, 0, 0);


%% PLOT STATS ON L0 DATA AFTER QC (BOUNDS)
[N2_oxyw_oxygen,X2_oxyw_oxygen] = hist(oxyw_oxygen,bin_Centers_oxyw_oxygen);
[N2_oxyw_saturation,X2_oxyw_saturation] = hist(oxyw_saturation,bin_Centers_oxyw_saturation)


%% PREP CTD DATA
% load CTD data from existing mat file...
L1_CTD_Mat_Fullpath = strcat(L1_CTD_Dir,strGliderName, '_Deployment', strDeploymentNumber, '_CTD_L1.mat');
ctd = load(L1_CTD_Mat_Fullpath);
length(ctd.ptime)

% Plot originals e.g. comparing internal and external temperatures, before doing any resampling, filtering, delay, etc. [SBL]
if debug_Level > 1            
    % convert original ptime (from CTD) into datenum style
    ptime_datenum_CTD = (ctd.ptime/3600/24) + datenum(1970, 1, 1, 0, 0, 0);
    title_String = sprintf('%s %s %s',strGliderName, 'Deployment', strDeploymentNumber);
    legend_String1 = sprintf('%s %s %s','T CTD without interp, without delay');
    figure; plot(ptime_datenum_CTD,ctd.temp,'bo', ptime_datenum,oxyw_temp,'ro'); legend(legend_String1,'oxyw temp'); title(title_String)
    datetick('x',7,'keeplimits');
    figure; plot(ptime_datenum,oxyw_dphase,'ro'); title(title_String); ylabel('dphase');
    datetick('x',7,'keeplimits')
end

% Sample CTD data at a regular interval [SBL]
% (This step is needed because we need to filter the CTD Data, below.)
my_SampleInterval_Secs = 3;
ptime_Regular = ctd.ptime(1):my_SampleInterval_Secs:ctd.ptime(end);
temp_Regular = interp1(ctd.ptime,ctd.temp,ptime_Regular);
salin_Regular = interp1(ctd.ptime,ctd.salinCorrected,ptime_Regular);
dens_Regular = interp1(ctd.ptime,ctd.densCorrected,ptime_Regular);
depth_Regular = interp1(ctd.ptime,ctd.depth,ptime_Regular); 
gpsLat_Regular = interp1(ctd.ptime,ctd.gpsLat,ptime_Regular); 
gpsLon_Regular = interp1(ctd.ptime,ctd.gpsLon,ptime_Regular); 

% Verify resampling [SBL]
if debug_Level > 1
    median_Ts_Original = median(diff(ctd.ptime));
    display_String = sprintf('%s %s','Median of original sample intervals of CTD data =',num2str(median_Ts_Original));
    figure; hist(log10(diff(ctd.ptime)),25); title('log10 of original sample intervals from CTD data');
    figure; plot(log10(diff(ctd.ptime))); title('log10 of original sample intervals from CTD data');
    figure; plot(log10(diff(ptime_Regular))); title('log10 of new regular sample intervals from CTD data, after resampling');
end

% Filter the regularly sampled CTD Data (T,S) before using it [SBL]
Tc_Minutes = 0.5;
Tc_Secs = Tc_Minutes*60;
Fc_Samples_Per_Sec = 1/Tc_Secs;
Fs = 1/my_SampleInterval_Secs;
Fc_Normalized = Fc_Samples_Per_Sec/(Fs/2);
[b,a] = butter(4,Fc_Normalized,'low');
[H,F] = freqz(b,a,100,Fs);
temp_Filtered = filtfilt(b,a,temp_Regular);
salin_Filtered = filtfilt(b,a,salin_Regular);  
dens_Filtered = filtfilt(b,a,dens_Regular); 

% Delay CTD Data
% my_Delay_Secs = 27;
ptime_Regular = ptime_Regular + my_Delay_Secs;


%% INTEGRATE WITH CTD DATA
% interpolate regular, delayed CTD to irregular times of DO sensor [SBL]
tempi = interp1(ptime_Regular,temp_Filtered,ptime);
salini = interp1(ptime_Regular,salin_Filtered,ptime);
densi = interp1(ptime_Regular,dens_Filtered,ptime);
depthi = interp1(ptime_Regular,depth_Regular,ptime);
gpsLati = interp1(ptime_Regular,gpsLat_Regular,ptime);
gpsLoni = interp1(ptime_Regular,gpsLon_Regular,ptime);

% Verify filtered, delayed tempi [SBL]
if debug_Level > 1
    %figure; loglog(F,abs(H)); title('LP Filter')
    title_String = sprintf('%s %s %s','External T is from CTD Filtered, Delayed',num2str(my_Delay_Secs), 'secs and then Interped to DO time');
    figure; plot(ptime_datenum,tempi,'bo', ptime_datenum,oxyw_temp,'ro'); legend('external','internal'); title(title_String)
    datetick('x',7,'keeplimits');
end


%% TSP CORRECTIONS
% first, implement temperature-dependent correction to DO concentration
% that utilizes dphase as the input (manual page 30), coefficients from cal
% sheets (a 5x4 matrix of values) and will be glider (and foil) dependent.
C0 = C0coef(1) + (C0coef(2) .* tempi) + ...
    (C0coef(3) .* (tempi.^2)) + (C0coef(4) .* (tempi.^3));
C1 = C1coef(1) + (C1coef(2) .* tempi) + ...
    (C1coef(3) .* (tempi.^2)) + (C1coef(4) .* (tempi.^3));
C2 = C2coef(1) + (C2coef(2) .* tempi) + ...
    (C2coef(3) .* (tempi.^2)) + (C2coef(4) .* (tempi.^3));
C3 = C3coef(1) + (C3coef(2) .* tempi) + ...
    (C3coef(3) .* (tempi.^2)) + (C3coef(4) .* (tempi.^3));
C4 = C4coef(1) + (C4coef(2) .* tempi) + ...
    (C4coef(3) .* (tempi.^2)) + (C4coef(4) .* (tempi.^3));

o2_tcorr = C0 + (C1 .* oxyw_dphase) + (C2 .* (oxyw_dphase.^2)) + ...
    (C3 .* (oxyw_dphase.^3)) + (C4 .* (oxyw_dphase.^4));


% second, implement the salinity correction to DO concentration (page 31)
% ASSUMES DEFAULT SALINITY IN SENSOR WAS SET TO ZERO, OTHERWISE ANOHTER
% SCALING IS REQUIRED
B0=-6.24097e-3;
B1=-6.93498e-3;
B2=-6.90358e-3;
B3=-4.29155e-3;
C0=-3.11680e-7;

Ts = log((298.15 - tempi) ./ (273.15 + tempi));

o2_tscorr = o2_tcorr .* ...
    exp((salini .* (B0 + (B1 .* Ts) + (B2 .* (Ts.^2)) + ...
                    (B3 .* (Ts.^3))))  + ...
    (C0 .* (salini.^2)));

% third, implement the pressure correction to DO concentration (page 32)
o2_tspcorr = o2_tscorr .* (1 + (0.04 .* depthi ./ 1000));


% %% APPLY CAL
% % Apply calibration values (slope and intercept) [SBL]
% switch projectLabel
%     case {'LongBay_2012','SECOORA_2016','PEACH_2017'}                % Same cal applies to both LongBay_2012 and SECOORA_2016
%         pieceWise = false;
%         switch strGliderName
%             case 'Pelagia'
%                 % Pelagia
%                 % Only deployment 3 was good wrt o2, but we'll apply the
%                 % same cal to all three deployments.
%                 if ~pieceWise
%                     cal_Slope = 0.8152;
%                     cal_Intercept = 15.5331;
%                     o2_tspcorr = cal_Slope*o2_tspcorr + cal_Intercept;
%                 else
%                     % Try piece-wise linear
%                     pelagia_set1 = (o2_tspcorr<=138.5200);
%                     if ~isempty(pelagia_set1)
%                         o2_tspcorr(pelagia_set1) = 0.9764*o2_tspcorr(pelagia_set1)+7.1456;
%                     end                
%                     pelagia_set2 = (o2_tspcorr>138.5200);
%                     if ~isempty(pelagia_set2)               
%                         o2_tspcorr(pelagia_set2) = 0.6791*o2_tspcorr(pelagia_set2)+48.3350; 
%                     end
%                 end
%             case 'Ramses'
%                 % Ramses
%                 % Deployments 1 and 2 are good wrt o2, but we'll apply the
%                 % same cal to all three deployments.
%                 if ~pieceWise
%                     cal_Slope = 1.2536;
%                     cal_Intercept = -15.7650;
%                     o2_tspcorr = cal_Slope*o2_tspcorr + cal_Intercept;
%                 else
%                     % Try piece-wise linear
%                     ramses_set1 = (o2_tspcorr<=103.4000);
%                     if ~isempty(ramses_set1)
%                         o2_tspcorr(ramses_set1) = 1.0704*o2_tspcorr(ramses_set1)-6.8814;
%                     end
%                     ramses_set2 = (o2_tspcorr>103.4000);
%                     if ~isempty(ramses_set2)
%                         o2_tspcorr(ramses_set2) = 1.3537*o2_tspcorr(ramses_set2)-36.1683;
%                     end
%                 end
%             otherwise
%                 % Do nothing for now, but add a case for PEACH in the
%                 % future.
%         end
%     otherwise
%         error('Unknown project label');
% end

%% CALC SATURATION
% use polynomial to calculate DO saturations using the measured temp and
% sal (manual page 30)
A0 = 2.00856;
A1 = 3.22400;
A2 = 3.99063;
A3 = 4.80299;
A4 = 9.78188e-1;
A5 = 1.71069;
B0 = -6.24097e-3;
B1 = -6.93498e-3;
B2 = -6.90358e-3;
B3 = -4.29155e-3;
C0 = -3.11680e-7;

% need interpolated temp, salinity, pressure at times of DO obs
rslt = (A0 + (A1 .* Ts) + (A2 .* (Ts.^2)) + (A3 .* (Ts.^3)) + ...
       (A4 .* (Ts.^4)) + (A5 .* (Ts.^5))) + ...
    (salini .* (B0 + (B1 .* Ts) + (B2 .* (Ts.^2)) + (B3 .*(Ts.^3)))) + ...
    (C0 .* (salini.^2));

o2_sol = exp(rslt);

o2_sat = (o2_tspcorr .* 2.2414) ./ o2_sol;
% Check hist of o2_sat [SBL]
if debug_Level > 0
    titleString = sprintf('%s %s %s','02 Saturation for',strGliderName,strDeploymentNumber);
    figure; hist(o2_sat); title(titleString); xlabel('Percent Saturation')
    titleString = sprintf('%s %s %s','02 Saturation vs External Temperature for',strGliderName,strDeploymentNumber);
    %figure; scatter(tempi,o2_sat,'bo'); title(titleString); xlabel('degrees C'); ylabel('Percent Saturation');
    %titleString = sprintf('%s %s %s','TSP 02 vs External Temperature for',strGliderName,strDeploymentNumber);
    %figure; scatter(tempi,o2_tspcorr,'bo'); title(titleString); xlabel('degrees C'); ylabel('10e-6 mol/dm3');
end


%% PREP OUTPUT
% create configuration struct...
units = struct( ...
    'gpsLati', 'decimal degrees',...
    'gpsLoni', 'decimal degrees',...
    'ptime', 'seconds since 0000-01-01T00:00', ...
    'ptime_datenum', 'days since 1970-01-01T00:00', ...
    'depthi', 'meters', ...
    'oxyw_oxygen', '10e-6 mol/dm3', ...
    'oxyw_saturation', 'percent', ...
    'oxyw_temp', 'degrees C', ...
    'oxyw_dphase', 'degrees', ...
    ... % 'oxyw_bphase', 'degrees', ...
    ... % 'oxyw_rphase', 'degrees', ...
    ... % 'oxyw_bamp', 'mA', ...
    ... % 'oxyw_bpot', 'mV', ...
    ... % 'oxyw_ramp', 'mA', ...
    ... % 'oxyw_rawtemp', 'degrees C', ...
    ... % 'oxyw_time', 'timestamp', ...
    ... % 'oxyw_installed', 'bool', ...    
    'tempi', 'degrees C', ...
    'salini', 'psu', ...
    'densi','kg m-3',...  
    'o2_tcorr', '10e-6 mol/dm3', ...
    'o2_tscorr', '10e-6 mol/dm3', ...
    'o2_tspcorr', '10e-6 mol/dm3', ...
    'o2_sol', 'cm3/liter at 1031 hPa', ...
    'o2_sat', 'percent');

variable_description = struct( ...
    'gpsLati', 'interpolated Latitude, from CTD dataset',...
    'gpsLoni', 'interpolated Longitude, from CTD dataset',...
    'ptime', ptime_Descrip, ...
    'ptime_datenum', 'ptime in datenum format', ...
    'depthi', 'interpolated CTD depth', ...   
    'oxyw_oxygen', 'dissolved oxygen', ...
    'oxyw_saturation', 'dissolved oxygen saturation', ...
    'oxyw_temp', 'water temperature', ...
    'oxyw_dphase', 'phase difference', ...
    ... % 'oxyw_bphase', 'blue phase', ...
    ... % 'oxyw_rphase', 'red phase', ...
    ... % 'oxyw_bamp', 'blue current bias', ...
    ... % 'oxyw_bpot', 'blue voltage bias', ...
    ... % 'oxyw_ramp', 'red current bias', ...
    ... % 'oxyw_rawtemp', 'raw water temperature', ...
    ... % 'oxyw_time', 'optode timestampe', ...
    ... % 'oxyw_installed', 'bool', ...    
    'tempi', 'filtered, interpolated CTD water temperature', ...
    'salini', 'corrected, filtered, interpolated CTD salinity', ...
    'densi', 'corrected, filtered, interpolated CTD density ',...
    'o2_tcorr', 'temperature corrected dissolved oxygen', ...
    'o2_tscorr', 'temperature and salinity corrected dissolved oxygen', ...
    'o2_tspcorr', 'temperature, salinity, and pressure corrected dissolved oxygen', ...
    'o2_sol', 'corrected oxygen solubility', ...
    'o2_sat', 'corrected oxygen saturation');

correction_coefficients = struct('C0coef', C0coef, ...
                                 'C1coef', C1coef, ...
                                 'C2coef', C2coef, ...
                                 'C3coef', C3coef, ...
                                 'C4coef', C4coef);

config = struct('glider_name', strGliderName,...
                'deployment_number', strDeploymentNumber,...
                'start_date', strStartDate,...
                'end_date', strEndDate,...
                'correction_coefficients', correction_coefficients,...
                'var_descriptions', variable_description,...
                'var_units', units);

% set Level 2 data mat file name...
strMatFileName = strcat(strGliderName, '_Deployment', strDeploymentNumber, '_DO_L1.mat');

pwd


%% OUTPUT
% save flight data to mat file...
save(strMatFileName,...
     'config', ...
     'gpsLati', ...
     'gpsLoni', ...
     'ptime', ...
     'ptime_datenum', ...
     'depthi', ...
     'oxyw_oxygen', ...
     'oxyw_saturation', ...
     'oxyw_temp', ...
     'oxyw_dphase', ...
     ... % 'oxyw_bphase', ...
     ... % 'oxyw_rphase', ...
     ... % 'oxyw_bamp', ...
     ... % 'oxyw_bpot', ...
     ... % 'oxyw_ramp', ...
     ... % 'oxyw_rawtemp', ...
     ... % 'oxyw_time', ...
     ... % 'oxyw_installed', ...    
     'tempi', ...
     'salini', ...
     'densi',...
     'o2_tcorr', ...
     'o2_tscorr', ...
     'o2_tspcorr', ...
     'o2_sol', ...
     'o2_sat');
 
 
 %% PLOT STATS ON L1 DATA
[N3_o2_tspcorr,X3_o2_tspcorr] = hist(o2_tspcorr,bin_Centers_oxyw_oxygen);
figure; semilogy(X1_oxyw_oxygen,N1_oxyw_oxygen,'ko-'); hold on;
        semilogy(X2_oxyw_oxygen,N2_oxyw_oxygen,'rs--'); hold on;
        semilogy(X3_o2_tspcorr,N3_o2_tspcorr,'b+-');
        xlabel('[O2]'); ylabel('Num Occurs'); 
        legend('L0','L0+Bounds','L1');
[N3_o2_sat,X3_o2_sat] = hist(o2_sat,bin_Centers_oxyw_saturation);
figure; semilogy(X1_oxyw_saturation,N1_oxyw_saturation,'ko-'); hold on;
        semilogy(X2_oxyw_saturation,N2_oxyw_saturation,'rs--'); hold on;
        semilogy(X3_o2_sat,N3_o2_sat,'b+-');
        xlabel('O2 %Sat Level1 (QC + TSP Corr)'); ylabel('Num Occurs');
        legend('L0','L0+Bounds','L1');

