require 'net/http'
require 'digest'

module Eporch2
  module Helpers
    def http_get(url:, params: {}, limit: 2, attempts: 5, delay: 10)
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      Chef::Log.debug("Trying to download from #{url}")
      uri = URI(url)
      params.empty? || (uri.query = URI.encode_www_form(params))
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 5
      http.read_timeout = 5
      res = Net::HTTP.get_response(uri)
      Chef::Log.debug("#{res.message} #{res.code}")
      case res
      when Net::HTTPSuccess
        return res.body
      when Net::HTTPRedirection
        location = res['location']
        Chef::Log.debug("Received redirect to #{location}")
        return http_get(url: location, limit: limit - 1)
      else
        Chef::Log.warn("Unable to get from #{url} with parameters: #{params}.\nServer returned #{res.code}")
        raise IOError, 'Max retries exceeded' if attempts <= 1
        Chef::Log.debug("Sleeping for #{delay} sec")
        sleep(delay)
        Chef::Log.info('Retying...')
        return http_get(url: url, params: params, attempts: attempts - 1)
      end
    end

    def validate_string(string, sha256)
      (Digest::SHA256.hexdigest string) == sha256
    end

    def gpg_decrypt(message)
      environment = platform_family?('windows') ? nil : { GNUPGHOME: node['gpg']['home'] }
      shell = Mixlib::ShellOut.new("#{node['gpg']['gpg_binary']} -d -u #{node['gpg']['eporchsec']['name']}", input: message, environment: environment)
      shell.run_command
      shell.error! || shell.stdout
    end
  end
end
