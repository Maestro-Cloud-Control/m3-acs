#
# Cookbook Name:: docker_acs
# Recipe:: worker
#
# Copyright:: 2020, All Rights Reserved.

include_recipe 'docker_acs::install_docker'
Chef::Resource::Execute.send(:include, Eporch2::Helpers)

execute 'join_swarm' do
  command "docker swarm join \
        --advertise-addr #{node['ipaddress']} \
        --token #{node['metadata']['docker']['cluster_token']} \
        #{node.run_state['docker_master']}:2377 \
    && touch #{Chef::Config[:file_cache_path]}/swarm_join.sem"
  creates "#{Chef::Config[:file_cache_path]}/swarm_join.sem"
end
