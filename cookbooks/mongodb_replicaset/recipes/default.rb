#
# Cookbook Name:: mongodb_replicaset
# Recipe:: default
#
# Copyright:: 2023, All Rights Reserved.

eporch2_meta_data 'meta_data' do
  name 'mongodb'
  action :nothing
end.run_action(:update)

include_recipe 'sc-mongodb::default'
include_recipe 'sc-mongodb::user_management'
include_recipe 'sc-mongodb::replicaset'




