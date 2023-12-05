#
# Cookbook:: lamp
# Recipe:: application
#
# Copyright:: 2023, All Rights Reserved.

directory node['apache2']['dir'] do
  owner     'root'
  group     'root'
  mode      '0755'
  action    :delete
  recursive true
  not_if    { File.exist? "#{node['apache2']['dir']}/db.php" }
end

git "#{node['apache2']['dir']}" do
  repository node['metadata']['lamp']['app_gitrepo']
  revision   node['metadata']['lamp']['app_gitbranch']
  action     :sync
end

template "#{node['apache2']['dir']}/db.php" do
  source 'db/db.php.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  action :create
  variables(
    :user =>     node['metadata']['lamp']['mysql_username'],
    :host =>     node['mysql']['host'],
    :password => node['metadata']['lamp']['mysql_user_password'],
    :db_name =>  node['metadata']['lamp']['mysql_db_name']
  )
end
