function [sql_query, deployment_fields] = configRTDeploymentInfoQueryDB()
%CONFIGRTDEPLOYMENTINFOQUERYDB  Configure the query to retrieve real time glider deployment information.
%
%  Syntax:
%    [SQL_QUERY, DEPLOYMENT_FIELDS] = CONFIGRTDEPLOYMENTINFOQUERYDB()
%
%  Description:
%    [SQL_QUERY, DEPLOYMENT_FIELDS] = CONFIGRTDEPLOYMENTINFOQUERYDB() should 
%    return the SQL query to retrieve the information about glider deployments
%    to be processed in real time. String SQL_QUERY is the query to execute. 
%    The mapping between deployment fields and data base table columns is given 
%    by the string cell array DEPLOYMENT_FIELDS. Deployment fields are described 
%    in GETDEPLOYMENTINFODB.
%
%  Notes:
%    Edit this file filling in the field mapping of your data base and the
%    query that returns that fields for each deployment.
%
%  Examples:
%    [sql_query, deployment_fields] = configRTDeploymentInfoQueryDB()
%
%  See also:
%    GETDEPLOYMENTINFODB
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

  % Select the deployment fields.
  % First column is deployment field
  % Second column is column in data base table.
  fields_map = {
    'deployment_id'          'deployment_id'
    'deployment_name'        'deployment_name'
    'deployment_start'       'deployment_initial_date'
    'deployment_end'         'deployment_end_date'
    'glider_name'            'platform_name'
    'glider_serial'          'instrument_serial'
    'glider_model'           'instrument_model'
    'glider_instrument_name' 'instrument_name'
    'glider_deployment_code' 'deployment_code'
    % Optional fields for global attributes.
    'abstract'                     'deployment_description'
    'acknowledgement'              'deployment_acknowledgement'
    'author'                       'deployment_author'
    'author_email'                 'deployment_author_email'
    'creator'                      'deployment_author'
    'creator_email'                'deployment_author_email'
    'creator_url'                  'deployment_author_url'
    'data_center'                  'deployment_data_center'
    'data_center_email'            'deployment_data_center_email'
    'institution'                  'institution_name'
    'institution_references'       'institution_references'
    'instrument'                   'instrument_name'
    'instrument_manufacturer'      'instrument_manufacturer'
    'instrument_model'             'instrument_model'
    'license'                      'deployment_license'
    'principal_investigator'       'deployment_principal_investigator'
    'principal_investigator_email' 'deployment_principal_investigator_email'
    'project'                      'deployment_project'
    'publisher'                    'deployment_publisher_name'
    'publisher_email'              'deployment_publisher_email'
    'publisher_url'                'deployment_publisher_url'
    'summary'                      'deployment_description'
    % fields added for the EGO format
    'citation'                     'deployment_acknowledgement'
    'wmo_platform_code'            'platform_wmo_platform_code'
    'platform_code'                'platform_platform_code'
    'deployment_label'             'deployment_name'
    'id'                           'deployment_name'
    'deployment_cruise_id'         'deployment_cruise_id'
    'glider_owner'                 'institution_name'
    'operating_institution'        'deployment_data_center' 
    'platform_type'                'instrument_model'
    'platform_maker'               'instrument_manufacturer'
  };

  deployment_fields = fields_map(:,1)';
  database_fields = fields_map(:,2)';

  % Build the query.
  database_fields_str = ...
    [sprintf('%s, ', database_fields{1:end-1}) database_fields{end}];
  sql_query = ['select ' database_fields_str ...
               '  from instrumentation.deployment' ...
               '  inner join instrumentation.instrument' ...
               '    on (deployment_instrument_id=instrument_id)' ...
               '  inner join instrumentation.instrument_type' ...
               '    on (instrument_instrument_type_id=instrument_type_id)' ...
               '  inner join instrumentation.instrument_platform' ...
               '    on (instrument_platform_instrument_id=instrument_id and instrument_platform_installation_date < now() and (instrument_platform_uninstallation_date is null or instrument_platform_uninstallation_date > now()))' ...
               '  inner join instrumentation.platform' ...
               '    on (instrument_platform_platform_id = platform_id)' ...
               '  inner join instrumentation.institution' ...
               '    on (deployment_institution_id=institution_id)' ...
               '  where (instrument_type_name~*''glider'' and deployment_initial_date < now() and deployment_finished=false);'];

end
