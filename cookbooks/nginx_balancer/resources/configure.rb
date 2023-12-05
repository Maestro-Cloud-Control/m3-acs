#
# Cookbook Name :: nginx_balancer
# Resources     :: configure
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

unified_mode true

action :configure do

  Chef::Log.info('>> Changing balancer.conf file: ' + node['metadata']['lb']['timestamp'])

  file '/etc/nginx/conf.d/default.conf' do
    action  :delete
    only_if { ::File.exist?('/etc/nginx/conf.d/default.conf') }
  end
    
  file '/etc/nginx/conf.d/example_ssl.conf' do
    action  :delete
    only_if { ::File.exist?('/etc/nginx/conf.d/example_ssl.conf') }
  end

  %w( /etc/nginx/sites-available /etc/nginx/sites-enabled ).each do |dir|
    directory dir do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end
  end

  directory '/etc/nginx_new' do
    recursive true
    action    :delete
  end
  
  execute 'copy current nginx config' do
    command 'cp -pr /etc/nginx /etc/nginx_new'
    action  :run
  end

  remote_file '/etc/nginx_new/sites-available/balancer.conf' do
    source "#{node['metadata']['common']['orch_api']}/api/#{node['metadata']['lb']['configuration']}"
    action :create
  end

  directory '/etc/nginx_old' do
    recursive true
    action    :delete
  end

  bash 'Move Nginx new config' do
    code <<-EOH
      mv /etc/nginx /etc/nginx_old
      mv /etc/nginx_new /etc/nginx
    EOH
  end

  link '/etc/nginx/sites-enabled/balancer.conf' do
    owner     'root'
    group     'root'
    mode      '0755'
    to        '/etc/nginx/sites-available/balancer.conf'
    link_type :symbolic
  end

  execute 'check new nginx config' do
    command 'nginx -t -c /etc/nginx/nginx.conf'
    action :run
    notifies :restart, 'service[nginx]', :immediately
  end

  node.default['nginx_balancer']['timestamp_old'] = node['metadata']['lb']['timestamp']

  service 'nginx' do
    supports status: true, restart: true, reload: true
    action :nothing
  end

end
