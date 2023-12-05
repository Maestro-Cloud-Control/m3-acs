#
# Cookbook Name:: elasticsearch
# Recipe:: default
#
# Copyright:: 2023, All Rights Reserved.

elasticsearch_user 'elasticsearch' do
  username 'elasticsearch'
  groupname 'elasticsearch'
  shell '/bin/bash'
  comment 'Elasticsearch User'
  
  action :create
end

elasticsearch_install 'elasticsearch' do
  type 'package'
  # version "1.7.2"
  action :install
end

elasticsearch_configure 'elasticsearch'

# elasticsearch_configure 'elasticsearch' do
#   configuration ({
#     'cluster.name' => 'escluster',
#     'discovery.type' => 'single-node',
#     'http.host' => '0.0.0.0',
#     'cluster.initial_master_nodes' => Chef::Config[:node_name],
#     'network.host' => '0.0.0.0',
#   })
#   action :manage
# end

elasticsearch_service 'elasticsearch' do
  service_actions [:enable, :start]
end



