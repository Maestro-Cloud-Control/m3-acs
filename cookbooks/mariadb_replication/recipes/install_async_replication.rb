if node.role?('mariadb_async_primary')
  secrets = begin
    data_bag_item('mariadb_async', 'primary')
            rescue Net::HTTPServerException, Chef::Exceptions::InvalidDataBagPath
              [] # empty array for length comparison
  end

  if secrets['root_password'].empty? == false &&
     secrets['server_id'].empty? == false &&
     secrets['replication_user'].empty? == false &&
     secrets['replication_password'].empty? == false

    node.default['mariadb']['primary']['root']['password'] = secrets['root_password']
    node.default['mariadb']['primary']['server_id'] = secrets['server_id']
    node.default['mariadb']['primary']['replication']['user'] = secrets['replication_user']
    node.default['mariadb']['primary']['replication']['password'] = secrets['replication_password']
  else
    Chef::Log.info('Some value in data bag is empty. Check databag')
    raise 'Some value in data bag is empty. Check databag'
  end

  mariadb_repository 'install' do
    version node['mariadb']['version']
  end

  mariadb_server_install 'package' do
    action [:install, :create]
    version node['mariadb']['version']
    password node['mariadb']['primary']['root']['password']
  end

  mariadb_server_configuration 'MariaDB Server Configuration' do
    version node['mariadb']['version']
    mysqld_bind_address '0.0.0.0'
    replication_server_id node['mariadb']['primary']['server_id']
    replication_options node['mariadb']['replicate_deny']
  end

  service 'mariadb' do
    action [:stop, :start]
  end

  mariadb_database 'test_database' do
    action :create
    password node['mariadb']['primary']['root']['password']
    sql <<-SQL
    CREATE TABLE `test_table` (
      `123123` INT NOT NULL AUTO_INCREMENT,
      `1231` VARCHAR(255),
      PRIMARY KEY (`123123`)
    );
    SQL
  end

  mariadb_user node['mariadb']['primary']['replication']['user'] do
    ctrl_password node['mariadb']['primary']['root']['password']
    password node['mariadb']['primary']['replication']['password']
    host '%'
    privileges [:all] # Also it's needed to fix problem with "replication slave" privilege in MySQL
    action :grant
  end

  mariadb_database 'test_database2' do
    action :create
    password node['mariadb']['primary']['root']['password']
    sql <<-SQL
    CREATE TABLE `test_table2` (
      `123123` INT NOT NULL AUTO_INCREMENT,
      `1231` VARCHAR(255),
      PRIMARY KEY (`123123`)
    );
    SQL
  end
end

if node.role?('mariadb_async_replica')

  secrets = begin
    data_bag_item('mariadb_async', 'replica')
            rescue Net::HTTPServerException, Chef::Exceptions::InvalidDataBagPath
              [] # empty array for length comparison
  end

  if secrets['server_id'].empty? == false &&
     secrets['root_password'].empty? == false &&
     secrets['replication_user'].empty? == false &&
     secrets['replication_password'].empty? == false &&
     secrets['primary_dns'].empty? == false

    node.default['mariadb']['replica']['server_id'] = secrets['server_id']
    node.default['mariadb']['replica']['root']['password'] = secrets['root_password']
    node.default['mariadb']['primary']['replication']['user'] = secrets['replication_user']
    node.default['mariadb']['primary']['replication']['password'] = secrets['replication_password']
    node.default['mariadb']['primary_address'] = secrets['primary_dns']
  else
    Chef::Log.info('Some value in data bag is empty. Check databag')
    raise 'Some value in data bag is empty. Check databag'
  end

  mariadb_repository 'install' do
    version node['mariadb']['version']
  end

  mariadb_server_install 'package' do
    action [:install, :create]
    version node['mariadb']['version']
    password node['mariadb']['replica']['root']['password']
  end

  mariadb_server_configuration 'MariaDB Server Configuration' do
    version node['mariadb']['version']
    replication_server_id node['mariadb']['replica']['server_id']
    replication_options node['mariadb']['replicate_deny']
  end

  mariadb_database 'deny replicate mysqldb' do
    password node['mariadb']['replica']['root']['password']
    sql "SET GLOBAL replicate_ignore_db='mysql,information_schema,performance_schema';"
    action :query
  end

  service 'mariadb' do
    action [:stop, :start]
  end

  mariadb_replication "slave_#{node['hostname']}" do
    action [:add, :start]
    password node['mariadb']['replica']['root']['password']
    master_user node['mariadb']['primary']['replication']['user']
    master_password node['mariadb']['primary']['replication']['password']
    master_host node['mariadb']['primary_address']
    master_use_gtid 'current_pos'
    master_connect_retry '10'
  end
end
