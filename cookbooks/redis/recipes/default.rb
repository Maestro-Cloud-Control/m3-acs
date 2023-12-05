#
# Cookbook:: redis
# Recipe:: default
#
# Copyright:: 2023, All Rights Reserved.

eporch2_meta_data 'meta_data' do
  name 'redis'
  action :nothing
end.run_action(:update)

include_recipe "redisio::default"
include_recipe "redisio::enable"

