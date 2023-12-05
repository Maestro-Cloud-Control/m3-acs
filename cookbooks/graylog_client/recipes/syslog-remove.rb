#
# Cookbook:: graylog-client
# Recipe:: syslog-remove
#
# Copyright:: 2020, All Rights Reserved.

require 'win32/service'

windows_service 'evtsys' do
  action :stop
end

powershell_script 'evtsys_delete' do
  code "#{node['graylog']['client']['dir_system32']}/evtsys.exe -u"
  action :run
  only_if '[bool]$(Get-Service -Name evtsys -ErrorAction SilentlyContinue)'
end
