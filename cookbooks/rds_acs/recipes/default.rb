#
# Cookbook Name:: rds_acs
# Recipe:: default
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

rds_acs_creds 'creds' do
  action :nothing
end.run_action(:get_attribute)

package 'ca-certificates' do
  action :install
end

include_recipe "rds_acs::#{node['rds_acs']['installation_type']}"
