% CTDplotX  plot CTD parameters vs depth
% =========================================================================
% CTDplotX  Version 1.0 18-May-1999
%
% Usage: 
%   CTDplotX
%
% Description:
%   This Matlab script plots temperature, salinity, and density versus depth
%   on the same figure by having floating x-axes below the plot.
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
%   floatAxisX.m
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
hl1=plot(temp,pres,'b-');
% assign current axis handle to variable for later reference if needed
ax1=gca;
% set properties of the axes
set(ax1,'XMinorTick','on','ydir','reverse', 'box','on','xcolor',get(hl1,'color'))
% add title to plot 
htitle = title(['Parizeau 96012  CTD Station ', num2str(Station(1)),'  ', datestr(now)]);
xlabel('Temperature (solid)')
ylabel('Depth (m)')

% add 1st floating axis for the second parameter (salinity) plotted
[hl2,ax2,ax3] = floatAxisX(psal,pres,'r:','Salinity (dotted)',[32 34 0 100]);
set(ax2,'ydir','reverse')


% add 2nd floating axis for the third parameter (density) plotted
[hl3,ax4,ax5] = floatAxisX(sigp,pres,'k--','Density (dashed)');
set(ax4,'ydir','reverse')
