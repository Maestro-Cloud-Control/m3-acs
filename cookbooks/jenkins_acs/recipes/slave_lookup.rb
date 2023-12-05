#
# Cookbook Name:: jenkins_acs
# Recipe:: slave_lookup
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute

data_interface_datics 'datics' do
  service 'jenkins_slave'
  action :nothing
end.run_action(:pull)

unless node.run_state['datics']['jenkins_slave'].nil?
  node.run_state['datics']['jenkins_slave'].each do |host, data|
    jenkins_ssh_slave data['source'] do
      host host
      executors 4
      credentials 'jenkins-ssh-key'
      user 'jenkins'
      action [:create, :connect]
    end
  end
end
