provides :zabbix_client_install

action :install do
  Chef::Log.info('Current Zabbix server: ' + node['zabbix-client']['zabbix-server'])

  case node['platform']
  when 'windows'
    windows_package 'azazabbix-agent' do
      source node['zabbix-client']['win']['agent_url']
      installer_type :msi
      action :install
      options "SERVER=#{node['zabbix-client']['zabbix-server']} HOSTNAME=#{node['zabbix-client']['zabbix_hostname']} INSTALLFOLDER=#{node['zabbix-client']['win']['home']} ENABLEREMOTECOMMANDS=1"
    end
  when 'ubuntu', 'debian', 'redhat', 'centos', 'amazon', 'oracle'

    case node['platform_family']
    when 'rhel'
      execute 'yum-update' do
        command 'yum update -y -q -e 0'
        action :nothing
      end
      file_name = node['zabbix-client']['rhel']['repo_package'].split('/').last
      remote_file 'zabbix-release-rhel' do
        source node['zabbix-client']['rhel']['repo_package']
        path "#{Chef::Config[:file_cache_path]}/#{file_name}"
      end
      rpm_package 'zabbix-release-rhel' do
        source "#{Chef::Config[:file_cache_path]}/#{file_name}"
        notifies :update, 'execute[yum-update]', :immediately
        not_if 'dpkg -l | grep zabbix-release'
        action :install
      end

    when 'debian'
      apt_update 'apt' do
        action :nothing
      end
      file_name = node['zabbix-client']['debian']['repo_package'].split('/').last
      remote_file 'zabbix-release-debian' do
        source node['zabbix-client']['debian']['repo_package']
        path "#{Chef::Config[:file_cache_path]}/#{file_name}"
      end
      dpkg_package 'zabbix-release-debian' do
        source "#{Chef::Config[:file_cache_path]}/#{file_name}"
        notifies :update, 'apt_update[apt]', :immediately
        not_if 'dpkg -l | grep zabbix-release'
        action :install
      end
    end

    package 'zabbix-agent' do
      action :install
    end

    directory node['zabbix-client']['include_dir']

    # Install configuration
    template '/etc/zabbix/zabbix_agentd.conf' do
      source 'zabbix_agentd.conf.erb'
      owner 'root'
      group 'root'
      mode '644'
      notifies :restart, 'service[zabbix-agent]', :delayed
    end

    # Define zabbix_agentd service
    service 'zabbix-agent' do
      supports :status => true, :start => true, :stop => true, :restart => true
      action [:enable, :start]
    end

    directory node['zabbix-client']['log_dir'] do
      owner 'zabbix'
      group 'zabbix'
      mode '0755'
      recursive true
      action :create
      notifies :restart, 'service[zabbix-agent]', :delayed
    end
  end

  new_resource.updated_by_last_action(true)
end
