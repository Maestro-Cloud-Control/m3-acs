#
# Cookbook:: zabbix-client
# Recipe:: default
#
# Copyright:: 2019, All Rights Reserved.

# chef_gem 'rubyzip' do
#   version '1.3.0'
#   compile_time true
# end

eporch2_meta_data 'meta_data' do
  name 'zabbix_client'
  action :nothing
end.run_action(:update)

zabbix_client_attributes 'update'
zabbix_client_install 'agent'
