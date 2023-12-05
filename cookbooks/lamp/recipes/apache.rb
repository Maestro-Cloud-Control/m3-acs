#
# Cookbook:: lamp
# Recipe:: apache
#
# Copyright:: 2023, All Rights Reserved.

apache2_module 'mpm_prefork' do
  action :disable
end

service 'apache2' do
  extend       Apache2::Cookbook::Helpers
  service_name lazy { apache_platform_service_name }
  supports     restart: true, status: true, reload: true
  action       :nothing
end

apache2_install 'default' do
  listen node['apache']['listen_ports']
end

apache2_module 'headers'

%w(
  php7.4
  mpm_prefork
).each do |mod|
  apache2_module mod do
    action :disable
  end
end

apache2_default_site '' do
  action :disable
end

apache2_site '000-default' do
  action :disable
end

package 'libapache2-mod-php' do
  action   :install
  notifies :run, 'execute[enable php mode]', :immediately
end

execute 'enable php mode' do
  command 'a2enmod php*'
  action  :nothing
end

execute 'apachectl_graceful' do
  command '/usr/sbin/apachectl graceful'
  action :nothing
end

template node['apache2']['conf_file'] do   
  source   'apache/apache_app.conf.erb'
  owner    'root'
  group    'root'
  mode     '0644'
  action   :create
  notifies :run,    'execute[apachectl_graceful]'
  notifies :reload, 'service[apache2]'
  variables(
    :apache2_dir  => node['apache2']['dir'],
    :apache2_port => node['apache']['listen_ports']
  )
end


