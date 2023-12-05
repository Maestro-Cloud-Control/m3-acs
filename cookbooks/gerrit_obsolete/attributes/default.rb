# gerrit
default['gerrit']['home_dir'] = '/home/gerrit'
default['gerrit']['base_dir'] = 'review_site'
default['gerrit']['username'] = 'gerrit'
default['gerrit']['run']['script']['sh'] = 'bin/gerrit.sh'
default['gerrit']['version'] = '3.0.3'
default['gerrit']['sshd']['listen_address'] = '*:29418'
default['gerrit']['httpd']['listen_url'] = 'http://*:8080/'
default['gerrit']['httpd']['listen_port'] = '8080'

# for gerrit config
default['gerrit']['auth']['type'] = 'DEVELOPMENT_BECOME_ANY_ACCOUNT'

