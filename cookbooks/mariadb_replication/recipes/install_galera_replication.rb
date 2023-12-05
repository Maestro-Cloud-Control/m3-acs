mariadb_repository 'install' do
  version node['mariadb']['version']
end

mariadb_server_install 'package' do
  action [:install, :create]
  version node['mariadb']['version']
  password node['mariadb']['primary']['root']['password']
end

service 'mariadb' do
  action :nothing
end

mariadb_server_configuration 'MariaDB Server Configuration' do
  version node['mariadb']['version']
  mysqld_bind_address '0.0.0.0'
end

matching_node = search(:node, 'mariadb_replica_galera_first:true',
  filter_result: { 'name' => [ 'name' ],
    'ip' => [ 'ipaddress' ],
    'fqdn' => [ 'fqdn' ],
  } 
)

if matching_node.empty?
  node.normal['mariadb_replica']['galera']['first'] = 'true'
  Chef::Log.info('Init node is not set. Setting up...')

  mariadb_galera_configuration 'MariaDB Galera Server Configuration' do
    version node['mariadb']['version']
    cluster_name node['mariadb_replica']['galera']['cluster_name']
    cluster_search_query "mariadb_replica_galera_cluster_name:#{node['mariadb_replica']['galera']['cluster_name']}"
    action [:create, :bootstrap]
  end

else
  Chef::Log.info("Init node is present: #{matching_node}")
  Chef::Log.info('Installing secondary...')

  mariadb_galera_configuration 'MariaDB Galera Server Configuration' do
    version node['mariadb']['version']
    cluster_name node['mariadb_replica']['galera']['cluster_name']
    cluster_search_query "mariadb_replica_galera_cluster_name:#{node['mariadb_replica']['galera']['cluster_name']}"
    action [:create, :join]
  end
end
