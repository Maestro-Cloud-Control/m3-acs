#
# Cookbook:: eporch2
# Recipe:: gpg
#
# Copyright:: 2019, All Rights Reserved.

if platform_family?('windows')
  remote_file "#{node['eporch2']['config_dir']}\\gpg_bin.zip" do
    source node['metadata']['common']['storage_url'] + node['gpg']['package']['url'] + "?name=#{node['name']}"
    checksum node['gpg']['package']['hash']
    notifies :extract, 'archive_file[gpg_bin.zip]', :immediately
    backup false
    not_if do
      ::File.exist?(node['gpg']['base_dir'])
    end
    action :create
  end

  archive_file 'gpg_bin.zip' do
    overwrite true
    destination node['eporch2']['config_dir']
    path "#{node['eporch2']['config_dir']}\\gpg_bin.zip"
    action :nothing
  end

  file "#{node['eporch2']['config_dir']}\\gpg_bin.zip" do
    action :delete
    backup false
  end
end

Chef::Resource::RubyBlock.send(:include, Eporch2::Helpers)

ruby_block 'Set GPG' do
  block do
    gpgkey = http_get(url: node['metadata']['common']['storage_url'] + node['gpg']['eporchsec']['url'], params: { name: node['name'] })
    raise 'gpg sha mismatch!' unless validate_string(gpgkey, node['gpg']['eporchsec']['hash'])
    environment = platform_family?('windows') ? nil : { GNUPGHOME: node['gpg']['home'] }
    shell = Mixlib::ShellOut.new("#{node['gpg']['gpg_binary']} --import -", input: gpgkey, environment: environment)
    shell.run_command
  end
  action :run
  not_if do
    shell = Mixlib::ShellOut.new("#{node['gpg']['gpg_binary']} -k")
    shell.run_command
    shell.stdout.include? node['gpg']['eporchsec']['name']
  end
  ignore_failure true
end.run_action(:run)
