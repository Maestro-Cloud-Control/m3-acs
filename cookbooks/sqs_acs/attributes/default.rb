default['rabbitmq']['erlang']['enabled'] = true
default['rabbitmq']['erlang']['apt']['uri'] = "http://ppa.launchpad.net/rabbitmq/rabbitmq-erlang/ubuntu"
default['rabbitmq']['erlang']['apt']['lsb_codename'] = node['lsb']['codename']
default['rabbitmq']['erlang']['apt']['components'] = ["erlang"]
default['rabbitmq']['erlang']['apt']['key'] = "F77F1EDA57EBB1CC"
default['rabbitmq']['erlang']['apt']['install_options'] = %w(--fix-missing)

default['rabbitmq']['deb_package'] = 'rabbitmq-server_3.8.6-1_all.deb'
default['rabbitmq']['deb_package_url'] = 'https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.6/'

default['sqs_acs']['jar_download_url'] = '/sqs_acs/messaging-1.0.jar?name='
default['rabbitmq']['version'] = '3.8.6-1'

default['sqs_acs']['guest']['username'] = 'guest'
default['sqs_acs']['guest']['password'] = 'password'

