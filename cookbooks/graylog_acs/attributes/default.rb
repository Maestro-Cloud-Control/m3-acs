default['corretto-java']['version'] = '8'

override['mongodb']['package_version'] = '4.4.0'
override['mongodb']['config']['mongos']['net']['bindIp'] = '127.0.0.1'

override['graylog2']['major_version'] = '4.2'
override['graylog2']['server']['version'] = '4.2.4-1'
override['graylog2']['install_enterprise_plugins'] = false
override['graylog2']['install_enterprise_integrations_plugins'] = false
override['graylog2']['mongodb']['uri'] = 'mongodb://127.0.0.1:27017/graylog'

default['graylog_acs']['web']['listen_address'] = '127.0.0.1'
default['graylog_acs']['transport_email_use_ssl'] = false
default['graylog_acs']['attribute']['state'] = ''
default['graylog_acs']['check_service'] = 'total'
default['graylog_acs']['authorized_ports'] = 514
default['graylod_acs']['conf_status'] = ''

default['graylog_acs']['elasticsearch']['download_url'] = 'https://artifacts.elastic.co/packages/7.x/apt'
default['graylog_acs']['elasticsearch']['download_url_key'] = 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
default['graylog_acs']['elasticsearch']['cluster_name'] = 'graylog'
