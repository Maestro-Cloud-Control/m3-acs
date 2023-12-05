#
# Cookbook Name:: graylog_acs
# Recipe:: default
#
# Copyright:: 2020, All Rights Reserved.

eporch2_meta_data 'meta_data' do
  name 'graylog_server'
  action :nothing
end.run_action(:update)

include_recipe 'graylog_acs::ssl'

sha256 = Digest::SHA256.new
sha256.update node['metadata']['graylog_server']['login_password']

node.default['graylog_acs']['http']['publish_uri'] = 'http://' + node['fqdn']
node.default['graylog2']['http']['external_uri'] = "https://#{node['metadata']['common']['ep_fqdn']}/"
node.default['graylog2']['password_secret'] = node['metadata']['graylog_server']['login_password']
node.default['graylog2']['root_password_sha2'] = sha256

include_recipe 'corretto-java'
include_recipe 'graylog_acs::install_elasticsearch'
include_recipe 'sc-mongodb'
include_recipe 'graylog2::authbind'
include_recipe 'graylog2'
include_recipe 'graylog2::server'

locale 'set en_US.UTF-8 system locale' do
  lang 'en_US.UTF-8'
end

# Create swap file
swap_file 'swap' do
  path '/root/swapfile'
  size 2048
  action :create
end

# Allow graylog bind 514 port
file '/etc/authbind/byport/!514' do
  owner 'graylog'
  group 'graylog'
  mode '755'
  action :create
end

service 'graylog-server' do
  start_command 'service graylog-server start'
  action [ :start ]
end

[
  { 'name' => 'syslog_tcp_conf', 'path' => 'syslog_tcp.json', 'source' => 'syslog_tcp.json.erb' },
  { 'name' => 'syslog_udp_conf', 'path' => 'syslog_udp.json', 'source' => 'syslog_udp.json.erb' },
  { 'name' => 'syslog_user_conf', 'path' => 'syslog_user.json', 'source' => 'syslog_user.json.erb' }
].each do |template|
  template template['name'] do
    path    "/tmp/#{template['path']}"
    source  "http_request_data/#{template['source']}"
    owner   'root'
    group   'root'
    mode    '400'
    action  :create
    variables(
      :passwd => node['metadata']['graylog_server']['eo_password']
    )
  end
end

graylog_acs_configure_graylog 'configure_graylog' do
  retries         10
  retry_delay     30
  admin_password  node['metadata']['graylog_server']['login_password']
  action          :configure
  notifies        :restart, 'service[graylog-server]', :immediately
  # notifies        :create, 'file[graylog-configured]', :immediately
  # not_if          { ::File.exist?("#{Chef::Config['file_cache_path']}/graylog-configured") }
  not_if          { node['graylod_acs']['conf_status'] == 'configured' }
end
