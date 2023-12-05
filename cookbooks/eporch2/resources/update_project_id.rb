#
# Cookbook Name:: eporch2
# Resource:: update_project_id
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

unified_mode true

action :update do
  case node['os']
  when 'windows'
    Chef::Log.info('Operating system on a virtual machine is WINDOWS')
    Chef::Log.info('Provide access to this VM for a new project impossible to do by update sssd.conf')
  when 'linux'
    Chef::Log.info('Project id was updated')

    execute 'set_new_project_id_into_sudoers_file' do
      user 'root'
      command "sed -i 's/#{node['eporch']['value_of_the_project_id_since_last_chef_client_run'].downcase.strip}/#{node['metadata']['common']['project_id'].downcase}/g' /etc/sudoers.d/"
      action :run
      ignore_failure true
    end

    execute 'set_new_project_id_into_sssd_conf_file' do
      user 'root'
      command "sed -i 's/Project #{node['eporch']['value_of_the_project_id_since_last_chef_client_run'].strip}/Project #{node['metadata']['common']['project_id']}/g' /etc/sssd/sssd.conf"
      action :run
      ignore_failure true
      notifies :restart, 'service[sssd]', :immediately
    end

    service 'sssd' do
      action :nothing
    end

    node.normal['eporch']['value_of_the_project_id_since_last_chef_client_run'] = node['metadata']['common']['project_id']
    Chef::Log.info('Value of the project id since last chef client run updated')
  end
end

