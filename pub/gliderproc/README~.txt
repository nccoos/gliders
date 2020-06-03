

1.  Open this folder in MATLAB (make current)

2.  Ensure that folders BATHYMETRY, GLIDER_CTD_DATA_LEVEL1 and MATLAB are added to the path.


3.  To generate plots:

    Run gliderCTD_DataViz.m to open glider plot user interface.

    Requires:
	gliderCTD_GeneratePlots.m
	gliderCTD_2DPlots.m
	gliderCTD_3DPlots.m
	BATHYMETRY folder - contains bathymetry data
	MATLAB folder - contains util, matutil, seawater, plots, strfun, opnml
	CLIDER_CTD_DATA_LEVEL1 folder - contains Level 1 .mat files


4.  To generate Level 1 glider CTD data .mat files:

    Open gliderCTD_CorrectThermalLag.m

    At top of file, set glider index, deployment number and desired correction parameters

    Run gliderCTD_CorrectThermalLag.m

    Requires:
	correctThermalLag.m
	MATLAB folder - contains util, matutil, seawater, plots, strfun, opnml




