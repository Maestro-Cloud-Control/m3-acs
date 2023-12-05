# 
# Cookbook:: zabbix-server
# Resources:: install_and_conf_zabbix_server
#
# Copyright:: 2019, All Rights Reserved.

unified_mode true

action :setup do
  apt_update 'apt' do
    action :nothing
  end

  file_name = node['zabbix']['debian']['release_package'].split('/').last

  remote_file 'zabbix-release-debian' do
    source node['zabbix']['debian']['release_package']
    path "#{Chef::Config[:file_cache_path]}/#{file_name}"
  end

  dpkg_package 'zabbix-release-debian' do
    source "#{Chef::Config[:file_cache_path]}/#{file_name}"
    notifies :update, 'apt_update[apt]', :immediately
    not_if 'dpkg -l | grep zabbix-release'
    action :install
  end

  %w(
    zabbix-server-mysql
    zabbix-frontend-php
    zabbix-agent
    zabbix-sql-scripts
  ).each do |pkg|
    package pkg do
      action :install
      timeout 1500
    end
  end

  swap_file '/swapfile' do
    size 2048
  end

  systemd_unit 'zabbix-server.service' do
    content <<-EOU.gsub(/^\s+/, '')
    [Unit]
    Description=Zabbix Server
    After=syslog.target
    After=network.target
    After=mysql-zabbix.service
  
    [Service]
    Environment="CONFFILE=/etc/zabbix/zabbix_server.conf"
    EnvironmentFile=-/etc/default/zabbix-server
    Type=forking
    Restart=on-failure
    PIDFile=/run/zabbix/zabbix_server.pid
    KillMode=control-group
    ExecStart=/usr/sbin/zabbix_server -c $CONFFILE
    ExecStop=/bin/kill -SIGTERM $MAINPID
    RestartSec=10s
    TimeoutSec=infinity
  
    [Install]
    WantedBy=multi-user.target
    EOU
    action [:create, :enable]
  end
  
  %W(
    #{node['zabbix-server']['include_dir']}
    #{node['zabbix-server']['alert_dir']}
    #{node['zabbix-server']['phpconf_dir']}
    #{node['zabbix-server']['log_dir']}
  ).each do |path|
    directory path do
      owner 'zabbix'
      group 'zabbix'
      action :create
      only_if { ::File.exist?('/etc/zabbix/zabbix_server.conf') }
    end
  end

  # service 'zabbix-server' do
  #   supports status: true, restart: true, reload: true
  #   action [ :start, :enable ]
  # end
  
  template '/etc/zabbix/zabbix_server.conf' do
    source 'zabbix_server.conf.erb'
    # notifies :restart, 'service[zabbix-server]'
  end
  
  template "#{node['zabbix-server']['phpconf_dir']}/zabbix.conf.php" do
    source 'zabbix_webui.conf.erb'
    owner 'zabbix'
    group 'zabbix'
    mode 0644
  end
end


