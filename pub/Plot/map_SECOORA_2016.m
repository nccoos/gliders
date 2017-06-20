%close all;

lonlim = [-80.5 -80];
latlim = [28 30];

[Z_elev,refvec] = etopo('C:\Users\slockhar\Projects\LongBay\Data\bathymetry\BATHYMETRY\DATA\etopo\etopo1_bed_c.flt', 1, latlim ,lonlim  );

%idx = find(Z_elev>0 | Z_elev<-150);
%Z_elev(idx) = NaN;


[Nrows, Ncols]= size(Z_elev);
Xspace = linspace(lonlim(1), lonlim(2), Ncols);
Yspace = linspace(latlim(1), latlim(2), Nrows);
[XI, YI] = meshgrid(Xspace, Yspace);

HndlBATH = surf(XI, YI, Z_elev);
%set(HndlBATH, 'facecolor', [0.75 0.75 0.75], 'edgecolor', [0.5 0.5 0.5]);
set(HndlBATH, 'facecolor', [0.75 0.75 0.75], 'edgecolor', 'none');
set(gca, 'box', 'on', 'position', [0.1227 0.2024 0.7727 0.6235]);    
% lighting and shading bath...
camlight right;
lighting phong;
material dull;
set(HndlBATH, 'edgecolor', 'none');




