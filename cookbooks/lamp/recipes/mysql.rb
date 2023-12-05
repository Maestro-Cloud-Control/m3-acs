#
# Cookbook:: lamp
# Recipe:: mysql
#
# Copyright:: 2023, All Rights Reserved.
# Configure the MySQL client.

mysql_client 'default' do
  action :create
end

mysql_service 'default' do
  version                 '8.0'
  bind_address            '0.0.0.0'
  port                    '3306'
  data_dir                '/data'
  initial_root_password   node['metadata']['lamp']['mysql_root_password']
  action                  [:create, :start]
end

ruby_block 'wait for service start' do
  block do
    sleep(30)
  end
  action :run
end

mysql_database node['metadata']['lamp']['mysql_db_name'] do
  host     node['mysql']['host']
  user     'root'
  password node['metadata']['lamp']['mysql_root_password']
  sql      node['mysql']['script_create_table']
  action   [:create, :query]
end

mysql_user node['metadata']['lamp']['mysql_username'] do
  password      node['metadata']['lamp']['mysql_user_password']
  database_name node['metadata']['lamp']['mysql_db_name']
  host          '%'
  privileges    [:select,:update,:insert,:delete]
  action        [:create, :grant]
end
