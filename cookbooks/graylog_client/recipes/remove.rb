#
# Cookbook:: graylog-client
# Recipe:: remove
#
# Copyright:: 2020, All Rights Reserved.

if platform?('windows')
  include_recipe 'graylog_client::syslog-remove'
else
  include_recipe 'graylog_client::syslog-ng-remove'
end
