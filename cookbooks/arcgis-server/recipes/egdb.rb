#
# Cookbook Name:: arcgis-server
# Recipe:: egdb
#
# Copyright 2015 Esri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

arcgis_server_server 'Register Managed Database' do
  server_url node['arcgis']['server']['private_url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  data_item_path '/enterpriseDatabases/managedDatabase'
  connection_string node['arcgis']['server']['managed_database']
  is_managed true
  action :register_database
end

arcgis_server_server 'Register Replicated Database' do
  server_url node['arcgis']['server']['private_url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  data_item_path '/namedWorkspaces/replicatedDatabase'
  connection_string node['arcgis']['server']['replicated_database']
  is_managed false
  action :register_database
end
