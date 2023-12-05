#
# Cookbook:: eporch2
# Recipe:: default
#
# Copyright:: 2019, All Rights Reserved.

node.save

eporch2_meta_data 'meta_data' do
  name 'common'
  action :nothing
end.run_action(:update)

include_recipe 'eporch2::handler'

eporch2_chef_run_list 'chef_run_list' do
  action :nothing
  roles node['metadata']['common']['role']
end.run_action(:update)

directory node['eporch2']['config_dir']
# include_recipe 'eporch2::gpg'
include_recipe 'eporch2::cleanup'
include_recipe 'chef-client'
include_recipe 'chef-client::config'

edit_resource(:template, "#{node['chef_client']['conf_dir']}/client.rb") do
  cookbook 'eporch2'
end

case node['platform_family']
when 'debian'
  apt_update 'update' do
    action :update
  end
  include_recipe 'unattended-upgrades'

  execute 'hold chef-client' do
    command "apt-mark hold chef \
      && touch #{Chef::Config[:file_cache_path]}/chef_hold.sem"
    creates "#{Chef::Config[:file_cache_path]}/chef_hold.sem"
  end
when 'rhel'
  if node['platform_version'].to_f >= 8
    link '/bin/yum' do
      to '/bin/dnf'
    end
  end
end

# update project id into sudoers and sssd conf file if the vm was moved from project to new project 
if node['eporch']['value_of_the_project_id_since_last_chef_client_run'].empty?
  Chef::Log.info('Value of the project id since last chef client run is empty')
  node.normal['eporch']['value_of_the_project_id_since_last_chef_client_run'] = node['metadata']['common']['project_id']
else
  if node['eporch']['value_of_the_project_id_since_last_chef_client_run'] != node['metadata']['common']['project_id']
    Chef::Log.info("Value of the project id since last chef client run changed!")
  
    eporch2_update_project_id 'update_project_id' do
      action :update
    end
  else
    Chef::Log.info("Value of the project id since last chef client run did not change")
  end
end

# Fixing issues on multiple servers caused by a recently expired root certificate
# https://www.zoocha.com/news/fixing-issues-multiple-servers-caused-recently-expired-root-certificate
if node['own']['chef']['certificates_bundle'].empty?
  execute 'update Chef own set of CA certificates bundle' do
    command 'cp /etc/ssl/certs/ca-certificates.crt /opt/chef/embedded/ssl/certs/cacert.pem'
    action :run
    only_if { ::Dir.exist?('/opt/chef/embedded/ssl/certs/') }
    only_if { ::File.exist?('/etc/ssl/certs/ca-certificates.crt') }
  end

  node.normal['own']['chef']['certificates_bundle'] = 'updated'
end
