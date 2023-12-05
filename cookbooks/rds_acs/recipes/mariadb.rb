#
# Cookbook Name:: rds_acs
# Recipe:: mariadb
#
# Copyright 2020 
#
# All rights reserved - Do Not Redistribute
#

mariadb_repository 'MariaDB Repository' do
  version node['rds_acs']['mariadb']['version']
  apt_repository_uri "http://mirror.netcologne.de/mariadb/repo"
end

mariadb_server_install 'MariaDB Server install' do
  version node['rds_acs']['mariadb']['version']
  password node.run_state['root_pass']
  setup_repo false
  action [:install, :create]
end

service 'mariadb'

mariadb_server_configuration 'MariaDB Server Configuration' do
  mysqld_bind_address node['rds_acs']['bind_address']
  version node['rds_acs']['mariadb']['version']
  client_host 'localhost'
  notifies :restart, 'service[mariadb]', :immediately
end

ruby_block 'wait for service start' do
  block do
    sleep(30)
  end
  action :run
end

if node.run_state['rds_mode'] == 'service'
  mariadb_database node.run_state['db_name'] do
    password node.run_state['root_pass']
    host '127.0.0.1'
    user 'root'
    action :create
  end

  mariadb_user node.run_state['db_user'] do
    ctrl_password node.run_state['root_pass']
    database_name node.run_state['db_name']
    password node.run_state['user_pass']
    host '%'
    action [:create, :grant]
  end
end
