#
# Cookbook Name:: mongodb
# Recipe:: default
#
# Copyright:: 2020, All Rights Reserved.

eporch2_meta_data 'meta_data' do
  name 'mongodb'
  action :nothing
end.run_action(:update)

# node.override['mongodb']['authentication']['password'] = node['metadata']['mongodb']['mongodb_user_password']

# node.override['mongodb']['admin'] = {
#   'username' => 'admin',
#   'password' => node['metadata']['mongodb']['mongodb_user_password'],
#   'roles' => %w(userAdminAnyDatabase dbAdminAnyDatabase clusterAdmin),
#   'database' => 'admin',
# }


include_recipe 'sc-mongodb::default'
include_recipe 'sc-mongodb::user_management'
