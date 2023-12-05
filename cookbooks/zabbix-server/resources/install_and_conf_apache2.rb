
# Cookbook:: zabbix-server
# Resources:: install_and_conf_apache2
#
# Copyright:: 2019, All Rights Reserved.

unified_mode true

action :install do
  service 'apache2' do
    extend       Apache2::Cookbook::Helpers
    service_name lazy { apache_platform_service_name }
    supports     restart: true, status: true, reload: true
    action       :nothing
  end

  apache2_install 'default' do
    listen node['apache']['listen_ports']
    mpm    node['zabbix-server']['apache_mpm']
  end

  apache2_module 'headers'

  apache2_default_site '' do
    action :disable
  end

  apache2_site '000-default' do
    action :disable
  end
end

action :conf do
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

  template '/etc/apache2/sites-enabled/zabbix.conf' do
    source 'zabbix_apache.conf.erb'
    notifies :run, 'execute[apachectl_graceful]'
  end
end
