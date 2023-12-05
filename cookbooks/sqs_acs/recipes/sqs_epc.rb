#
# Cookbook:: sqs_acs
# Recipe:: sqs_acs
#
# Copyright:: 2020, All Rights Reserved.

include_recipe 'corretto-java'

user 'sqs_acs' do
  comment 'sqs_acs service user'
  system true
  shell '/bin/true'
  home '/opt/sqs_acs'
  manage_home true
  action :create
end

%w( /etc/sqs_acs /var/log/sqs_acs /opt/sqs_acs ).each do |path|
  directory path
end

remote_file '/opt/sqs_acs/sqs_acs.jar' do
  source node['metadata']['common']['storage_url'] + node['sqs_acs']['jar_download_url'] + node['name']
end

systemd_unit 'sqs-acs.service' do
  verify true
  enabled true
  active true
  content(Unit: {
            Description: 'sqs-acs',
            After: ['network.target', 'syslog.target', 'rabbitmq-server.service'],
            Requires: 'rabbitmq-server.service',
          },
          Service: {
            Type: 'simple',
            ExecStart: '/usr/bin/java -jar -Dconfig.log.file=/var/log/sqs_acs/sqs-acs.log -Dconfig.location=/etc/sqs_acs -Ddefault.port=5673 /opt/sqs_acs/sqs_acs.jar',
            Restart: 'on-failure',
            TimeoutStartSec: 'infinity',
            TimeoutStopSec: 'infinity',
          },
          Install: {
            WantedBy: 'multi-user.target',
          })
  action :create
end

service 'sqs-acs' do
  supports restart: true, start: true, stop: true
  action :enable
end

template '/etc/sqs_acs/users.properties' do
  source 'users.properties'
  sensitive true
  mode '00644'
  notifies :restart, 'service[sqs-acs]', :delayed
end

template '/etc/sqs_acs/config.properties' do
  source 'config.properties'
  sensitive true
  mode '00644'
  variables(
    lazy do
      {
      region: node['metadata']['common']['region'].downcase,
      project_id: node['metadata']['common']['project_id'].downcase,
      ep_password: node.run_state['rabbit_password'],
      }
    end
  )
  only_if { node.run_state['rabbit_password'] }
  notifies :restart, 'service[sqs-acs]', :delayed
end
