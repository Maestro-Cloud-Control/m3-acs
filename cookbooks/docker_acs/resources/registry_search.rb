unified_mode true

action :update do
  unless node.run_state['datics']['docker_registry'].nil?
    node.run_state['datics']['docker_registry'].each do |host, data|
      Chef::Log.info("Found docker registy at #{host}")
      url = 'https://' + host + ':5000'
      shell = Mixlib::ShellOut.new("docker login \
        #{url} -u #{node['metadata']['docker']['registry_user']} --password-stdin", input: node['metadata']['docker']['registry_password'] )
      shell.run_command
    end
  end
end
