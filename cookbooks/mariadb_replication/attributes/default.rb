default['mariadb']['version'] = '10.6'

default['mariadb']['primary']['server_id'] = '1'
default['mariadb']['primary']['root']['password'] = 'root'
default['mariadb']['primary']['replication']['user'] = 'rep_user'
default['mariadb']['primary']['replication']['password'] = 'rep_user_password'
default['mariadb']['replicate_deny'] = {
  'binlog-ignore-db' => 'mysql,information_schema,performance_schema',
  'replicate-ignore-db' => 'mysql,information_schema,performance_schema',
}
default['mariadb']['replica']['server_id'] = '2'
default['mariadb']['replica']['root']['password'] = 'replicapass'
default['mariadb']['primary_address'] = ''
default['mariadb_replica']['galera']['cluster_name'] = 'Galerka'
default['mariadb_replica']['galera']['first'] = 'false'
