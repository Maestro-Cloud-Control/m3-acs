#
# Cookbook Name:: artifactory_acs
# Recipe:: default
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

require 'digest'
require 'securerandom'

eporch2_meta_data 'meta_data' do
  name 'artifactory'
  action :nothing
end.run_action(:update)

include_recipe 'artifactory_acs::ssl'

# selinux_install '' do
#   action :install
# end

include_recipe 'selinux_policy::install'

selinux_policy_boolean 'httpd_can_network_connect' do
  value true
end

include_recipe 'corretto-java'
include_recipe 'artifactory_acs::install_artifactory'

http_request 'HEAD http://localhost:8082/' do
  url         'http://localhost:8082/'
  action      :head
  retries     20
  retry_delay 30
  # notifies    :configure, 'artifactory_acs_configure_artifactory_admin_users[configure_artifactory_admin_users]', :immediately
  # not_if      { node['artifactory']['status'] == 'installed' }
end

unless ::File.exist?("#{Chef::Config['file_cache_path']}/artifactory/artifactory.security.xml")

  admin_password = node['metadata']['artifactory']['login_password']
  admin_salt = SecureRandom.hex(8)
  admin_crypted_pass = Digest::MD5.hexdigest(admin_password + '{' + admin_salt + '}')

  artifactory_acs_configure_artifactory_admin_users 'configure_artifactory_admin_users' do
    retries             10
    retry_delay         30
    admin_crypted_pass  admin_crypted_pass
    admin_salt          admin_salt
    action              :configure
    # action            :nothing
    not_if              { node['artifactory']['status'] == 'configured' }
  end

end
