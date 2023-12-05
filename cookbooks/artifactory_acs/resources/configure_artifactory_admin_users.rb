#
# Cookbook Name:: artifactory_acs
# Resources:: configure_artifactory_admin_users
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

property :retries, Integer
property :retry_delay, Integer

property :admin_crypted_pass, String
property :admin_salt, String

action :configure do

  template "#{Chef::Config['file_cache_path']}/artifactory/artifactory.security.xml" do
    source 'artifactory.security.xml.erb'
    variables(
      admin_crypted_pass: new_resource.admin_crypted_pass,
      admin_salt:         new_resource.admin_salt
    )
    action :create_if_missing
    sensitive true
    notifies :post, 'http_request[reload_security]', :immediately
  end

  http_request 'reload_security' do
    url 'http://localhost:8082/artifactory/api/system/security'
    action :nothing
    headers(
      'AUTHORIZATION' => "Basic #{Base64.encode64('admin:password')}",
      'Content-Type' => 'application/xml'
    )
    message lazy { IO.read("#{Chef::Config['file_cache_path']}/artifactory/artifactory.security.xml") }
    sensitive true
    retries new_resource.retries
    retry_delay new_resource.retry_delay
  end

  node.normal['artifactory']['status'] = 'configured'

end
