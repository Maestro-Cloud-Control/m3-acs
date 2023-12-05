#
# Cookbook Name:: docker_acs
# Recipe:: ssl_config
#
# Copyright:: 2020, All Rights Reserved.

directory '/usr/share/ca-certificates/docker'

template '/usr/share/ca-certificates/docker/docker_acs_ca.crt' do
  source 'docker_acs_ca.crt.erb'
end

if ::File.readlines('/etc/ca-certificates.conf').grep(/docker_acs_ca.crt/).empty?
  ruby_block 'append_docker_ca_cert' do
    block do
      open('/etc/ca-certificates.conf', 'a') do |f|
        f.puts 'docker/docker_acs_ca.crt'
      end
    end
    action :run
    notifies :run, 'execute[update-ca-certificates]', :immediately
  end
else
  Chef::Log.info('==> ca-certificates.conf already updated')
end

execute 'update-ca-certificates' do
  command '/usr/sbin/update-ca-certificates'
  action :nothing
end
