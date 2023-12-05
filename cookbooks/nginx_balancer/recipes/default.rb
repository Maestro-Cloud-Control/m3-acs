#
# Cookbook Name :: nginx_balancer
# Recipe        :: default
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

eporch2_meta_data 'meta_data' do
  name 'lb'
  action :nothing
end.run_action(:update)

# install nginx
include_recipe 'nginx_balancer::install_nginx'

# configure nginx balancer
nginx_balancer_configure 'update balancer conf' do
  action  :configure
  only_if { node['nginx_balancer']['timestamp_old'] != node['metadata']['lb']['timestamp'] }
end
