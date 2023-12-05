#
# Cookbook Name :: nginx_balancer
# Recipe        :: install
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

apt_repository 'nginx' do
  uri 'http://nginx.org/packages/ubuntu/'
  distribution node['lsb']['codename']
  components ['nginx']
  keyserver 'keyserver.ubuntu.com'
  key 'ABF5BD827BD9BF62'
  action :add
  cache_rebuild true
end

package 'nginx' do
  action :install
  retries 3
  retry_delay 20
end

service 'nginx' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  mode 0644
  owner 'root'
  group 'root'
end

%w( /var/cache/nginx/ram /var/cache/nginx/ram/tmp ).each do |dir|
  directory dir do
    owner 'nginx'
    group 'nginx'
    mode 00755
    action :create
  end
end

mount '/var/cache/nginx/ram' do
  pass     0
  fstype   'tmpfs'
  device   'tmpfs'
  options  'nr_inodes=999k,mode=755,size=512m'
  action   [:mount, :enable]
end
