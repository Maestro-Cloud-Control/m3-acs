#
# Cookbook:: graylog-client
# Recipe:: default
#
# Copyright:: 2020, All Rights Reserved.

eporch2_meta_data 'meta_data' do
  name 'graylog_client'
  action :nothing
end.run_action(:update)

if node['metadata']['graylog_client']['server_fqdn'] != ''
  if platform?('windows')
    include_recipe 'graylog_client::syslog-agent'
  else
    include_recipe 'graylog_client::syslog-ng'
  end
else
  Chef::Log.info('==> No graylog server was specified. Please check if properties are correct')
end
