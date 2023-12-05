#
# Cookbook Name:: rds_acs
# Recipe:: mysql
#
# Copyright 2023
#
# All rights reserved - Do Not Redistribute
#

unless node.run_state['user_pass'].nil?
  
  # Chef::Log.info("db name: #{node.run_state['db_name']}")
  # Chef::Log.info("db admin user password : #{node.run_state['user_pass']}")
  
  mysql_client 'default' do
    action  :create
    version '8.0'
  end

  mysql_service 'default' do
    version       '8.0'
    bind_address  node['rds_acs']['bind_address']
    port          node['rds_acs']['mysqld']['port']
    action        [:create, :start]
  end

  ruby_block 'wait for service start' do
    block do
      sleep(30)
    end
    action :run
  end

  if node.run_state['rds_mode'] == 'service'
    mysql_database node.run_state['db_name'] do
      host    'localhost'
      port    node['rds_acs']['mysqld']['port']
      user    'root'
      action  :create
      sql     node.run_state['sql_init_script']
    end

    mysql_user node.run_state['db_user'] do
      password  node.run_state['user_pass']
      host      '%'
      action    [:create, :grant]
    end
  end

  else
    Chef::Log.info("db name, user password and user name is empty")

end