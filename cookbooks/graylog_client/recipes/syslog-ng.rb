#
# Cookbook:: graylog-client
# Recipe:: syslog-ng
#
# Copyright:: 2020, All Rights Reserved.

case node['platform_family']
when 'rhel', 'amazon'
  include_recipe 'yum-epel'

  execute 'SELinux change to permissive' do
    command "/usr/sbin/setenforce 0 && \
    sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config"
    only_if '/sbin/selinuxenabled'
  end

  if node['platform_version'].to_i == 7 || platform_family?('amazon')
    yum_package 'syslog-ng' do
      action :install
    end
  else
    dnf_package 'syslog-ng' do
      action :install
    end
  end
when 'debian'
  package 'syslog-ng' do
    action :install
  end
end

template '/etc/syslog-ng/syslog-ng.conf' do
  source 'syslog-ng.conf.erb'
  mode '644'
  variables(
    lazy do
      {
        graylog_server_name: node['metadata']['graylog_client']['server_fqdn'],
        version_string: '@version:3.5',
        logs: node['log_files']
      }
    end
  )
  notifies :restart, 'service[syslog-ng]', :delayed
end

service 'syslog-ng' do
  supports 'status' => true, 'restart' => true, 'reload' => true
  action [:enable, :start]
end
