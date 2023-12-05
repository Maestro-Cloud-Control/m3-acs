#
# Cookbook Name:: jenkins_acs
# Recipe:: default
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

chef_gem 'sshkey' do
  compile_time true
end

require 'sshkey'

eporch2_meta_data 'meta_data' do
  name 'jenkins'
  action :nothing
end.run_action(:update)

directory '/etc/systemd/system/jenkins.service.d' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
    recursive true
end

template '/etc/systemd/system/jenkins.service.d/override.conf' do
    source 'override.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
    notifies :restart, 'service[jenkins]'
end

include_recipe 'corretto-java'
include_recipe 'jenkins_acs::ssl'
include_recipe 'jenkins::master'

id_key_path = '/root/.ssh/id_rsa'
flags_path = "#{Chef::Config[:file_cache_path]}/jenkins_flags"

ruby_block 'use ssh for jenkins executor' do
  block do
    node.override['jenkins']['executor']['protocol'] = 'ssh'
  end
  action :run
  only_if { ::File.exist?("#{flags_path}/jenkins-installed") }
end

directory 'Service directory for some flags' do
  path    flags_path
  owner   'root'
  group   'root'
  mode    '0700'
  action  :create
end

if !File.exist?(id_key_path)
  sshkey = SSHKey.generate(
    type: 'RSA',
    bits: 4096
  )

  directory ::File.dirname(id_key_path) do
    owner   'root'
    group   'root'
    mode    '0700'
    action  :create
  end

  # Store public key on disk
  file "#{id_key_path}.pub" do
    content sshkey.ssh_public_key
    owner   'root'
    group   'root'
    mode    '0644'
    action  :create_if_missing
  end

  file 'Private key backup' do
    path    "#{flags_path}/eo-key"
    content sshkey.private_key
    owner   'root'
    group   'root'
    mode    '0600'
    action  :create_if_missing
  end

  node.run_state[:jenkins_public_key] = sshkey.ssh_public_key
  node.run_state[:jenkins_private_key] = sshkey.private_key

else
  node.run_state[:jenkins_public_key] = File.open(id_key_path + '.pub', 'r').read
  node.run_state[:jenkins_private_key] = File.open(id_key_path, 'r').read
end

file id_key_path do
  content node.run_state[:jenkins_private_key]
  owner   'root'
  group   'root'
  mode    '0600'
  sensitive true
  action  :create_if_missing
end

jenkins_users = []
jenkins_users.push('name' => 'admin', 'privileges' => 'ADMINISTER', 'password' => node['jenkins']['login_password'], 'sshkey' => '')

# install plugins
jenkins_acs_install_plugins 'Install plugins' do
  plugins node['jenkins_acs']['default_plugins']
  flags_path flags_path
  action :install
  not_if { ::File.exist?("#{Chef::Config[:file_cache_path]}/jenkins-plugins.json") }
end

template 'JenkinsLocationConfiguration' do
  owner   'jenkins'
  group   'jenkins'
  path    "#{node['jenkins']['master']['home']}/jenkins.model.JenkinsLocationConfiguration.xml"
  source  'jenkins.model.JenkinsLocationConfiguration.xml.erb'
  variables(
    jenkins_url: node['metadata']['common']['fqdn']
  )
end

# configure users
jenkins_acs_configure_users 'Configure basic users' do
  users       jenkins_users
  flags_path  flags_path
  action      :configure
  notifies    :create, 'file[Jenkins installed]', :immediately
  not_if      { ::File.exist?("#{flags_path}/jenkins-installed") }
end

file 'Jenkins installed' do
  path    "#{flags_path}/jenkins-installed"
  action  :nothing
end

# allow ssh connect in order to use jenkins cli from under admin users
template 'update_org.jenkinsci.main.modules.sshd.SSHD.xml.erb' do
  source 'org.jenkinsci.main.modules.sshd.SSHD.xml.erb'
  path   "#{node['jenkins']['master']['home']}/org.jenkinsci.main.modules.sshd.SSHD.xml"
  owner  'jenkins'
  group  'jenkins'
  mode   '0755'
  variables(
    port: node['jenkins_acs']['cli']['sshd']['port']
  )
  action :create
  notifies :restart, 'service[jenkins]', :immediately
  notifies :run, 'ruby_block[use ssh for jenkins executor]', :immediately
end

# data_interface_datics 'datics' do
#   service 'jenkins_master'
#   data 'ssh_key' => node.run_state[:jenkins_public_key].split(' ')[1]
# end

# include_recipe 'jenkins_acs::slave_lookup'
