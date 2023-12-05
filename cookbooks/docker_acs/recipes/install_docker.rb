#
# Cookbook Name:: docker_acs
# Recipe:: install_docker
#
# Copyright:: 2020, All Rights Reserved.

apt_repository 'docker' do
  uri node['docker_acs']['download_url']
  key node['docker_acs']['download_url_key']
  components ['stable']
  arch 'amd64'
end

%w(
  apt-transport-https
  ca-certificates
  curl
  software-properties-common
  docker-ce
  docker-ce-cli
  containerd.io
).each do |pkg|
  package pkg do
    action :install
    timeout 1500
  end
end
