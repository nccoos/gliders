function [outputs, figures, meta_res, data_res] = deploymentDataProcessing(data_paths, deployment, configuration, varargin)
% DEPLOYMENTDATAPROCESSING  Process glider data of a specific deployment
%                            and given configuration
%
%  Syntax:
%    [META_RES, DATA_RES] = DEPLOYMENTDATAPROCESSING(DATA_PATH, DEPLOYMENT, CONFIG)
%    [META_RES, DATA_RES] = DEPLOYMENTDATAPROCESSING(DATA_PATH, DEPLOYMENT, CONFIG, OPT1, VAL1, ...)
%
%  Description:
%    DEPLOYMENTDATAPROCESSING processes the data of a specific deployment 
%    and path. The process includes the entire chain from Level 0 to 
%    Level 2 data. The processing chain is as follow:
%      - Select deployment configuration "processing_config". The config 
%           structure includes the configuration for all allowed gliders. 
%           The processing function calls extractDeploymentConfig for the 
%           current glider name given in the deployment definition and the 
%           configuration. 
%      - Download new or updated deployment raw data files from dockserver. 
%           This step is optional and it is performed if config.dockservers.active
%           is set to 1. Data is retrieved using the information in config.dockservers.
%      - Convert downloaded files to human readable format. This step consists 
%           of converting binary to ascii. It is optional and it is
%           selected by setting processing_config.file_options.format_conversion
%           to 1. It is necessary for Slocum data unless the files were
%           previously converted. In this case, it will save time to skip
%           this step. The conversion uses the shell dbd2asc 
%          script profided by Slocumdefined by config.wrcprogs.dbd2asc.
%      - Load data from all files in a single and consistent structure.
%      - Generate standarized product version of raw data (NetCDF level 0).
%           This step is optional and happens when the netcdf0 file name is
%           defined in the data_paths or data_paths is a directory name.
%      - Preprocess raw data applying simple unit conversions and factory
%        calibrations without modifying their nominal value:
%          -- Select reference sensors for time and space coordinates.
%             Perform unit conversions if necessary.
%          -- Select reference gps parameters for time and space coordinates.
%             Perform unit conversions if necessary.
%          -- Select extra navigation sensors: waypoints, pitch, depth...
%             Perform unit conversions if necessary.
%          -- Select sensors of interest: CTD, oxygen, ocean color...
%             Perform unit conversions and factory calibrations if necessary.
%      - Process preprocessed data to obtain well referenced trajectory data
%        with new derived measurements and corrections:
%          -- Fill missing values of time and space reference sensors.
%          -- Fill missing values of other navigation sensors.
%          -- Identify transect boundaries at waypoint changes.
%          -- Identify cast boundaries from vertical direction changes.
%          -- Apply generic sensor processings: sensor lag correction... 
%          -- Process CTD data: pressure filtering, thermal lag correction...
%          -- Derive new measurements: depth, salinity, density...
%      - Perform quality control. Currently this option is not implemented
%          but the array is created for this purpose
%      - Generate standarized product version of trajectory data (NetCDF 
%          level 1).This step is optional and happens when the netcdf0 file 
%          name is defined in the data_paths or data_paths is a directory name.
%      - Generate descriptive figures from trajectory data. This step is
%           optional and happens when the figure directory name is
%           defined in the data_paths or data_paths is a directory name.
%      - Postprocess processed data applying parameter and unit conversions
%           as defined by the additional output standard to be produced.
%           Currently, only EGO format is implemented and the changes
%           consists of:
%          -- Create juld variable.
%          -- Create phase and phase_number variables.
%          -- Rename data variables as defined by param_convert option 
%             in the configuration.
%      - Interpolate/bin trajectory data to obtain gridded data (vertical 
%        instantaneous profiles of already processed data).
%      - Generate standarized product version of gridded data (NetCDF level 2).
%           This step is optional and happens when the netcdf0 file name is
%           defined in the data_paths or data_paths is a directory name.
%      - Generate descriptive figures from gridded data. This step is
%           optional and happens when the figure directory name is
%           defined in the data_paths or data_paths is a directory name.
%
%  Inputs:
%    DATA_PATH defines the location of the input files and the products that
%      are created including netCDF files and figures. It may be a directory 
%      name or a struct in the format returned by createFStruct where the
%      binary, ascii, cache, log, figure directories and netcdf L0, L1 and L2
%      files are defined. When DATA_PATHS is a directory name, data may be
%      read and writen in the specified path or structured under a given tree
%      when the option data_tree is set to structured. In the latest case,
%      the following folders will be created under the input directory: binary, 
%      log, ascii, figure and netcdf. The files netcdf_l0.nc, netcdf_l1.nc
%      and netcdf_l2.nc are created for L0, L1 and L2 netCDF files
%      respecively.
%
%    DEPLOYMENT contains the information of the deployment to be processed.
%    It should be a structure containing the following information:
%      - deployment_start, deployment_end: deployment start and end date.
%          Optionally the deployment end date can be input as NaN if the
%          deployment is not finished.
%      - glider_name, glider_serial and glider_model: name, serial number
%          and model of the deployed glider. The glider model should comply
%          to the definition given by extractDeploymentConfig in order to
%          identify the glider type from the name format. Glider serial and name is
%          and name are only required to retrieve raw data from the dockserver.
%          The deployment information can be retrieved from a database using
%          getDeploymentInfoDB if it was previously set and defined as
%          specified by the function.
%
%    CONFIGURATION may be a struct in the format returned by SETUPCONFIGURATION.
%    It defines the parameters required along the process. Optionally, the
%    name of a configuration file can be input. In this case, the
%    SETUPCONFIGURATION function will be call to initialize the
%    configuration structure.
%
%  Outputs:
%    OUTPUTS is a structure containing the names of the NetCDF files that
%      were created along the process. The structure may contain
%      (optionally) these fields
%       - netcdf_l0:    L0 level NetCDF file
%       - netcdf_eng:   Engineering L0 level NetCDF file
%       - netcdf_l1:    L1 level NetCDF file
%       - netcdf_l2:    L2 level NetCDF file
%       - netcdf_egol0: L1 level NetCDF-EGO file
%    FIGURES is a structure containing the file names of the figures that
%      were created along the process. The structure may contain
%      (optionally) these fields
%       - fig_proc: structure with the figures of processed data
%       - fig_grid: structure with the figures of gridded data  
%    META_RES and DATA_RES are a struct containg the data and meta data at
%    a given step. The funcion returns the step as specified by the data_result
%    option. The result depends on the step that is request as:
%       - raw:  struct in the format returned by LOADSLOCUMDATA or
%               LOADSEAGLIDERDATA, where each field is a vector sequence 
%               from the sensor or variable with the same name. META_RAW 
%               should be the struct with the metadata required for the preprocessing.
%       - preprocessed: struct in the format returned by PREPROCESSGLIDERDATA
%       - processed: struct in the format returned by PROCESSGLIDERDATA
%       - qc_processed: TBD
%       - postprocessed: struct in the format returned by POSTPROCESSGLIDERDATA
%       - qc_postprocessed: struct in the format returned by POSTPROCESSQCGLIDERDATA
%       - gridded: struct in the format returned by GRIDGLIDERDATA
%    
%  Options:
%    DATA_TREE defines the tree structure when the DATA_PATHS is a
%    directory name. Values are default and structured. When the value is
%    default input and output files are read and writen in the same
%    directory (data_paths). Otherwise (data_paths=structured), a directory
%    structure is created underneath with the subfolders binary, 
%    log, ascii, figure and netcdf.
%
%    DATA_RESULT defines the product that is returned by the function. The
%    options are raw,preprocessed, processed, qc_processed, postprocessed, 
%    qc_postprocessed and gridded for the various steps of the processing.
%
%  Notes:
%    This function replaces the processing of each deployment in 
%    main_glider_data_processing_dt and main_glider_data_processing_rt. It
%    allows to either process data that exists in a given path or start by
%    retrieving raw data from a dockserver.
%
%  Examples:
%    deployment = { ...
%         'deployment_start', 7.3687e+05, ...
%         'deployment_end',   NaN, ...
%         'glider_name',     'icoast00',
%         'glider_serial',   '050', ...
%         'glider_model',    'Slocum G1 Shallow'};
%    [meta, data] = ...
%      deploymentDataProcessing('/home/glider/data', ...
%                               deployment, ...
%                               '/home/glider/config/proc.config', ...
%                               'data_tree', 'structured', ...
%                               'data_result', 'processed');
%    This calll retrieves the data from the dockserver defined by the
%    configuration  and processes all levels of data L0, L1 and L3. It 
%    returns the data and meta data structures of the process data.
%
%
%  See also:
%    CONFIGGLIDERTOOLBXPATH
%    SETUPCONFIGURATION
%    EXTRACTDEPLOYMENTCONFIG
%    GETBINARYDATA
%    CONVERTBINARYDATA
%    LOATASCIIDATA
%    PREPROCESSGLIDERDATA
%    PROCESSGLIDERDATA
%    POSTPROCESSGLIDERDATA
%    GRIDGLIDERDATA
%    PROCESSQCGLIDERDATA
%    POSTPROCESSQCGLIDERDATA
%    GENERATEGLIDERFIGURES
%    GENERATEOUTPUTNETCDF
%    GENERATEOUTPUTNETCDFPLUS
%
%  Authors:
%    Miguel Charcos Llorens  <mcharcos@socib.es>
%
%  Copyright (C) 2013-2016
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears
%  <http://www.socib.es>
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
  narginchk(3, 5);
    
  options.processing_mode = 'rt';  
  options.data_tree = 'default';
  options.data_result = '';  % (empty/other), raw, preprocessed, processed, 
                             % qc_processed, postprocessed,
                             % qc_postprocessed,gridded  
  
  %% Parse optional arguments.
  % Get option key-value pairs in any accepted call signature.
  argopts = varargin;
  if isscalar(argopts) && isstruct(argopts{1})
    % Options passed as a single option struct argument:
    % field names are option keys and field values are option values.
    opt_key_list = fieldnames(argopts{1});
    opt_val_list = struct2cell(argopts{1});
  elseif mod(numel(argopts), 2) == 0
    % Options passed as key-value argument pairs.
    opt_key_list = argopts(1:2:end);
    opt_val_list = argopts(2:2:end);
  else
    error('glider_toolbox:deploymentDataProcessing:InvalidOptions', ...
          'Invalid optional arguments (neither key-value pairs nor struct).');
  end
  % Overwrite default options with values given in extra arguments.
  for opt_idx = 1:numel(opt_key_list)
    opt = lower(opt_key_list{opt_idx});
    val = opt_val_list{opt_idx};
    if isfield(options, opt)
      options.(opt) = val;
    else
      error('glider_toolbox:deploymentDataProcessing:InvalidOption', ...
            'Invalid option: %s.', opt);
    end
  end
  
  %% Set deployment field shortcut variables and initialize other ones.
  % Initialization of big data variables may reduce out of memory problems,
  % provided memory is properly freed and not fragmented.
  if ischar(data_paths)
      if strcmp(options.data_tree, 'structured')
          binary_dir     = fullfile(data_paths, 'binary');
          cache_dir      = fullfile(data_paths, 'binary');
          log_dir        = fullfile(data_paths, 'log');
          ascii_dir      = fullfile(data_paths, 'ascii');
          figure_dir     = fullfile(data_paths, 'figure');
          netcdf_l0_file = fullfile(data_paths, 'netcdf', 'netcdf_l0.nc');
          netcdf_l1_file = fullfile(data_paths, 'netcdf', 'netcdf_l1.nc');
          netcdf_l2_file = fullfile(data_paths, 'netcdf', 'netcdf_l2.nc');
      else   %if strcmp(options.data_tree, 'default')
          binary_dir     = fullfile(data_paths);
          cache_dir      = fullfile(data_paths);
          log_dir        = fullfile(data_paths);
          ascii_dir      = fullfile(data_paths);
          figure_dir     = fullfile(data_paths);
          netcdf_l0_file = fullfile(data_paths, 'netcdf_l0.nc');
          netcdf_l1_file = fullfile(data_paths, 'netcdf_l1.nc');
          netcdf_l2_file = fullfile(data_paths, 'netcdf_l2.nc');
      end
  elseif isstruct(data_paths)
      binary_dir         = fullfile(data_paths.base_dir, data_paths.binary_path);
      cache_dir          = fullfile(data_paths.base_dir, data_paths.cache_path);
      log_dir            = fullfile(data_paths.base_dir, data_paths.log_path);
      ascii_dir          = fullfile(data_paths.base_dir, data_paths.ascii_path);
      figure_dir         = '';
      netcdf_l0_file     = '';
      netcdf_eng_file     = '';
      netcdf_l1_file     = '';
      netcdf_l2_file     = '';
      netcdf_egol1_file  = '';
      
      if isfield(data_paths,'figure_path') && ~isempty(data_paths.figure_path)
        figure_dir         = fullfile(data_paths.base_dir, data_paths.figure_path);
      end
      if isfield(data_paths,'netcdf_l0') && ~isempty(data_paths.netcdf_l0)
        netcdf_l0_file     = fullfile(data_paths.base_dir, data_paths.netcdf_l0);
      end
      if isfield(data_paths,'netcdf_eng') && ~isempty(data_paths.netcdf_eng)
        netcdf_eng_file     = fullfile(data_paths.base_dir, data_paths.netcdf_eng);
      end
      if isfield(data_paths,'netcdf_l1') && ~isempty(data_paths.netcdf_l1)
        netcdf_l1_file     = fullfile(data_paths.base_dir, data_paths.netcdf_l1);
      end
      if isfield(data_paths,'netcdf_l2') && ~isempty(data_paths.netcdf_l2)
        netcdf_l2_file     = fullfile(data_paths.base_dir, data_paths.netcdf_l2);
      end
      if isfield(data_paths,'netcdf_egol1') && ~isempty(data_paths.netcdf_egol1)
        netcdf_egol1_file     = fullfile(data_paths.base_dir, data_paths.netcdf_egol1);
      end
  else
    error('glider_toolbox:deploymentDataProcessing:InvalidOptions', ...
          'Data path input must be a string or a structure.');
  end  
  
  %% Read configuration values from configuration file
  if ischar(configuration)
      glider_toolbox_dir = configGliderToolboxPath();
      config = setupConfiguration(glider_toolbox_dir,  ...
                                    'processing_mode', options.processing_mode, ...
                                    'fconfig', configuration);
  else
      config = configuration;
  end
    
  if isempty(config) && ~isstruct(config)  
    error('glider_toolbox:deploymentDataProcessing:MissingConfiguration',...
          'Empty configuration file');
  end
  
  %source_files = {};
  %meta_raw = struct();
  %data_raw = struct();
  meta_preprocessed = struct();
  data_preprocessed = struct();
  meta_processed = struct();
  data_processed = struct();
  meta_qc_processed = struct();
  data_qc_processed = struct();
  meta_gridded = struct();
  data_gridded = struct();
  meta_postprocessed = struct();
  data_postprocessed = struct();
  meta_qc_postprocessed = struct();
  data_qc_postprocessed = struct();
  meta_res = struct();
  data_res = struct();
  outputs = struct();
  figures = struct();
  
  glider_model = deployment.glider_model;
  [glider_type, processing_config] = extractDeploymentConfig(glider_model, config);

  if isempty(glider_type)
    error('glider_toolbox:deploymentDataProcessing:InvalidGliderType', ...
        'Unknown glider model: %s.', glider_model);
  end
  
  if isfield(deployment, 'calibrations')
    processing_config.preprocessing_options.calibration_parameter_list = deployment.calibrations;
  end
  
  %% Download deployment glider files from station(s).
  user_dockserver = 0;
  if ~isempty(config.dockservers) && isfield(config.dockservers, 'active')
      user_dockserver = config.dockservers.active;
  end
  if user_dockserver
      glider_name  = deployment.glider_name;
      glider_serial = deployment.glider_serial;
      output_path = binary_dir;
      DSbin_options = struct();
      DSbin_options.start_utc = deployment.deployment_start;
      DSbin_options.end_utc = deployment.deployment_end;
      DSbin_options.remote_base_dir = config.dockservers.remote_base_dir;
      DSbin_options.remote_xbd_dir  = config.dockservers.remote_xbd_dir;
      DSbin_options.remote_log_dir  = config.dockservers.remote_log_dir;
      DSbin_options.glider = glider_name;
      if isfield(config, 'basestations')  % TODO: Check if we really need basestations
         output_path = ascii_dir;
         %DSbin_options.basestations = config.basestations;
         DSbin_options.glider = glider_serial;
      end
      try
        getBinaryData(output_path, log_dir, glider_type, ...
                    processing_config.file_options, config.dockservers.server, DSbin_options);
      catch exception
                error('glider_toolbox:deploymentDataProcessing:CallFailed', ...
                      'Error getting remote files:%s', getReport(exception, 'extended'));
      end
  end
  
  %% Convert binary data to ascii format
  if ~isfield(processing_config.file_options, 'format_conversion')
      processing_config.file_options.format_conversion = 1;
  end
  if processing_config.file_options.format_conversion
      try
        convertBinaryData( binary_dir, ascii_dir,  glider_type, ...
                           'xbd_name_pattern', processing_config.file_options.xbd_name_pattern, ...
                           'dba_name_replace', processing_config.file_options.dba_name_replace, ...
                           'cache', cache_dir, ...
                           'cmdname', fullfile(config.wrcprogs.base_dir, config.wrcprogs.dbd2asc))
      catch exception
          error('glider_toolbox:deploymentDataProcessing:ProcessError', ...
                'Error generating Ascii data from %s: %s', binary_dir, getReport(exception, 'extended'));
      end
  else
      disp('Skip binary conversion due to request of no binary format conversion');
  end

  %% Load data from ascii deployment glider files.
  try
    [meta_raw, data_raw, source_files] = loadAsciiData( ascii_dir, glider_type, deployment.deployment_start, ...
                 processing_config.file_options, 'end_utc', deployment.deployment_end);
  catch exception
      error('glider_toolbox:deploymentDataProcessing:ProcessError', ...
            'Error loading Ascii data from %s: %s', ascii_dir, getReport(exception, 'extended'));
  end
  
  if strcmp(options.data_result, 'raw')
    meta_res = meta_raw;
    data_res = data_raw;
  end

  %% Add source files to deployment structure if loading succeeded.
  if isempty(source_files)
    disp('No deployment data, processing and product generation will be skipped.');
  else
    disp(['Files loaded in deployment period: ' num2str(numel(source_files)) '.']);
    deployment.source_files = sprintf('%s\n', source_files{:});
  end


  %% Generate L0 NetCDF file (raw/preprocessed data), if needed and possible.
  if ~isempty(fieldnames(data_raw)) && ~isempty(netcdf_l0_file)
    disp('Generating NetCDF L0 output...');
    netcdf_l0_options = processing_config.netcdf_l0_options;
    try
      switch glider_type
        case {'slocum_g1' 'slocum_g2'}
          outputs.netcdf_l0 = generateOutputNetCDF( ...
            netcdf_l0_file, data_raw, meta_raw, deployment, ...
            netcdf_l0_options.variables, ...
            netcdf_l0_options.dimensions, ...
            netcdf_l0_options.attributes, ...
            'time', {'m_present_time' 'sci_m_present_time'}, ...
            'position', {'m_gps_lon' 'm_gps_lat'; 'm_lon' 'm_lat'}, ...
            'position_conversion', @nmea2deg, ...
            'vertical',            {'m_depth' 'sci_water_pressure'}, ...
            'vertical_conversion', {[]        @(z)(z * 10)}, ...
            'vertical_positive',   {'down'} );
        case 'seaglider'
          outputs.netcdf_l0 = generateOutputNetCDF( ...
            netcdf_l0_file, data_raw, meta_raw, deployment, ...
            netcdf_l0_options.variables, ...
            netcdf_l0_options.dimensions, ...
            netcdf_l0_options.attributes, ...
            'time', {'elaps_t'}, ...
            'time_conversion', @(t)(t + meta_raw.start_secs), ... 
            'position', {'GPSFIX_fixlon' 'GPSFIX_fixlat'}, ...
            'position_conversion', @nmea2deg, ...
            'vertical',            {'depth'}, ...
            'vertical_conversion', {@(z)(z * 10)}, ... 
            'vertical_positive',   {'down'} );
        case {'seaexplorer'}
          outputs.netcdf_l0 = generateOutputNetCDF( ...
              netcdf_l0_file, data_raw, meta_raw, deployment, ...
              netcdf_l0_options.variables, ...
              netcdf_l0_options.dimensions, ...
              netcdf_l0_options.attributes, ...
              'time', {'Timestamp' 'PLD_REALTIMECLOCK'}, ...
              'position', {'NAV_LONGITUDE' 'NAV_LATITUDE'; 'Lon' 'Lat'}, ...
              'position_conversion', @nmea2deg, ...
              'vertical',            {'Depth' 'SBD_PRESSURE'}, ...
              'vertical_conversion', {[]        @(z)(z * 10)}, ...
              'vertical_positive',   {'down'} );      
      end
      disp(['Output NetCDF L0 (raw data) generated: ' outputs.netcdf_l0 '.']);
    catch exception
      disp(['Error generating NetCDF L0 (raw data) output ' netcdf_l0_file ':']);
      disp(getReport(exception, 'extended'));
    end
  elseif isempty(netcdf_l0_file)
      disp('Skip generation of NetCDF L0 outputs');
  end

  %% Generate Engineering L0 NetCDF file (raw/preprocessed data), if needed and possible.
  if ~isempty(fieldnames(data_raw)) && ~isempty(netcdf_eng_file)
    disp('Generating Engineering NetCDF L0 output...');
    netcdf_eng_options = processing_config.netcdf_eng_options;
    try
      switch glider_type
        case {'slocum_g1' 'slocum_g2'}
          outputs.netcdf_eng = generateOutputNetCDF( ...
            netcdf_eng_file, data_raw, meta_raw, deployment, ...
            netcdf_eng_options.variables, ...
            netcdf_eng_options.dimensions, ...
            netcdf_eng_options.attributes, ...
            'time', {'m_present_time' 'sci_m_present_time'}, ...
            'position', {'m_gps_lon' 'm_gps_lat'; 'm_lon' 'm_lat'}, ...
            'position_conversion', @nmea2deg, ...
            'vertical',            {'m_depth' 'sci_water_pressure'}, ...
            'vertical_conversion', {[]        @(z)(z * 10)}, ...
            'vertical_positive',   {'down'} );
        case 'seaglider'
          outputs.netcdf_eng = generateOutputNetCDF( ...
            netcdf_eng_file, data_raw, meta_raw, deployment, ...
            netcdf_eng_options.variables, ...
            netcdf_eng_options.dimensions, ...
            netcdf_eng_options.attributes, ...
            'time', {'elaps_t'}, ...
            'time_conversion', @(t)(t + meta_raw.start_secs), ... 
            'position', {'GPSFIX_fixlon' 'GPSFIX_fixlat'}, ...
            'position_conversion', @nmea2deg, ...
            'vertical',            {'depth'}, ...
            'vertical_conversion', {@(z)(z * 10)}, ... 
            'vertical_positive',   {'down'} );
        case {'seaexplorer'}
          outputs.netcdf_eng = generateOutputNetCDF( ...
              netcdf_eng_file, data_raw, meta_raw, deployment, ...
              netcdf_eng_options.variables, ...
              netcdf_eng_options.dimensions, ...
              netcdf_eng_options.attributes, ...
              'time', {'Timestamp' 'PLD_REALTIMECLOCK'}, ...
              'position', {'NAV_LONGITUDE' 'NAV_LATITUDE'; 'Lon' 'Lat'}, ...
              'position_conversion', @nmea2deg, ...
              'vertical',            {'Depth' 'SBD_PRESSURE'}, ...
              'vertical_conversion', {[]        @(z)(z * 10)}, ...
              'vertical_positive',   {'down'} );      
      end
      disp(['Output NetCDF L0 (raw data) generated: ' outputs.netcdf_eng '.']);
    catch exception
      disp(['Error generating Engineering NetCDF L0 (raw data) output ' netcdf_eng_file ':']);
      disp(getReport(exception, 'extended'));
    end
  elseif isempty(netcdf_eng_file)
      disp('Skip generation of Engineering NetCDF L0 outputs');
  end

  %% Preprocess raw glider data.
  if ~isempty(fieldnames(data_raw))
    disp('Preprocessing raw data...');
    try
      if strcmp(glider_type, 'seaglider')
        seaglider_time_sensor_select = strcmp('elaps_t', {processing_config.preprocessing_options.time_list.time});
        processing_config.preprocessing_options.time_list(seaglider_time_sensor_select).conversion = @(t)(t +  meta_raw.start_secs);
      end
      
      [data_preprocessed, meta_preprocessed] = ...
        preprocessGliderData(data_raw, meta_raw, processing_config.preprocessing_options);
    catch exception
      error('glider_toolbox:deploymentDataProcessing:ProcessError', ...
            'Error preprocessing glider deployment data: %s', getReport(exception, 'extended'));
    end
  end

  if strcmp(options.data_result, 'preprocessed')
    meta_res = meta_preprocessed;
    data_res = data_preprocessed;
  end

  %% Process preprocessed glider data.
  if ~isempty(fieldnames(data_preprocessed))
    disp('Processing glider data...');
    try
      [data_processed, meta_processed] = ...
        processGliderData(data_preprocessed, meta_preprocessed, ...
                          processing_config.processing_options);
    catch exception
      error('glider_toolbox:deploymentDataProcessing:ProcessError', ...
            'Error processing glider deployment data: %s', getReport(exception, 'extended'));
    end
  end
  
  if strcmp(options.data_result, 'processed')
    meta_res = meta_processed;
    data_res = data_processed;
  end
  
  
  %% Quality control of processed glider data.
  if ~isempty(fieldnames(data_processed))
    disp('Performing quality control of glider data (Not implemented yet)...');
    try
      [data_qc_processed, meta_qc_processed] = ...
        processQCGliderData(data_processed, meta_processed); %, processing_config.postprocessing_options);
    catch exception
      error('glider_toolbox:deploymentDataProcessing:ProcessError', ...
            'Error performing QC of processed data: %s', getReport(exception, 'extended'));
    end
  end
    
  if strcmp(options.data_result, 'qc_processed')
    meta_res = meta_qc_processed;
    data_res = data_qc_processed;
  end
  
  %% Generate L1 NetCDF file (processed data), if needed and possible.
  if ~isempty(fieldnames(data_qc_processed)) && ~isempty(netcdf_l1_file)
    netcdf_l1_options = processing_config.netcdf_l1_options;
    disp('Generating NetCDF L1 output...');
    try
      outputs.netcdf_l1 = generateOutputNetCDF( ...
        netcdf_l1_file, data_qc_processed, meta_qc_processed, deployment, ...
        netcdf_l1_options.variables, ...
        netcdf_l1_options.dimensions, ...
        netcdf_l1_options.attributes);
      disp(['Output NetCDF L1 (processed data) generated: ' ...
            outputs.netcdf_l1 '.']);
    catch exception
      disp(['Error generating NetCDF L1 (processed data) output ' ...
            netcdf_l1_file ':']);
      disp(getReport(exception, 'extended'));
    end
  elseif isempty(netcdf_l1_file)
      disp('Skip generation of NetCDF L1 outputs');
  end

  %% Generate processed data figures.
  if ~isempty(fieldnames(data_qc_processed)) && ~isempty(figure_dir)
    disp('Generating figures from processed data...');
    try
      figures.figproc = generateGliderFigures( ...
        data_qc_processed, processing_config.figproc_options, ...
        'date', datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00'), ...
        'dirname', figure_dir);
    catch exception
      disp('Error generating processed data figures:');
      disp(getReport(exception, 'extended'));
    end
  end

  
  %% PostProcess and new QC of last L1 processed glider data.
  %  This step is performed when special format types are needed. 
  %  It calculates special parameters or rename as specified by the format
  %  definition
  perform_postprocessing = false;
  if ~isempty(netcdf_egol1_file) || ...
        strcmp(options.data_result, 'postprocessed')  || ...
        strcmp(options.data_result, 'qc_postprocessed')
     perform_postprocessing = true; 
  end
  if ~isempty(fieldnames(data_qc_processed)) && perform_postprocessing
    disp('Post processing processed glider data...');
    try
      [data_postprocessed, meta_postprocessed] = ...
        postProcessGliderData(data_qc_processed, meta_qc_processed, ...
                              processing_config.netcdf_egol1_options.variables, ...   %, processing_config.postprocessing_options);
                              'attributes', processing_config.netcdf_egol1_options.attributes, ...
                              'deployment', deployment);
    catch exception
      disp('Error post processing glider deployment data:');
      disp(getReport(exception, 'extended'));
      perform_postprocessing = false;
    end
    
    
    if ~isempty(fieldnames(data_postprocessed)) && perform_postprocessing
        if strcmp(options.data_result, 'postprocessed')
            meta_res = meta_postprocessed;
            data_res = data_postprocessed;
        end

        disp('QC of post processed glider data (add EGO QC keywords)...');
        try
          [data_qc_postprocessed, meta_qc_postprocessed] = ...
            postProcessQCGliderData(data_postprocessed, meta_postprocessed); %, processing_config.postprocessing_options);
        catch exception
          disp('Error performing QC of post processed glider data:');
          disp(getReport(exception, 'extended'));
        end

        if strcmp(options.data_result, 'qc_postprocessed')
            meta_res = meta_qc_postprocessed;
            data_res = data_qc_postprocessed;
        end
    end
  end
  
  if ~isempty(fieldnames(data_qc_postprocessed)) && perform_postprocessing
    %% Generate L1 NetCDF-EGO file (processed data), if needed and possible.
    if ~isempty(fieldnames(data_qc_postprocessed)) && ~isempty(netcdf_egol1_file)
    netcdf_egol1_options = processing_config.netcdf_egol1_options;
    disp('Generating NetCDF-EGO L1 output...');
    try
      outputs.netcdf_egol1 = generateOutputNetCDF( ...
        netcdf_egol1_file, data_qc_postprocessed, meta_qc_postprocessed, deployment, ...
        netcdf_egol1_options.variables, ...
        netcdf_egol1_options.dimensions, ...
        netcdf_egol1_options.attributes, ...
        'modified', datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SSZ'), ...
        'time_format', @(t)(datestr(posixtime2utc(t), 'yyyy-mm-ddTHH:MM:SSZ')), ...
        'netcdf_format', 'EGO');
      disp(['Output NetCDF-EGO L1 (processed data) generated: ' ...
            outputs.netcdf_egol1 '.']);
    catch exception
      disp(['Error generating NetCDF-EGO L1 (processed data) output ' ...
            netcdf_egol1_file ':']);
      disp(getReport(exception, 'extended'));
    end
    elseif isempty(netcdf_egol1_file)
      disp('Skip generation of NetCDF-EGO L1 outputs');      
    end
  end
   
  
  %% Check end criteria
  %  It should end if no further figure or netCDF is requested
  if isempty(netcdf_l2_file) && isempty(figure_dir) && ~strcmp(options.data_result, 'gridded')
     disp('Skip level 2. No further figure or netCDF is requested.');
     return;
  end
  
  %% Grid processed glider data.
  if ~isempty(fieldnames(data_processed))
    disp('Gridding glider data...');
    try
      [data_gridded, meta_gridded] = ...
        gridGliderData(data_processed, meta_processed, processing_config.gridding_options);
    catch exception
      error('glider_toolbox:deploymentDataProcessing:ProcessError', ...
            'Error gridding glider deployment data: %s', getReport(exception, 'extended'));
    end
  end
  
  if strcmp(options.data_result, 'gridded')
    meta_res = meta_gridded;
    data_res = data_gridded;
  end
  
  %% Generate L2 (gridded data) netcdf file, if needed and possible.
  if ~isempty(fieldnames(data_gridded)) && ~isempty(netcdf_l2_file)
    netcdf_l2_options = processing_config.netcdf_l2_options;
    disp('Generating NetCDF L2 output...');
    try
      outputs.netcdf_l2 = generateOutputNetCDF( ...
        netcdf_l2_file, data_gridded, meta_gridded, deployment, ...
        netcdf_l2_options.variables, ...
        netcdf_l2_options.dimensions, ...
        netcdf_l2_options.attributes);
      disp(['Output NetCDF L2 (gridded data) generated: ' ...
            outputs.netcdf_l2 '.']);
    catch exception
      disp(['Error generating NetCDF L2 (gridded data) output ' ...
            netcdf_l2_file ':']);
      disp(getReport(exception, 'extended'));
    end
  elseif isempty(netcdf_l2_file)
      disp('Skip generation of NetCDF L2 outputs');
  end


  %% Generate gridded data figures.
  if ~isempty(fieldnames(data_gridded)) && ~isempty(figure_dir)
    disp('Generating figures from gridded data...');
    try
      figures.figgrid = generateGliderFigures( ...
        data_gridded, processing_config.figgrid_options, ...
        'date', datestr(posixtime2utc(posixtime()), 'yyyy-mm-ddTHH:MM:SS+00:00'), ...
        'dirname', figure_dir);
    catch exception
      disp('Error generating gridded data figures:');
      disp(getReport(exception, 'extended'));
    end
  end
  
end