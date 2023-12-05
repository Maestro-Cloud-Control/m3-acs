#
# Cookbook:: gerrit_acs
# Recipe:: default
#
# Copyright:: 2019, All Rights Reserved.

eporch2_meta_data 'meta_data' do
  name 'gerrit'
  action :nothing
end.run_action(:update)

# install java && git
include_recipe 'gerrit_acs::ssl'
include_recipe 'corretto-java'
include_recipe 'git'

# Create user and group for gerrit
group node['gerrit']['username'] do
  comment 'Gerrit Code Review Groop'
  action :create
end

user node['gerrit']['username'] do
  comment 'Gerrit Code Review User'
  gid node['gerrit']['username']
  home node['gerrit']['home_dir']
  action :create
end

# configure gerrit
template '/etc/default/gerritcodereview' do
  source 'gerrit/gerritcodereview.erb'
  mode 00644
  owner node['gerrit']['username']
  group node['gerrit']['username']
  variables(
    gerrit_site: "#{node['gerrit']['home_dir']}/#{node['gerrit']['base_dir']}"
  )
end

%W(
  node['gerrit']['home_dir']
  #{node['gerrit']['home_dir']}/git
  #{node['gerrit']['home_dir']}/#{node['gerrit']['base_dir']}
  #{node['gerrit']['home_dir']}/#{node['gerrit']['base_dir']}/etc
  #{node['gerrit']['home_dir']}/#{node['gerrit']['base_dir']}/lib
  #{node['gerrit']['home_dir']}/.ssh
).each do |path|
  directory path do
    owner        node['gerrit']['username']
    group        node['gerrit']['username']
    mode         '00755'
    action       :create
    recursive    true
  end
end

# build out gerrit configuration
template 'upload gerrit secure.config' do
  source    'gerrit/secure.config.erb'
  path      "#{node['gerrit']['home_dir']}/#{node['gerrit']['base_dir']}/etc/secure.config"
  mode      00600
  owner     node['gerrit']['username']
  group     node['gerrit']['username']
  sensitive true
  variables(
    server: node['metadata']['gerrit']['ldap_server'],
    user: node['metadata']['gerrit']['ldap_user'],
    password: node['metadata']['gerrit']['ldap_password'],
  )
end

template 'upload gerrit.config' do
  source    'gerrit/gerrit.config.erb'
  path      "#{node['gerrit']['home_dir']}/#{node['gerrit']['base_dir']}/etc/gerrit.config"
  mode      00666
  owner     node['gerrit']['username']
  group     node['gerrit']['username']
  sensitive true
  variables(
    lazy do
      {
        javahome: node['corretto-java']['javahome'],
      }
    end
  )
end

# download the gerrit.war file if it doesn't already exist
remote_file "#{node['gerrit']['home_dir']}/gerrit.war" do
  owner          node['gerrit']['username']
  group          node['gerrit']['username']
  ignore_failure true
  source         "#{node['metadata']['common']['storage_url']}/gerrit/gerrit-#{node['gerrit']['version']}.war?name=#{node['name']}"
  not_if         { ::File.exist?("#{node['gerrit']['home_dir']}/gerrit.war") }
end

remote_file "#{node['gerrit']['home_dir']}/gerrit.war" do
  owner  node['gerrit']['username']
  group  node['gerrit']['username']
  source "https://gerrit-releases.storage.googleapis.com/gerrit-#{node['gerrit']['version']}.war"
  not_if { ::File.exist?("#{node['gerrit']['home_dir']}/gerrit.war") }  
end

package ['unzip', 'gitweb'] do
  action :install
end

# Install replication and download-commands plugins
%w(
  codemirror-editor
  delete-project
  replication
  download-commands
  gitiles
  hooks
  plugin-manager
  reviewnotes
  webhooks
).each() do |plugin|
  execute "Initiall #{plugin} plugin" do
    command "unzip -j gerrit.war WEB-INF/plugins/#{plugin}.jar -d #{node['gerrit']['home_dir']}/#{node['gerrit']['base_dir']}/plugins/"
    cwd     node['gerrit']['home_dir']
    user    node['gerrit']['username']
    group   node['gerrit']['username']
    not_if  { ::File.exist?("#{node['gerrit']['home_dir']}/#{node['gerrit']['base_dir']}/plugins/#{plugin}.jar") }
  end
end

# Grant a user sudo privileges for any command
sudo 'admin' do
  user     node['gerrit']['username']
  nopasswd true
  action   :create
end

execute 'Initialize Gerrit Site' do
  command <<-EOS
    chown -R #{node['gerrit']['username']}:#{node['gerrit']['username']} #{node['gerrit']['home_dir']}
    sudo -u gerrit java -jar gerrit.war init --batch -d #{node['gerrit']['base_dir']}
    sudo -u gerrit java -jar gerrit.war reindex -d #{node['gerrit']['base_dir']}
  EOS
  cwd     node['gerrit']['home_dir']
  user    node['gerrit']['username']
  group   node['gerrit']['username']
  not_if  { ::File.exist?("#{node['gerrit']['home_dir']}/#{node['gerrit']['base_dir']}/bin") }
end

template 'add the systemctl gerrit service' do
  source 'gerrit/gerrit.service.erb'
  path   '/etc/systemd/system/gerrit.service'
  group  node['gerrit']['user']
  mode   '0755'
  variables(
    service_user:     node['gerrit']['username'],
    service_group:    node['gerrit']['username'],
    gerrit_sh:        "#{node['gerrit']['home_dir']}/#{node['gerrit']['base_dir']}/#{node['gerrit']['run']['script']['sh']}",
    gerrit_pid_file:  "#{node['gerrit']['home_dir']}/#{node['gerrit']['base_dir']}/logs/gerrit.pid"
  )
  action :create
end

# reload systemctl
execute 'reload systemctl' do
  command 'systemctl daemon-reload'
  action :nothing
end

# activate service
service 'gerrit' do
  supports restart: true, reload: true, status: true
  action [:enable, :start]
end

# set admin user
gerrit_acs_create_admin_user 'set up machine owner as admin gerrit server' do 
  action  :set
  only_if { node['gerrit']['auth']['type'] != 'LDAP' }
end