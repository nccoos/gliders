% CTDplotY  plot CTD parameters vs depth
% =========================================================================
% CTDplotY  Version 1.0 18-May-1999
%
% Usage: 
%   CTDplotY
%
% Description:
%   This Matlab script plots temperature, salinity, and density versus depth
%   on the same figure by having floating y-axes beside the plot.
%
% Input:
%   n/a
%
% Output:
%   n/a
%
% Called by:
%   n/a
%
% Calls:
%   floatAxisY.m
%
% Author:
%   Blair Greenan
%   Bedford Institute of Oceanography
%   18-May-1999
%   Matlab 5.2.1
%   greenanb@mar.dfo-mpo.gc.ca
% =========================================================================
%

load ctd_stn72.mat
figure;
% plot temperature vs pressure
hl1=plot(pres,temp,'b-');
% assign current axis handle to variable for later reference if needed
ax1=gca;
% set properties of the axes
set(ax1,'YMinorTick','on', 'box','on','ycolor',get(hl1,'color'))
% add title to plot 
htitle = title(['Parizeau 96012  CTD Station ', num2str(Station(1)),'  ', datestr(now)]);
ylabel('Temperature (solid)')
xlabel('Depth (m)')

% add 1st floating axis for the second parameter (salinity) plotted
[hl2,ax2,ax3] = floatAxisY(pres,psal,'r:','Salinity (dotted)',[0 100 32 34]);


% add 2nd floating axis for the third parameter (density) plotted
[hl3,ax4,ax5] = floatAxisY(pres,sigp,'k--','Density (dashed)');
