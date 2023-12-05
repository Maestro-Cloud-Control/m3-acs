#
# Cookbook Name:: docker_acs
# Recipe:: get_keys
#
# Copyright:: 2020, All Rights Reserved.

directory '/etc/docker' do
  owner 'root'
  group 'root'
  mode '0600'
  action :create
end

docker_acs_keys 'get'
