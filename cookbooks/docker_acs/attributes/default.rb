# Set path for docker SSL keys
default['docker_acs']['cert_path'] = '/etc/docker/host.crt'
default['docker_acs']['key_path'] = '/etc/docker/host.key'
default['docker_acs']['ca_path'] = '/etc/docker/ca.crt'
default['docker_acs']['download_url'] = 'https://download.docker.com/linux/ubuntu'
default['docker_acs']['download_url_key'] = 'https://download.docker.com/linux/ubuntu/gpg'
default['docker_acs']['orch_url'] = '/api/autoconfiguration/docker'