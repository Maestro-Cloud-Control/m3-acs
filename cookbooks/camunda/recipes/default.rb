#
# Cookbook:: camunda
# Recipe:: camunda
#
# Copyright:: 2023, The Authors, All Rights Reserved.

eporch2_meta_data 'meta_data' do
  name 'camunda'
  action :nothing
end.run_action(:update)

include_recipe 'camunda::ssl'

%w(
  openjdk-11-jdk
  git
  curl
).each do |pkg|
  package pkg do
    action :install
    timeout 1500
  end
end

user node['tomcat']['user'] do
  shell '/bin/false'
end

group node['tomcat']['group'] do
  action :create
  members node['tomcat']['user']
  append true
end

directory node['tomcat']['dir'] do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0755'
  action :create
  recursive true
end

remote_file '/tmp/camunda.tar.gz' do
  source node['camunda']['source']
  mode '644'
  action :create
end

bash 'unpack_camunda' do
  user node['tomcat']['user']
  group node['tomcat']['group']
  cwd '/tmp'
  code <<-EOH
  tar -xvzf camunda.tar.gz -C #{node['tomcat']['dir']} #{node['tomcat']['archdir']} --strip-components=2
  EOH
end

template "#{node['tomcat']['dir']}/conf/tomcat-users.xml" do
  source 'tomcat-users.xml.erb'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0644'
  action :create
  variables(
    :admin_password => node['metadata']['camunda']['admin_password'],
    :manager_password => node['metadata']['camunda']['manager_password']
  )
end

[
  "#{node['tomcat']['dir']}/webapps/manager/META-INF/context.xml",
  "#{node['tomcat']['dir']}/webapps/host-manager/META-INF/context.xml"
].each do |path|
  template path do
    source 'context.xml.erb'
    owner node['tomcat']['user']
    group node['tomcat']['group']
    mode '0644'
    action :create
  end
end

systemd_unit 'tomcat.service' do
  content({ Unit: {
            Description: 'Tomcat',
            After: 'network.target',
          },
          Service: {
            Type: 'forking',
            User: node['tomcat']['user'],
            WorkingDirectory: "#{node['tomcat']['dir']}",
            Environment: [
              "JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64",
              "JAVA_OPTS=-Djava.security.egd=file:///dev/urandom",
              "\"CATALINA_BASE=#{node['tomcat']['dir']}\"",
              "\"CATALINA_HOME=#{node['tomcat']['dir']}\"",
              "\"CATALINA_PID=#{node['tomcat']['dir']}/temp/tomcat.pid\"",
              '"CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"',
            ],
            ExecStart: "#{node['tomcat']['dir']}/bin/startup.sh",
            ExecStop: "#{node['tomcat']['dir']}/bin/shutdown.sh",
            RestartSec: '10',
            Restart: 'always',
          },
          Install: {
            WantedBy: 'multi-user.target',
          } })
  action [:create, :enable, :start]
end

