# frozen_string_literal: true

#
# Cookbook Name:: docker_wrapper
# Recipe:: registry_search
#
# Copyright:: 2020, All Rights Reserved.

data_interface_datics 'datics' do
  service 'docker_registry'
  action :nothing
end.run_action(:pull)

docker_acs_registry_search 'update'
