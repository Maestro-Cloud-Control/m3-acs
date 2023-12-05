#
# Cookbook Name:: sonar_acs
# Recipe:: default
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

property :retries, Integer
property :retry_delay, Integer

property :admin_password, String
# property :eo_username, String
# property :eo_password, String

unified_mode true

action :configure do

  # require 'cgi'
  # escaped_password = CGI.escape()
  # Chef::Log.info("password: #{new_resource.admin_password}")

  http_request 'change_sonar_admin_user_password' do
    url "http://localhost:9000/api/users/change_password?login=admin&previousPassword=admin&password=#{new_resource.admin_password}"
    action :post
    headers(
      'AUTHORIZATION' => "Basic #{Base64.encode64('admin:admin')}"
    )
    message ''
    retries     new_resource.retries
    retry_delay new_resource.retry_delay
    sensitive   true
  end

  # http_request 'configure_sonar_orchestrator_user' do
  #   url "http://localhost:9000/api/users/create?login=#{new_resource.eo_username}&name=Orchestrator&password=#{new_resource.eo_password}"
  #   action :post
  #   headers(
  #     'AUTHORIZATION' => "Basic #{Base64.encode64("admin:#{new_resource.admin_password}")}"
  #   )
  #   message ''
  #   retries     new_resource.retries
  #   retry_delay new_resource.retry_delay
  #   sensitive   true
  # end

  # http_request 'configure_sonar-administrator_user' do
  #   url "http://localhost:9000/api/user_groups/add_user?login=#{new_resource.eo_username}&name=sonar-administrators"
  #   action :post
  #   headers(
  #     'AUTHORIZATION' => "Basic #{Base64.encode64("admin:#{new_resource.admin_password}")}"
  #   )
  #   message ''
  #   retries     new_resource.retries
  #   retry_delay new_resource.retry_delay
  #   sensitive   true
  # end

end
