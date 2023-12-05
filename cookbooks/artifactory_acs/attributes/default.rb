override['nginx']['repo_source'] = 'epel'

default['artifactory']['home'] = '/opt/artifactory'
default['artifactory']['user'] = 'artifactory'
default['artifactory']['group'] = 'artifactory'

default['artifactory']['install_java'] = false

default['artifactory']['data_dir'] = '/artifactory/filestore'
