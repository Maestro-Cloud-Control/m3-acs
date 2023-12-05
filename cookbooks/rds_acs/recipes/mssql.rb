#
# Cookbook Name:: rds_acs
# Recipe:: mssql
#
# Copyright 2020
#
# All rights reserved - Do Not Redistribute
#

unless ::Win32::Service.exists?(node['rds_acs']['mssql']['instance_name'])

  # Only create if not already there
  directory node['rds_acs']['mssql']['temp_dir'] do
    action    :nothing
    recursive true
  end.run_action(:create)

  directory node['rds_acs']['mssql']['startup_dir'] do
    action    :nothing
    recursive true
  end.run_action(:create)

  # Create directories
  node['rds_acs']['mssql']['sql_dirs_array'].each do |dir|
    directory dir do
      action :create
      recursive true
    end
  end

  # Download Microsoft SQL Server 2017 (64-bit) installer
  installer_file = "#{Chef::Config['file_cache_path']}\\installer.exe"
  remote_file 'MS_SQL_Installer' do
    path      installer_file
    source    node['rds_acs']['mssql']['server']['url']
    checksum  node['rds_acs']['mssql']['server']['checksum']
    action :create
    notifies :create, 'template[ConfigurationFile.ini]', :immediately
  end

  # Create configuration file for installation. All configurations are to be made in this file.
  configuration_file = "#{node['rds_acs']['mssql']['temp_dir']}\\ConfigurationFile.ini"
  template 'ConfigurationFile.ini' do
    path configuration_file
    source 'mssql/mssql_configurationfile.ini.erb'
    mode '0755'
    variables(
      lazy do
        {
          'server_sa_password' => node.run_state['root_pass'],
          'sql_data_dir' => node['rds_acs']['mssql']['sql_data_dir'],
          'sql_user_db_dir' => node['rds_acs']['mssql']['sql_user_db_dir'],
          'sql_temp_db_dir' => node['rds_acs']['mssql']['sql_temp_db_dir'],
          'sql_user_db_log_dir' => node['rds_acs']['mssql']['sql_user_db_log_dir'],
        }
      end
    )
    action :nothing
    sensitive true
    notifies :run, 'execute[Install SQL Server]', :immediately
  end

  execute 'Install SQL Server' do
    command "#{installer_file} /Q /ConfigurationFile=#{configuration_file}"
    action :nothing
    notifies :add, 'windows_path[C:\\Program Files\\Microsoft SQL Server\\100\\Tools\\Binn]', :immediately
  end

  # Add sql client binaries to path
  windows_path 'C:\Program Files\Microsoft SQL Server\100\Tools\Binn' do
    action :nothing
    notifies :create, "template[#{node['rds_acs']['mssql']['temp_dir']}\\init.sql]", :immediately
  end

  # Create and run init script
  template "#{node['rds_acs']['mssql']['temp_dir']}\\init.sql" do
    source 'mssql/mssql_init.sql.erb'
    variables(
      lazy do
        {
        'db_name' => node.run_state['db_name'],
        'db_username' => node.run_state['db_user'],
        'db_userpass' => node.run_state['user_pass'],
        }
      end
    )
    action :nothing
    sensitive true
    notifies :run, 'execute[Run_init_script]', :immediately
  end
  execute 'Run_init_script' do
    command "\"C:\\Program Files\\Microsoft SQL Server\\Client SDK\\ODBC\\130\\Tools\\Binn\\sqlcmd.exe\" -i #{node['rds_acs']['mssql']['temp_dir']}\\init.sql -o #{Chef::Config['file_cache_path']}\\mssql_init.log"
    action :nothing
    notifies :run, 'execute[open_static_port]', :immediately
  end

  # Set firewall rule
  firewall_rule_name = "#{node['rds_acs']['mssql']['instance_name']} Static Port"
  execute 'open_static_port' do
    command "netsh advfirewall firewall add rule name=\"#{firewall_rule_name}\" dir=in action=allow protocol=TCP localport=#{node['rds_acs']['mssql']['port']}"
    returns [0, 1, 42]
    only_if do
      cmd = `netsh advfirewall firewall show rule name="#{firewall_rule_name}" | grep -c "#{firewall_rule_name}"`.to_i
      cmd == 0
    end
  end

  # Download and run user script if exists
  if !node.run_state['sql_init_script'].nil? && ::File.exist?("#{Chef::Config[:file_cache_path]}/user-script-checker")
    sql_user_script = "#{node['rds_acs']['mssql']['temp_dir']}\\init-user.sql"
    remote_file 'MS_SQL_user_script' do
      path sql_user_script
      source node.run_state['sql_init_script']
      mode   '655'
      notifies :create, 'file[user_script_checker]', :immediately
      notifies :run, 'execute[Run_user_script]', :immediately
    end

    file 'user_script_checker' do
      path "#{Chef::Config[:file_cache_path]}/user-script-checker"
      action :nothing
    end

    execute 'Run_user_script' do
      command "\"C:\\Program Files\\Microsoft SQL Server\\Client SDK\\ODBC\\130\\Tools\\Binn\\sqlcmd.exe\" -i #{sql_user_script} -o #{node['rds_acs']['mssql']['temp_dir']}\\user.log"
      action :nothing
      sensitive true
      notifies :delete, "remote_file[#{node['rds_acs']['mssql']['temp_dir']}\\init-user.sql]", :immediately
    end
  end

  # Remove temp directory in the end
  directory node['rds_acs']['mssql']['temp_dir'] do
    recursive true
    action :delete
  end

end
