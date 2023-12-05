#
# Cookbook:: gerrit_acs
# Recipe:: install_and_conf_gerrit
#
# Copyright:: 2023, All Rights Reserved.

user node['gerrit']['user'] do
  action :create
end

group node['gerrit']['user'] do
  members node['gerrit']['user']
  action  :create
end

directory node['gerrit']['dir'] do
  owner     node['gerrit']['user']
  group     node['gerrit']['group']
  mode      '0755'
  action    :create
  recursive true
end

remote_file '/tmp/gerrit.war' do
  source node['gerrit']['release_package']
  mode   '0644'
  action :create
end

execute 'java gerrit init' do
  command "java -jar /tmp/gerrit.war init -b --no-auto-start --install-all-plugins -d #{node['gerrit']['dir']}"
  user    node['gerrit']['user']
  action  :run
  not_if  { ::File.exist?("#{node['gerrit']['dir']}/bin/gerrit.sh") }
end

systemd_unit 'gerrit.service' do
  content({ Unit: {
              Description: 'Web based code review and project management for Git based projects',
              After: 'network.target',
            },
            Service: {
              Type: 'forking',
              User: node['gerrit']['user'],
              WorkingDirectory: node['gerrit']['dir'],
              ExecStart: "#{node['gerrit']['dir']}/bin/gerrit.sh start",
              ExecStop: "#{node['gerrit']['dir']}/bin/gerrit.sh stop",
              RestartSec: '10',
              Restart: 'always',
              OOMScoreAdjust: "-1000",
            },
            Install: {
              WantedBy: 'multi-user.target',
            } })
  action [:create, :enable, :start]
end

template "#{node['gerrit']['dir']}/etc/gerrit.config" do
  source   'gerrit.config.erb'
  owner    node['gerrit']['user']
  group    node['gerrit']['group']
  mode     '0644'
  action   :create
  notifies :restart, 'service[gerrit]'
  variables(
    :url => "#{node['metadata']['common']['fqdn']}:#{node['gerrit']['port']}",
    :ssh_port => node['gerrit']['ssh_port']
  )
end

service 'gerrit' do
  action [:nothing]
end
