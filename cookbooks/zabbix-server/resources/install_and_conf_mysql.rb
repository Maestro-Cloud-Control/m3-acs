# 
# Cookbook:: zabbix-server
# Resources:: install_and_conf_mysql
#
# Copyright:: 2019, All Rights Reserved.

unified_mode true

action :conf do

  mysql_client 'default' do
    action  :create
    version '8.0'
  end

  mysql_service 'default' do
    version       node['zabbix-server']['mysql']['mysql_version']
    port          node['zabbix-server']['mysql']['dbport']
    bind_address  node['zabbix-server']['mysql']['dbhost']
    action        [:create, :start]
  end

  ruby_block 'wait for service start' do
    block do
      sleep(10)
    end
    action :run
  end

  mysql_database node['zabbix-server']['mysql']['dbname'] do
    host      'localhost' # Connection with sudo use only for localhost (not the same as 127.0.0.1)
    encoding	'utf8mb4'
    collation 'utf8mb4_bin'
    action    :create
  end
  
  mysql_user node['zabbix-server']['mysql']['dbuser'] do
    password      node['metadata']['zabbix_server']['db_user_password'] 
    database_name node['zabbix-server']['mysql']['dbname']
    host          '%'
    # privileges  [:select,:update,:insert] -> :all by default
    action        [:create, :grant]
  end

  # gz format does not support archive_file resource
  #
  # archive_file 'extract archive create.sql.gz' do
  #   path '/usr/share/doc/zabbix-server-mysql/create.sql.gz'
  #   destination '/usr/share/doc/zabbix-server-mysql/'
  # end

  execute 'extract archive server.sql.gz' do
    command 'gunzip /usr/share/zabbix-sql-scripts/mysql/server.sql.gz'
    action  :run
    not_if { ::File.exist?('/usr/share/zabbix-sql-scripts/mysql/server.sql') }
  end

  execute 'run server.sql' do
    command "mysql -e 'use zabbix; source /usr/share/zabbix-sql-scripts/mysql/server.sql;'"
    action  :run
    not_if "mysql -e 'use zabbix; show tables;' |grep users"
  end

  password_bcrypt_hash = `htpasswd -nbBC 10 Admin #{node['metadata']['zabbix_server']['login_password']} | grep -o -P "(?<=Admin:).+" |  tr -d '\n'`
  Chef::Log.info("bcrypt_hash of admin passwd: #{password_bcrypt_hash}")

  template '/tmp/Admin_passwd.sql' do
    source 'mysql/Admin_passwd.sql.erb'
    owner 'root'
    group 'root'
    mode '0600'
    action :create
    variables(
        :password => password_bcrypt_hash
    )
  end

  template '/tmp/double.sql' do
    source 'mysql/double.sql.erb'
    owner 'root'
    group 'root'
    mode '0600'
    action :create
  end

  mysql_database 'update zabbix Admin password and upgrade to numeric values of extended range' do
    database_name node['zabbix-server']['mysql']['dbname']
    host          'localhost'
    sql           "use #{node['zabbix-server']['mysql']['dbname']}; source /tmp/Admin_passwd.sql; source /tmp/double.sql;"
    action :query
  end

  # if node['zabbix-server']['mysql']['db_restored']['status'].empty?
  #   # mysql_database 'upload zabbix db' do
  #   #   database_name node['zabbix-server']['mysql']['dbname']
  #   #   host          'localhost'
  #   #   # port          node['zabbix-server']['mysql']['dbport']
  #   #   # user          node['zabbix-server']['mysql']['dbuser']
  #   #   # password      node['zabbix_server']['db_user_password']
  #   #   sql           "use #{node['zabbix-server']['mysql']['dbname']}; source /usr/share/zabbix-sql-scripts/mysql/server.sql;"
  #   #   action :query
  #   # end

  #   mysql_database 'update zabbix Admin password' do
  #     database_name node['zabbix-server']['mysql']['dbname']
  #     host          'localhost'
  #     # port          node['zabbix-server']['mysql']['dbport']
  #     # user          node['zabbix-server']['mysql']['dbuser']
  #     # password      node['zabbix_server']['db_user_password']
  #     sql           "update zabbix.users set passwd=md5(\'#{node['zabbix_server']['admin_password']}\') where alias=\'Admin\';"
  #     action        :query
  #   end
  
  #   mysql_database 'insert zabbix user creds for login' do
  #     database_name node['zabbix-server']['mysql']['dbname']
  #     host          'localhost'
  #     # port          node['zabbix-server']['mysql']['dbport']
  #     # user          node['zabbix-server']['mysql']['dbuser']
  #     # password      node['zabbix_server']['db_user_password']
  #     sql           "INSERT INTO zabbix.users (userid,alias,name,surname,passwd,autologin,autologout,lang,refresh,type,theme) VALUES(3,'admin','Zabbix','Administrator',md5('#{node['zabbix_server']['login_password']}'),1,900,'en_GB','30s',3,'default') ON DUPLICATE KEY UPDATE passwd=md5('#{node['zabbix_server']['login_password']}');"
  #     action :query
  #   end

  #   node.normal['zabbix-server']['mysql']['db_restored']['status'] = 'restored'
  # else
  #   Chef::Log.info('Zabbix db was restored and configured; Admin password updated; user creds for login inserted')
  # end
end
