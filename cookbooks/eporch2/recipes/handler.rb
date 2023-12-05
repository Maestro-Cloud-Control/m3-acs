#
# Cookbook:: eporch2
# Recipe:: handler
#
# Copyright:: 2019, All Rights Reserved.


template Chef::Config[:file_cache_path] + '/report_handler.rb' do
  source 'handlers/report_handler.rb.erb'
  variables(
    :lastrun_url => node['metadata']['common']['last_run']
  )
  action :create
end

template File.dirname(Chef::Config[:config_file]) + '/start_handler.rb' do
  source 'handlers/start_handler.rb.erb'
  variables(
    :startrun_url => node['metadata']['common']['last_run']
  )
  action :create
end

chef_handler 'EpHandler::LastRun' do
  source Chef::Config[:file_cache_path] + '/report_handler.rb'
  action :enable
end

