#
# Cookbook Name:: sonar_acs
# Recipe:: install_sonar
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

require 'digest/sha1'
require 'securerandom'

group node['sonarqube']['group'] do
  system true
end

user node['sonarqube']['user'] do
  gid    node['sonarqube']['group']
  system true
end

remote_file ::File.join(Chef::Config[:file_cache_path], "sonarqube-#{node['sonarqube']['version']}.zip") do
  source         "#{node['metadata']['common']['storage_url']}/sonar/sonarqube-#{node['sonarqube']['version']}.zip?name=#{node['name']}"
  mode           0644
  checksum       node['sonarqube']['checksum']
  ignore_failure true
end

archive_file "sonarqube-#{node['sonarqube']['version']}.zip" do
  path              ::File.join(Chef::Config[:file_cache_path], "sonarqube-#{node['sonarqube']['version']}.zip")
  destination       "#{node['sonarqube']['home']['dir']}/sonarqube-#{node['sonarqube']['version']}"
  owner             node['sonarqube']['user']
  group             node['sonarqube']['group']
  action            :extract
  overwrite         true
  strip_components  1
  not_if            { ::File.exist?("#{node['sonarqube']['home']['dir']}/sonarqube-#{node['sonarqube']['version']}/bin/#{node['sonarqube']['os_kernel']}/sonar.sh") }
end

template '/etc/systemd/system/sonarqube.service' do
  source 'sonarqube.service.erb'
  variables(
    service_user:  node['sonarqube']['user'],
    service_group: node['sonarqube']['group'],
    sonar_sh:      "#{node['sonarqube']['home']['dir']}/sonarqube-#{node['sonarqube']['version']}/bin/#{node['sonarqube']['os_kernel']}/sonar.sh"
  )
  mode '0755'
  action   :create
  notifies :enable, 'service[sonarqube]', :immediately
  notifies :start, 'service[sonarqube]', :immediately
end

template "#{node['sonarqube']['home']['dir']}/sonarqube-#{node['sonarqube']['version']}/conf/sonar.properties" do
  source 'sonar.properties.erb'
  mode 0600
  action :create
  notifies :restart, 'service[sonarqube]', :delayed
end

sysctl 'vm.max_map_count' do
  conf_dir '/etc/sysctl.d'
  value    262144
  action   :apply
end

sysctl 'fs.file-max' do
  conf_dir '/etc/sysctl.d'
  value    65536
  action   :apply
end

sonar_acs_configure_sonar_users 'configure_sonar_users' do
  retries         10
  retry_delay     30
  admin_password  node['metadata']['sonar']['login_password']
  # eo_username     node['metadata']['sonar']['eo_username']
  # eo_password     node['metadata']['sonar']['eo_password']
  action          :configure
  notifies        :create, 'file[sonar_users_configured]', :immediately
  notifies        :restart, 'service[sonarqube]', :immediately
  not_if          { ::File.exist?("#{Chef::Config['file_cache_path']}/sonar_users_configured") }
end

file 'sonar_admin_password_updated' do
  path   "#{Chef::Config['file_cache_path']}/sonar_admin_password_updated"
  action :nothing
end

file 'sonar_users_configured' do
  path   "#{Chef::Config['file_cache_path']}/sonar_users_configured"
  action :nothing
end

service 'sonarqube' do
  supports restart: true, reload: false, status: true
  action   [:enable, :start]
end
