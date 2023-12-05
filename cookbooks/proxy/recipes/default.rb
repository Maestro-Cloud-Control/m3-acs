#
# Cookbook:: proxy
# Recipe:: default
#
# Copyright:: 2020, All Rights Reserved.

include_recipe 'ssl_certificate::attr_apply'
include_recipe 'nginx-proxy'

service 'nginx' do
  supports status: true, restart: true, reload: true
  action :restart
end
