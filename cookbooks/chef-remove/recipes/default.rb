#
# Cookbook:: chef-remove
# Recipe:: default
#
# Copyright:: 2020
#  All Rights Reserved.
# 

# callback to orch
# chefserver = URI.parse(Chef::Config.chef_server_url) 
# node.override['lastrun']['state'] = 'success'
# some_magic = JSON.parse(node['_out'].to_json)

# http_request 'Call orch' do
#   action :post
#   url node['metadata']['common']['last_run']
#   message "name=" + node['name'] + "&state=" + node['lastrun']['state']  + "&chefserver=" + chefserver.host + "&node_data={" + "\"name\":\"" + node['name'] + "\",\"state\":\"" + node['lastrun']['state'] + "\",\"chefserver\":\"" + chefserver.host + "\",\"node_roles\":" + "[\"" + "#{node['roles'].join('","')}" + "\"]" + ",\"node_status\":" + some_magic.inspect.gsub('=>',':') + "}"
# end

# execute 'remove itself from chef-server' do
#   command "yes | knife node delete #{node['name']} -c #{node['chef_client']['conf_dir']}/client.rb"
#   action :run
# end

if node['os'] == 'windows'
  execute 'remove chef-client schedule' do
    command 'schtasks /Delete /TN chef-client /F'
    action :run
    only_if 'schtasks /Query /TN chef-client'
    ignore_failure true
  end

  # === bad choice because there is version dependency === 
  
  # windows_package 'Chef Infra Client v15.11.3' do
  #   action :remove
  # end

  powershell_script 'uninstall_chef-client' do
    code <<-EOH
      (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "Chef" }).Uninstall()
    EOH
  end

  %w[
    C:\\chef
    C:\\opscode
  ].each do |path|
    directory path do
      recursive true
      action :delete
    end
  end
else
  execute 'remove chef-client cron' do
    command 'crontab -l | grep -v chef-client | crontab -'
    action :run
    only_if 'crontab -l | grep chef-client'
    ignore_failure true
  end

  service 'chef-client' do
    action [ :stop, :disable ]
  end

  # Remove the systemd service unit file
  %w[ 
    /etc/systemd/system/chef-client.service
    /lib/systemd/system/chef-client-run.service
    /lib/systemd/system/chef-client-run.timer
  ].each do |path|
    file path do
      action :delete
    end
  end

  package 'chef' do
    action  :purge
    options '--allow-change-held-packages'
  end

  %w[ 
    /usr/bin/chef-apply
    /usr/bin/chef-client
    /usr/bin/chef-shell
    /usr/bin/chef-solo
    /usr/bin/knife
    /usr/bin/ohai
  ].each do |path|
    link path do
      action :delete
      only_if "test -L #{path}"
    end
  end

  %w[ 
    /opt/chef
    /var/chef
    /var/log/chef
    /etc/chef
  ].each do |path|
    directory path do
      recursive true
      action :delete
    end
  end
end

