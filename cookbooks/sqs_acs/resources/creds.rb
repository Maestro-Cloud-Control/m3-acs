#
# Cookbook:: sqs_acs
# Resource:: creds.rb
#
# Copyright:: 2020, All Rights Reserved.

action :create do
  o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
  random_pass = (0...12).map { o[rand(o.length)] }.join

  sqs_acs_user 'acs_user' do
    password random_pass
    action :add
  end

  sqs_acs_user 'acs_user' do
    vhost '/'
    permissions '.* .* .*'
    action :set_permissions
  end

  sqs_acs_user 'acs_user' do
    tag 'administrator'
    action :set_tags
  end

  file 'sqs_user.sem' do
    path "#{Chef::Config[:file_cache_path]}/sqs_user.sem"
    action :touch
  end

  node.run_state['rabbit_password'] = random_pass
end
