#
# Cookbook Name:: docker_acs
# Recipe:: master
#
# Copyright:: 2020, All Rights Reserved.

include_recipe 'docker_acs::install_docker'
include_recipe 'docker_acs::ssl_config'
include_recipe 'docker_acs::get_keys'

data_interface_datics 'datics' do
  service "docker_master_#{node['metadata']['docker']['cluster_id']}"
  action :push
end

service 'docker' do
  provider Chef::Provider::Service::Systemd
  supports status: true, stop: true, restart: true, start: true
  action :nothing
end

execute 'systemctl daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

template '/etc/systemd/system/multi-user.target.wants/docker.service' do
  source 'docker_opts.erb'
  manage_symlink_source true
  variables(
    cert_path: node['docker_acs']['cert_path'],
    key_path: node['docker_acs']['key_path']
  )
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

execute 'init_swarm' do
  command "docker swarm init --advertise-addr #{node['ipaddress']} && touch #{Chef::Config[:file_cache_path]}/swarm_init.sem"
  notifies :restart, 'service[docker]', :delayed
  creates "#{Chef::Config[:file_cache_path]}/swarm_init.sem"
end

# =========== #
# swarmpit UI #
# =========== #

# Parameters
# INTERACTIVE - must be set to 0 (disabled)
# ADMIN_PASSWORD - must be at least 8 characters long

# STACK_NAME - default to swarmpit
# ADMIN_USERNAME - default to admin
# APP_PORT - default to 888
# DB_VOLUME_DRIVER - default to local

Chef::Resource::Execute.send(:include, Eporch2::Helpers)

execute 'init_swarm_ui' do
  command lazy {
    <<-EOS
    docker run --tty --rm \
      --name swarmpit-installer \
      --volume /var/run/docker.sock:/var/run/docker.sock \
      -e INTERACTIVE=0 \
      -e ADMIN_USERNAME='admin' \
      -e ADMIN_PASSWORD=#{node['metadata']['docker']['swarmpit_login_password']} \
      swarmpit/install:1.8
  EOS
  }
  user 'root'
  group 'root'
  notifies :create, 'file[Swarmpit installed]', :immediately
  not_if   { ::File.exist?("#{Chef::Config[:file_cache_path]}/swarmpit-installed") }
end

file 'Swarmpit installed' do
  path    "#{Chef::Config[:file_cache_path]}/swarmpit-installed"
  action  :nothing
end
