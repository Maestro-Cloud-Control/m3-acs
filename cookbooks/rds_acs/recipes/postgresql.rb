#
# Cookbook Name:: rds_acs
# Recipe:: postgresql
#
# Copyright 2023
#
# All rights reserved - Do Not Redistribute
#

unless node.run_state['user_pass'].nil?

  postgresql_install 'postgresql' do
    version node['rds_acs']['postgresql']['version']
    action :install
  end

  postgresql_service 'postgresql' do
    service_name 'postgresql'
    action [:enable, :start]
  end

  template "/etc/postgresql/#{node['rds_acs']['postgresql']['version']}/main/postgresql.conf" do
    source 'postgresql/postgresql.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0644'
    action :create
    notifies :restart, 'service[postgresql]'
    variables(
        :port => node['rds_acs']['postgresql']['port'],
        :version => node['rds_acs']['postgresql']['version']
    )
  end

  postgresql_role node.run_state['db_user'] do
    sensitive             true
    superuser             true
    createdb              true
    createrole            true
    login                 true
    unencrypted_password  node.run_state['user_pass']
    action                [:create, :update, :set_password]
  end

  postgresql_access node.run_state['db_user'] do
    comment 'User access'
    type 'host'
    database 'all'
    user node.run_state['db_user']
    address '0.0.0.0/0'
    auth_method 'md5'
    action [:create, :update]
  end

  postgresql_database node.run_state['db_name'] do
    owner node.run_state['db_user']
  end

  else
    Chef::Log.info("db name, user password and user name is empty")

end

service 'postgresql' do
  action :nothing
end