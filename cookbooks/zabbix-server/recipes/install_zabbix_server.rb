#
# Cookbook:: zabbix-server
# Recipe:: server-install
#
# Copyright:: 2019, All Rights Reserved.

zabbix_server_install_and_conf_zabbix_server 'install_and_conf_zabbix_server' do
  action :setup
end

zabbix_server_install_and_conf_mysql 'install_and_conf_mysql' do
  action :conf
end

zabbix_server_install_and_conf_apache2 'install_and_conf_apache2' do
  action :conf
end

zabbix_server_install_and_conf_zabbix_server 'install_and_conf_zabbix_server' do
  action :setup
end
