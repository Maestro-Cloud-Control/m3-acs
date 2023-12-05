property :api_fqdn, String
property :path_to_ssl_certificate, String 
property :path_to_ssl_certificate_key, String

action :configure do

  if node['metadate']['chef_epc']['domain_name'].empty?
    [
      { 'path' => "#{path_to_ssl_certificate}", 'content' => node['metadata']['chef_epc']['ssl_certificate'] },
      { 'path' => "#{path_to_ssl_certificate_key}", 'content' => node['metadata']['chef_epc']['sl_certificate_key'] },
    ].each do |file|
      file file['path'] do
        content file['content']
        mode    '0755'
        owner   'ceph'
        group   'ceph'
      end
    end
  end

  template '/etc/opscode/chef-server.rb' do
    source      'chef-server.rb.erb'
    owner       'root'
    group       'root'
    mode        '0755'
    action      :create
    variables(
      api_fqdn: new_resource.api_fqdn
      path_to_ssl_certificate: new_resource.path_to_ssl_certificate
      path_to_ssl_certificate_key: new_resource.path_to_ssl_certificate_key
    )
  end
    
  bash 'chef_server_reconfigure' do
    code <<-EOH
        chef-server-ctl reconfigure --accept-license
    EOH
    action :run
  end


  bash 'chef_server_org_create' do
    code <<-EOH
      chef-server-ctl org-create #{node['chef']['epc']['org']['name']} "#{node['chef']['epc']['org']['name']}" -f #{node['chef']['epc']['conf']['dir']}/#{node['chef']['epc']['validation']['key']['name']}.pem
      chef-server-ctl user-create #{node['chef']['epc']['user']['name']} Admin Admin #{['chef']['epc']['user']['name']}@test.com -p -f #{node['chef']['epc']['conf']['dir']}/#{['chef']['epc']['user']['name']}.pem
      chef-server-ctl org-user-add #{node['chef']['epc']['org']['name']} #{node['chef']['epc']['user']['name']} --admin
    EOH
    action :run
  end

# ??? how data bag will be created ???
# # Create orchestrator user. It will be used for orchestrator app.
# chef-server-ctl user-create orchestrator Orch App orch@example.com -p -f /home/administrator/.chef/orchestrator.key
# chef-server-ctl org-user-add orchestrator --admin

# # Upload code
# # sudo su administrator
# cd ~/epc-acs2 && berks install && berks upload && knife environment from file environments/* && knife role from file roles/*


  node.normal['chef']['epc']['conf']['status'] = 'configured'

end