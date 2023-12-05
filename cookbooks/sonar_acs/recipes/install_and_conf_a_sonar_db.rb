#
# Cookbook Name:: sonar_acs
# Recipe:: install_and_conf_a_sonar_db
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

# Install postgresql server
package 'postgresql' do
  action :install
  notifies :run, 'ruby_block[get_postgresql_version]', :immediately
end

# get postgresql version
Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)

ruby_block 'get_postgresql_version' do
  block do
    postgresql_version = shell_out("dpkg -l | grep postgresql | awk '{ print $3 }' | head -n 1 | cut -c -2")
    node.run_state['postgresql_version'] = postgresql_version.stdout.strip
    Chef::Log.info("Installed version postgresql #{node.run_state['postgresql_version']}")
  end
  action :nothing
  notifies :create, "template[#{Chef::Config['file_cache_path']}/init.sql]", :immediately
end

# Temptate, which contains all initial credentials
template "#{Chef::Config['file_cache_path']}/init.sql" do
  source 'init.sql.erb'
  owner 'postgres'
  mode 00600
  variables(
    lazy do
      {
        db_name:     'sonar',
        db_username: node['sonarqube']['jdbc']['username'],
        db_userpass: node['metadata']['sonar']['db_user_password'],
        db_rootpass: node['metadata']['sonar']['db_root_password'],
      }
    end
  )
  action   :nothing
  notifies :run, 'execute[create-cluster]', :immediately
end

# Create cluster
execute 'create-cluster' do
  command lazy { 
    "pg_dropcluster #{node.run_state['postgresql_version']} main --stop; export LC_ALL='en_US.UTF-8' \
    && pg_createcluster #{node.run_state['postgresql_version']} main --start" 
  }
  action :nothing
  notifies :restart, 'service[postgresql]', :immediately
  notifies :run, 'bash[run-postgresql-init]', :immediately
end

# Run Initialization scripts
bash 'run-postgresql-init' do
  code <<-EOS
    until pids=$(pidof postgres)
    do
      sleep 1
    done
    su - postgres -c "export LC_ALL='en_US.UTF-8' && psql -f #{Chef::Config['file_cache_path']}/init.sql"
  EOS
  action   :nothing
  notifies :create, 'template[upload_pg_hba.conf]', :immediately
end

# Template for access configuration
template 'upload_pg_hba.conf' do
  source 'pg_hba.conf.erb'
  path lazy { "/etc/postgresql/#{node.run_state['postgresql_version']}/main/pg_hba.conf" }
  owner 'postgres'
  mode 00600
  variables(
    db_name:     'sonar',
    db_username: node['sonarqube']['jdbc']['username']
  )
  action   :nothing
  notifies :restart, 'service[postgresql]', :immediately
end

service 'postgresql' do
  action [:enable, :start]
end