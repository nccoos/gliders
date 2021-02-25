function processing_options = configDataProcessingSeaglider()
%CONFIGDATAPROCESSINGSEAGLIDER  Configure Seaglider glider data processing.
%
%  Syntax:
%    PROCESSING_OPTIONS = CONFIGDATAPROCESSINGSEAGLIDER()
%
%  Description:
%    PROCESSING_OPTIONS = CONFIGDATAPROCESSINGSEAGLIDER() should return a struct
%    setting the options for Seaglider glider data processing as needed by the
%    function PROCESSGLIDERDATA.
%
%  Examples:
%    processing_options = configDataProcessingSeaglider()
%
%  See also:
%    PROCESSGLIDERDATA
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>

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

  narginchk(0, 0);

  processing_options = struct();

  processing_options.time_filling = true;
  processing_options.position_filling = true;
  processing_options.depth_filling = true;
  processing_options.attitude_filling = true;
  processing_options.heading_filling = true;
  processing_options.waypoint_filling = true;

  processing_options.pressure_filtering = true;
  processing_options.pressure_filter_constant = 4; % Recommended setting from Seabird Data Processing Manual.
  processing_options.depth_ctd_derivation = true;

  processing_options.profiling_list(1).depth = 'depth_ctd';
  processing_options.profiling_list(1).time = 'time';
  processing_options.profiling_list(2).depth = 'depth';
  processing_options.profiling_list(2).time = 'time';
  % Use default values for profile identification parameters:
  % stall (3), inversion (3), and length (10), and
  % shake (20), interrupt (180), and period (0).

  processing_options.profile_min_range = 10;
  processing_options.profile_max_gap_ratio = 0.6;

  processing_options.flow_ctd_list(1).time  = 'time_ctd';
  processing_options.flow_ctd_list(1).depth = 'depth_ctd';
  processing_options.flow_ctd_list(1).pitch = 'pitch';
  processing_options.flow_ctd_list(2).time  = 'time';
  processing_options.flow_ctd_list(2).depth = 'depth_ctd';
  processing_options.flow_ctd_list(2).pitch = 'pitch';
  processing_options.flow_ctd_list(3).time  = 'time';
  processing_options.flow_ctd_list(3).depth = 'depth';
  processing_options.flow_ctd_list(3).pitch = 'pitch';
  processing_options.flow_ctd_pitch_value = [];
  processing_options.flow_ctd_min_pitch = deg2rad(11);
  processing_options.flow_ctd_min_velocity = 0.05;

  processing_options.sensor_lag_list = ...
    struct('corrected', {}, 'original', {}, 'parameters', {});

  processing_options.thermal_lag_list = ...
    struct('conductivity_corrected', {}, 'temperature_corrected', {}, ...
           'conductivity_original', {}, 'temperature_original', {}, ...
           'pressure_original', {}, 'parameters', {});

  processing_options.thermal_lag_list(1).conductivity_corrected = 'conductivity_corrected_thermal';
  processing_options.thermal_lag_list(1).temperature_corrected  = 'temperature_corrected_thermal';
  processing_options.thermal_lag_list(1).conductivity_original  = 'conductivity';
  processing_options.thermal_lag_list(1).temperature_original   = 'temperature';
  processing_options.thermal_lag_list(1).pressure_original      = 'pressure';
  processing_options.thermal_lag_list(1).constant_flow          = false;
  processing_options.thermal_lag_list(1).parameters             = 'auto';
  processing_options.thermal_lag_list(1).estimator              = @nanmedian;
  processing_options.thermal_lag_list(1).minopts                = struct();

  processing_options.salinity_list(1).salinity     = 'salinity';
  processing_options.salinity_list(1).conductivity = 'conductivity';
  processing_options.salinity_list(1).temperature  = 'temperature';
  processing_options.salinity_list(1).pressure     = 'pressure';
  processing_options.salinity_list(2).salinity     = 'salinity_corrected_thermal';
  processing_options.salinity_list(2).conductivity = 'conductivity';
  processing_options.salinity_list(2).temperature  = 'temperature_corrected_thermal';
  processing_options.salinity_list(2).pressure     = 'pressure';

  processing_options.density_list(1).density     = 'density';
  processing_options.density_list(1).salinity    = 'salinity';
  processing_options.density_list(1).temperature = 'temperature';
  processing_options.density_list(1).pressure    = 'pressure';
  processing_options.density_list(2).density     = 'density_corrected_thermal';
  processing_options.density_list(2).salinity    = 'salinity_corrected_thermal';
  processing_options.density_list(2).temperature = 'temperature';
  processing_options.density_list(2).pressure    = 'pressure';

end
