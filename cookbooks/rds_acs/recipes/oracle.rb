# Cookbook Name:: rds_acs
# Recipe:: oracle
# Copyright 2019
# All rights reserved - Do Not Redistribute

# Create user and group to work with oracle databases
user 'oracle' do
  password node.run_state['root_pass']
end

group 'dba' do
  members 'oracle'
end

# https://github.com/chef/chef/issues/4468
%w[ 
  /u01
  /u01/app/
  /u01/app/oracle
  /u01/app/oracle/product
  /u01/app/oracle/product/19.0.0
  /u01/app/oracle/product/19.0.0/dbhome_1
].each do |path|
  directory path do
    owner     'oracle'
    group     'dba'
    mode      '755'
    recursive true
    action    :create
  end
end

swap_file '/swap' do
  size 4096
end

# Preinstall oracle 19
yum_package 'oracle-database-preinstall-19c' do
  action :install
end

# Create template for install oracle
template '/home/oracle/db_install.rsp' do
  source 'oracle/db_install.rsp.erb'
  owner 'oracle'
  group 'dba'
  mode '644'
  action :create
end

# Download zip archive oracle
remote_file "#{node['rds_acs']['oracle_home']}/oracle_19.zip" do
  source node['metadata']['common']['storage_url'] + node['rds_acs']['oracle_download_url'] + node['name']
  owner 'oracle'
  group 'dba'
  checksum node['rds_acs']['oracle_checksum']
  action :create
  not_if { ::File.exist?("#{node['rds_acs']['oracle_home']}/oracle_19.zip") }
end

# Unzip Change owner
bash 'unzip_and_change_owner' do
  code <<-EOS
    cd #{node['rds_acs']['oracle_home']}
    unzip -xuo #{node['rds_acs']['oracle_home']}/oracle_19.zip
    chown -R oracle:dba /u01/app/oracle/product/19.0.0
    chmod 644 /home/oracle/db_install.rsp
  EOS
  action :run
  not_if { ::File.exist?("#{node['rds_acs']['oracle_home']}/runInstaller") }
end

# Install oracle 19
execute 'installing_oracledb' do
  command "su - oracle -c \"#{node['rds_acs']['oracle_home']}/runInstaller -waitforcompletion -silent -ignorePrereq -responseFile /home/oracle/db_install.rsp\""
  not_if "test -f #{node['rds_acs']['oinventory_dir']}/oraInst.loc"
end

execute 'orainstRoot.sh' do
  command "#{node['rds_acs']['oinventory_dir']}/orainstRoot.sh"
  not_if { ::File.exist?('/etc/oraInst.loc') }
end

execute 'root.sh' do
  command "#{node['rds_acs']['oracle_home']}/root.sh"
  not_if { ::File.exist?('/etc/oratab') }
end

# Create template for database
template "#{node['rds_acs']['oracle_home']}/assistants/dbca/templates/create_db.dbc" do
  owner 'oracle'
  group 'dba'
  mode '644'
  source 'oracle/create_db.dbc.erb'
end

host_name = node['fqdn'] != '' ? node['fqdn'] : node['hostname']

# Create template for network configure
template "#{node['rds_acs']['oracle_home']}/network/admin/listener.ora" do
  owner 'oracle'
  group 'dba'
  mode '644'
  variables(
    host_name: host_name
  )
  source 'oracle/listener.ora.erb'
end

# Create template for PATH
template '/etc/profile.d/oracle.sh' do
  owner 'oracle'
  group 'dba'
  mode '744'
  source 'oracle/oracle.sh.erb'
end

execute 'export_env_vars' do
  command '/etc/profile.d/oracle.sh'
end

# Create listener.log
file "#{node['rds_acs']['oracle_home']}/network/log/listener.log" do
  owner 'oracle'
  group 'dba'
  mode '644'
  action :create_if_missing
end

# Create database
if File.exist?("#{node['rds_acs']['oinventory_dir']}/oraInst.loc")

  execute 'start_listener' do
    command "su - oracle -c '/etc/profile.d/oracle.sh; lsnrctl start'"
    not_if 'ps ax | grep LISTENER | grep -v grep'
  end

  template "#{node['rds_acs']['oracle_home']}/db_create.rsp" do
    owner 'oracle'
    group 'dba'
    mode '644'
    source 'oracle/db_create.erb'
  end

  execute 'create_database' do
    command "su - oracle -c \"#{node['rds_acs']['oracle_home']}/bin/dbca -silent -createDatabase -templateName create_db.dbc -responseFile #{node['rds_acs']['oracle_home']}/db_create.rsp\""
    not_if "grep #{node.run_state['db_name']} /etc/oratab"
  end

  template '/etc/oratab' do
    owner 'oracle'
    group 'dba'
    mode '664'
    source 'oracle/oratab.erb'
  end

  template '/etc/init.d/oracle' do
    mode '755'
    owner 'oracle'
    group 'dba'
    source 'oracle/oracle-init.sh.erb'
  end

  service 'oracle' do
    action [ :enable, :start ]
  end
end

# Template, which contains all initial credentials
template "#{node['rds_acs']['tmp_dir']}/createTablespaceAndUsers.sql" do
  source 'oracle/createTablespaceAndUsers.sql.erb'
  mode '600'
  owner 'oracle'
  group 'dba'
  variables(
    lazy do
      {
      'prod_user' => node.run_state['db_user'],
      'prod_passwd' => node.run_state['user_pass'],
      }
    end
  )
end

bash 'run_init_script' do
  code <<-EOS
    bash /etc/profile.d/oracle.sh
    su - oracle -c "#{node['rds_acs']['oracle_home']}/bin/sqlplus / as sysdba @#{node['rds_acs']['tmp_dir']}/createTablespaceAndUsers.sql"
  EOS
  notifies :delete, "template[#{node['rds_acs']['tmp_dir']}/createTablespaceAndUsers.sql]", :immediately
end

unless node.run_state['sql_init_script'].nil?
  user_script = "#{node['rds_acs']['tmp_dir']}/user-script.sql"
  remote_file 'oracle_user_script' do
    path   user_script
    source node.run_state['sql_init_script']
    not_if node.run_state['sql_init_script'] == ''
    mode   '655'
    owner 'oracle'
    group 'dba'
    action :create
  end

  bash 'run_oracle_user_script' do
    code <<-EOS
      bash /etc/profile.d/oracle.sh
      su - oracle -c "#{node['rds_acs']['oracle_home']}/bin/sqlplus system/#{node.run_state['root_pass']} @#{node['rds_acs']['tmp_dir']}/user-script.sql"
    EOS
    notifies :delete, "remote_file[#{node['rds_acs']['tmp_dir']}/user-script.sql]", :immediately
  end
end
