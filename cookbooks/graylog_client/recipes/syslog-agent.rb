#
# Cookbook:: graylog-client
# Recipe:: syslog-agent
#
# Copyright:: 2020, All Rights Reserved.

require 'win32/service'

timezone 'UTC'

directory node['graylog']['client']['dir'] do
  action :create
end

remote_file "#{node['graylog']['client']['dir']}/Evtsys.zip" do
  source node['graylog']['client']['download_url']
  action :create
end

archive_file 'Evtsys.zip' do
  path "#{node['graylog']['client']['dir']}/Evtsys.zip"
  destination "#{node['graylog']['client']['dir']}/evtsys"
  not_if { ::File.exist?("#{node['graylog']['client']['dir']}/evtsys/64-Bit-LP/evtsys.exe") }
end

remote_file "#{node['graylog']['client']['dir_system32']}/evtsys.exe" do
  source "file:///#{node['graylog']['client']['dir']}/evtsys/64-Bit-LP/evtsys.exe"
end

powershell_script 'evtsys install' do
  code "#{node['graylog']['client']['dir_system32']}/evtsys.exe -i -h #{node['metadata']['graylog_client']['server_fqdn']}"
  not_if '[bool]$(Get-Service -Name evtsys -ErrorAction SilentlyContinue)'
  action :run
end

windows_service 'evtsys' do
  action :start
end
