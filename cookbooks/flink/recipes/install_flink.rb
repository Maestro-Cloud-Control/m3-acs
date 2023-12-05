# Update all available packages

apt_update 'update_all' do
  ignore_failure true
  action :update
end

# Install Java

apt_package 'openjdk-11-jdk' do
  action :install
end

# Download specified version of Flink binary

remote_file '/opt/flink.tgz' do
  source "https://dlcdn.apache.org/flink/flink-#{node['flink']['version']}/flink-#{node['flink']['version']}-bin-scala_2.12.tgz"
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Unzip archive

execute 'extract_tar' do
  command <<-EOL
    tar xzvf /opt/flink.tgz
    ln -s /opt/flink-#{node['flink']['version']}/bin/flink /usr/local/bin/flink
  EOL
  cwd '/opt'
  only_if { ::File.exist?('/opt/flink.tgz') }
  not_if  { ::File.exist?('/usr/local/bin/flink') }
end

# Configure Rest&Web service to listen connections on node's public ip

ruby_block 'replace localhost to node ip' do
  block do
    fe = Chef::Util::FileEdit.new("/opt/flink-#{node['flink']['version']}/conf/flink-conf.yaml")
    fe.search_file_replace('rest.bind-address: localhost', 'rest.bind-address: 0.0.0.0')
    fe.write_file
  end
end

# Start flink cluster

execute 'start_flink_cluster' do
  command "bash /opt/flink-#{node['flink']['version']}/bin/start-cluster.sh"
end
