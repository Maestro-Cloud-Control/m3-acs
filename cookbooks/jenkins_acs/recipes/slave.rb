#
# Cookbook Name:: jenkins_acs
# Recipe:: slave
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

data_interface_datics 'datics' do
  service 'jenkins_master'
  action :nothing
end.run_action(:pull)

user 'jenkins' do
  home '/home/jenkins'
  shell '/bin/bash'
  action :create
end

directory '/home/jenkins' do
  owner 'jenkins'
  group 'jenkins'
  mode '0755'
  recursive true
  action :create
end

unless node.run_state['datics']['jenkins_master'].nil?
  node.run_state['datics']['jenkins_master'].each do |host, data|
    ssh_authorize_key host do
      key data['ssh_key']
      user 'jenkins'
      home '/home/jenkins'
    end
  end
end

include_recipe 'corretto-java'

data_interface_datics 'datics' do
  service 'jenkins_slave'
  action :push
end
