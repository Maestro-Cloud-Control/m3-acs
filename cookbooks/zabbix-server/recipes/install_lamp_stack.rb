#
# Cookbook:: zabbix-server
# Recipe:: install_lamp_stack
#
# Copyright:: 2019, All Rights Reserved.

zabbix_server_install_and_conf_apache2 'install_and_conf_apache2' do
  action               :install
end

include_recipe 'php'
