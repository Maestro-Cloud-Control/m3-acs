#
# Cookbook Name:: jenkins_acs
# Resource:: install_plugins
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute

unified_mode true

property :plugins, Array
property :flags_path, String

action :install do
  directory "#{Chef::Config[:file_cache_path]}/jpr" do
    action :nothing
  end.run_action(:create)

  cookbook_file "#{Chef::Config[:file_cache_path]}/jpr/JenkinsPluginResolver.py" do
    source 'jpr/JenkinsPluginResolver.py'
    backup false
    mode '0755'
    action :nothing
  end.run_action(:create)

  python 'resolve plugins versions' do
    cwd Chef::Config[:file_cache_path]
    interpreter 'python3'
    code <<-EOH
input = '#{JSON.generate(new_resource.plugins)}'
import json, os, sys
sys.path.insert(0, '#{Chef::Config[:file_cache_path]}')
from jpr.JenkinsPluginResolver import JenkinsPluginResolver
jpr = JenkinsPluginResolver()
for p in json.loads(input):
  if 'version' in p:
    jpr.load(p['name'], p['version'])
  else:
    jpr.load(p['name'])
plugins = list()
for n, v in jpr.dump().items():
  uc_plugin = jpr.uc_post()['plugins'][n]
  if uc_plugin['version'] == v:
      url = uc_plugin['url']
  else:
      url = uc_plugin['url'].replace(uc_plugin['version'], v)
  plugins.append({'name': n, 'version': v, 'url': url})
with open('jenkins-plugins.json', 'w') as f:
  f.write(json.dumps(plugins))
EOH
    action :nothing
  end.run_action(:run)

  plugins = JSON.parse(::File.read("#{Chef::Config[:file_cache_path]}/jenkins-plugins.json"))
  plugins.each do |plugin|
    jenkins_plugin plugin['name'] do
      action :install
      source plugin['url']
      notifies :create, 'file[reload-configuration]', :immediately
    end
  end

  file 'reload-configuration' do
    path    "#{new_resource.flags_path}/reload-configuration"
    action  :nothing
  end

  jenkins_command 'restart' do
    action    :execute
    only_if   { ::File.exist?("#{new_resource.flags_path}/reload-configuration") }
    notifies  :delete, 'file[reload-configuration]', :immediately
  end
end
