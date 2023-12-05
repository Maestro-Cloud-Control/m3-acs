default['mongodb']['package_version'] = '4.4.0'

default['mongodb']['config']['auth'] = true
default['mongodb']['config']['mongod']['net']['bindIp'] = '0.0.0.0'

# override['mongodb']['authentication']['username'] = 'admin'
override['mongodb']['authentication']['password'] = lazy { node['metadata']['mongodb']['mongodb_user_password'] }

node.override['mongodb']['admin'] = {
  'username' => 'admin',
  'password' => lazy { node['metadata']['mongodb']['mongodb_user_password'] },
  'roles' => %w(userAdminAnyDatabase dbAdminAnyDatabase clusterAdmin),
  'database' => 'admin',
}