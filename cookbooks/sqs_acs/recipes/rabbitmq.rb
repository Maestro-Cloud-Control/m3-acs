#
# Cookbook:: sqs_acs
# Recipe:: rabbitmq
#
# Copyright:: 2020, All Rights Reserved.

include_recipe 'rabbitmq::erlang_package'
include_recipe 'rabbitmq::management_ui'

sqs_acs_creds 'rabbit' do
  not_if { ::File.exist?("#{Chef::Config[:file_cache_path]}/sqs_user.sem") }
end
