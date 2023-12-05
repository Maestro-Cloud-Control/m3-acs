#
# Cookbook:: zabbix-server
# Recipe:: default
#
# Copyright:: 2019, All Rights Reserved.

eporch2_meta_data 'meta_data' do
  name 'zabbix_server'
  action :nothing
end.run_action(:update)

include_recipe 'zabbix-server::ssl'
include_recipe 'zabbix-server::install_lamp_stack'
include_recipe 'zabbix-server::install_zabbix_server'

service 'zabbix-agent' do
  action [:start, :enable]
end