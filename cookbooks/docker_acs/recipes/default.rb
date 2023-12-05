#
# Cookbook Name:: docker_acs
# Recipe:: default
#
# Copyright:: 2020, All Rights Reserved.

include_recipe 'docker_acs::ssl'

eporch2_meta_data 'meta_data' do
  name 'docker'
  action :nothing
end.run_action(:update)

package 'ca-certificates' do
  action :upgrade
end

cluster_id = node['metadata']['docker']['cluster_id']

data_interface_datics 'datics' do
  service "docker_master_#{cluster_id}"
  action :nothing
end.run_action(:pull)

if node.run_state['datics']["docker_master_#{cluster_id}"].nil?
  include_recipe 'docker_acs::master'
else
  node.run_state['datics']["docker_master_#{cluster_id}"].each do |host, _data|
    node.run_state['docker_master'] = host
    include_recipe 'docker_acs::worker'
  end
end

include_recipe 'docker_acs::registry_search'
