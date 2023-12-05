default['rds_acs']['mssql']['temp_dir'] = 'C:\\sql_tmp'
default['rds_acs']['mssql']['startup_dir'] = 'C:\\scr'
default['rds_acs']['mssql']['install_dir'] = 'C:\Program Files\Microsoft SQL Server'
default['rds_acs']['mssql']['port'] = 1433
default['rds_acs']['mssql']['instance_name'] = 'MSSQLSERVER'
default['rds_acs']['mssql']['feature_list'] = 'SQL'
#'SQLEngine,RS,SQL'
default['rds_acs']['mssql']['instance_dir'] = 'C:\Program Files\Microsoft SQL Server'
default['rds_acs']['mssql']['shared_wow_dir'] = 'C:\Program Files (x86)\Microsoft SQL Server'

default['rds_acs']['mssql']['sql_files_dir'] = 'C:\\MSSQL'
default['rds_acs']['mssql']['sql_data_dir'] = "#{node['rds_acs']['mssql']['sql_files_dir']}\\DataDir"
default['rds_acs']['mssql']['sql_user_db_dir'] = "#{node['rds_acs']['mssql']['sql_files_dir']}\\UserDbDir"
default['rds_acs']['mssql']['sql_temp_db_dir'] = "#{node['rds_acs']['mssql']['sql_files_dir']}\\UserDbLogDir"
default['rds_acs']['mssql']['sql_user_db_log_dir'] = "#{node['rds_acs']['mssql']['sql_files_dir']}\\TempDir"
default['rds_acs']['mssql']['sql_dirs_array'] = [
    node['rds_acs']['mssql']['sql_data_dir'],
    node['rds_acs']['mssql']['sql_user_db_dir'],
    node['rds_acs']['mssql']['sql_temp_db_dir'],
    node['rds_acs']['mssql']['sql_user_db_log_dir'],
]
default['rds_acs']['mssql']['agent_account'] = 'NT AUTHORITY\NETWORK SERVICE'
default['rds_acs']['mssql']['agent_startup'] = 'Automatic'
default['rds_acs']['mssql']['sql_account'] = 'NT AUTHORITY\NETWORK SERVICE'
default['rds_acs']['mssql']['sysadmins'] = 'Administrator'
default['rds_acs']['mssql']['admin'] = ''
default['rds_acs']['mssql']['rs_account'] = 'NT AUTHORITY\NETWORK SERVICE'
default['rds_acs']['mssql']['server']['url'] = 'https://download.microsoft.com/download/E/F/2/EF23C21D-7860-4F05-88CE-39AA114B014B/SQLEXPR_x64_ENU.exe'
default['rds_acs']['mssql']['server']['checksum'] = 'f857ff82145e196bf85af32eeb0193fe38302e57b30beb54e513630c60d83e0d'
default['rds_acs']['mssql']['server']['package_name'] = 'Microsoft SQL Server 2019 (64-bit)'
default['rds_acs']['mssql']['size'] = ''
