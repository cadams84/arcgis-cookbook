#
# Cookbook Name:: arcgis-server
# Recipe:: portal_standby
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

if node['platform'] == 'windows'
  arcgis_server_portal 'Update Portal for ArcGIS service logon account' do
    install_dir node['arcgis']['portal']['install_dir']
    run_as_user node['arcgis']['run_as_user']
    run_as_password node['arcgis']['run_as_password']
    only_if { Utils.product_installed?(node['arcgis']['portal']['product_code']) }
    subscribes :update_account, "user[#{node['arcgis']['run_as_user']}]", :immediately
    action :nothing
  end
end

arcgis_server_portal "Install System Requirements:#{recipe_name}" do
  action :system
  only_if { node['arcgis']['portal']['install_system_requirements'] }
end

arcgis_server_portal 'Install Portal for ArcGIS' do
  install_dir node['arcgis']['portal']['install_dir']
  product_code node['arcgis']['portal']['product_code']
  data_dir node['arcgis']['portal']['data_dir']
  setup node['arcgis']['portal']['setup']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['portal']['product_code']) }
  else
    not_if { ::File.exist?(::File.join(node['arcgis']['portal']['install_dir'],
                                       node['arcgis']['portal']['install_subdir'],
                                       'startportal.sh')) }
  end
  action :install
end

arcgis_server_portal 'Configure arcgisportal service' do
  install_dir node['arcgis']['portal']['install_dir']
  only_if { node['arcgis']['portal']['configure_autostart'] }
  action :configure_autostart
end

arcgis_server_portal 'Authorize Portal for ArcGIS' do
  authorization_file node['arcgis']['portal']['authorization_file']
  authorization_file_version node['arcgis']['portal']['authorization_file_version']
  retries 5
  retry_delay 60
  not_if { ::File.exists?(node['arcgis']['portal']['cached_authorization_file']) &&
           FileUtils.compare_file(node['arcgis']['portal']['authorization_file'],
                                  node['arcgis']['portal']['cached_authorization_file']) }
  action :authorize
end

file node['arcgis']['portal']['cached_authorization_file'] do
  content File.open(node['arcgis']['portal']['authorization_file'], 'rb') { |file| file.read }
  sensitive true
  subscribes :create, 'arcgis_server_portal[Authorize Portal for ArcGIS]', :immediately
  only_if { node['arcgis']['cache_authorization_files'] }
  action :nothing
end

arcgis_server_portal 'Start Portal for ArcGIS' do
  action :start
end

arcgis_server_portal 'Join Portal Site' do
  portal_url node['arcgis']['portal']['url']
  primary_machine_url node['arcgis']['portal']['primary_machine_url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  action :join_site
end
