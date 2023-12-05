unified_mode true

action_class do
  include Eporch2::Helpers
end

action :get do
  docker_cert = http_get(url: node['metadata']['common']['orch_api'] + node['docker_acs']['orch_url'], params: { instanceId: node['name'] })
  if docker_cert.empty?
    Chef::Log.debug('docker_cert is empty')
  else
    certs = docker_cert.split(';')

    file 'docker_restart_required' do
      path "#{Chef::Config[:file_cache_path]}/docker_restart_required.sem"
      action :nothing
    end

    file node['docker_acs']['cert_path'] do
      content certs[0]
      mode '600'
      only_if { !::File.exist?(node['docker_acs']['cert_path']) }
      notifies :touch, 'file[docker_restart_required]', :immediately
    end

    file node['docker_acs']['key_path'] do
      content certs[1]
      mode '600'
      only_if { !::File.exist?(node['docker_acs']['key_path']) }
      notifies :touch, 'file[docker_restart_required]', :immediately
    end

    file node['docker_acs']['ca_path'] do
      content certs[2]
      mode '600'
      only_if { !::File.exist?(node['docker_acs']['ca_path']) }
      notifies :touch, 'file[docker_restart_required]', :immediately
    end

    execute 'restart docker' do
      command 'systemctl restart docker.service'
      action :run
      only_if { ::File.exist?("#{Chef::Config[:file_cache_path]}/docker_restart_required.sem") }
      notifies :delete, 'file[docker_restart_required]', :immediately
    end
  end
end
