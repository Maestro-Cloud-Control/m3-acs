#
# Cookbook Name:: graylog_acs
# Recipe:: install_elasticsearch
#
# Copyright:: 2023, All Rights Reserved.

apt_repository 'elastic-7.x' do
  uri node['graylog_acs']['elasticsearch']['download_url']
  key node['graylog_acs']['elasticsearch']['download_url_key']
  components   ['stable','main']
  distribution ''
  cache_rebuild true
end

apt_package 'elasticsearch' do
  # version node['graylog_acs']['elasticsearch']['version']
  action  :install
end
  
template 'update_elasticsearch_conf' do
  path '/etc/elasticsearch/elasticsearch.yml'
  source 'elasticsearch_conf.yml.erb'
  owner 'root'
  group 'elasticsearch'
  mode '660'
  variables(
    claster_name: node['graylog_acs']['elasticsearch']['cluster_name'] 
  )
  action :create
  notifies :reload, 'service[elasticsearch]', :immediately
  notifies :restart, 'service[elasticsearch]', :immediately
end

service 'elasticsearch' do
  supports       restart: true, reload: true, status: true
  action         :enable
  reload_command 'systemctl daemon-reload'
end



