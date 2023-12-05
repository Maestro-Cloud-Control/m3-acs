#
# Cookbook Name:: artifactory_acs
# Recipe:: install artifactory
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

# preconfiguration
user node['artifactory']['user'] do
  comment 'artifactory system user'
  system  true
  shell   '/bin/false'
  action  :create
end

group node['artifactory']['group'] do
  comment 'artifactory system group'
  system  true
  action  :create 
  members node['artifactory']['user']
end

directory "#{Chef::Config['file_cache_path']}/artifactory" do
  owner     node['artifactory']['user']
  group     node['artifactory']['group']
  recursive true
  action    :create
end

# install artifactory
yum_repository 'bintray--jfrog-artifactory-rpms' do
  baseurl 'https://jfrog.bintray.com/artifactory-rpms'
  repo_gpgcheck false
  gpgcheck      false
  enabled       true
end

%w(
  deltarpm
  jfrog-artifactory-cpp-ce
).each do |pkg|
  package pkg do
    action   :install
    timeout  2000
  end
end

service 'artifactory' do
  supports restart: true, reload: true, status: true
  action [:enable, :start]
end

service 'firewalld' do
  action [:disable, :stop]
  only_if { ::File.exist?('/etc/sysconfig/firewalld') }
end
