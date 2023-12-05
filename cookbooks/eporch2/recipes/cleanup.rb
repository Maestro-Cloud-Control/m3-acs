#
# Cookbook:: eporch2
# Recipe:: cleanup
#
# Copyright:: 2019, All Rights Reserved.

file Chef::Config.validation_key do
  action :delete
  backup false
  only_if { ::File.exist?(Chef::Config.validation_key) }
end

if node['os'] == 'windows'
  node.rm('kernel', 'cs_info', 'oem_logo_bitmap')
  node.rm('kernel', 'pnp_drivers')
  node.rm('kernel', 'modules')
else
  execute 'remove chef-client cron' do 
    command 'crontab -l | grep -v chef-client | crontab -' 
    action :run 
    only_if 'crontab -l | grep chef-client' 
    ignore_failure true 
  end 
end
