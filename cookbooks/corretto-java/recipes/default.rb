#
# Cookbook:: corretto-java
# Recipe:: default
#
# Copyright:: 2020, All Rights Reserved.

# download aws corretto

java_version = node['corretto-java']['version']
node.default['java']['jdk_version'] = java_version

remote_file "download_aws_corretto_#{java_version}" do
  source        node['corretto-java'][java_version]['download_url']
  path          "#{node['corretto-java']['tmp_folder']}/#{node['corretto-java'][java_version]['package_name']}"
  mode          0644
  checksum      node['corretto-java'][java_version]['package_checksum']
  not_if        { File.exist? "#{node['corretto-java']['tmp_folder']}/#{node['corretto-java'][java_version]['package_name']}" }
end

# install aws corretto
case node['platform']
when 'debian', 'ubuntu'
  package 'java-common' do
    action :install
  end
  dpkg_package node['corretto-java'][java_version]['package_name'] do
    source        "#{node['corretto-java']['tmp_folder']}/#{node['corretto-java'][java_version]['package_name']}"
    action        :install
  end
when 'redhat', 'centos', 'fedora', 'oracle'
  rpm_package node['corretto-java'][java_version]['package_name'] do
    source        "#{node['corretto-java']['tmp_folder']}/#{node['corretto-java'][java_version]['package_name']}"
    action        :install
  end
when 'windows'
  windows_package node['corretto-java'][java_version]['package_name'] do
    action         :install
    installer_type :msi
    source         "#{node['corretto-java']['tmp_folder']}\\#{node['corretto-java'][java_version]['package_name']}"
  end

  windows_path '%JAVA_HOME%\\bin' do
    action :add
  end
end