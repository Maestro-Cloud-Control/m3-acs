#
# Cookbook:: sqs_acs
# Recipe:: default
#
# Copyright:: 2020, All Rights Reserved.

eporch2_meta_data 'meta_data' do
  name 'sqs'
  action :nothing
end.run_action(:update)

include_recipe 'sqs_acs::rabbitmq'
include_recipe 'sqs_acs::sqs_acs'
