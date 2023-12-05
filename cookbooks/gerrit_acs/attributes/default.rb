release = default['gerrit']['version'] = '3.8.1'

default['gerrit']['release_package'] = "https://gerrit-releases.storage.googleapis.com/gerrit-#{release}.war"
default['gerrit']['user'] = 'gerrit'
default['gerrit']['dir'] = '/opt/gerrit'
default['gerrit']['port'] = '80' # not 8080, is used for localhost
default['gerrit']['ssh_port'] = '29418'

