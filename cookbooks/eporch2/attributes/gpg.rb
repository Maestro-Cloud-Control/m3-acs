case node['os']
when 'linux'
  default['gpg']['gpg_binary'] = 'gpg'
  default['gpg']['home'] = '/root/.gnupg/'
when 'windows'
  default['gpg']['base_dir'] = node['eporch2']['config_dir'] + '\\gpg'
  default['gpg']['gpg_binary'] = node['gpg']['base_dir'] + '\\gpg2.exe'
  default['gpg']['package']['url'] = '/windows/gpg_binary.zip'
  default['gpg']['package']['hash'] = '57ffa42aca46298fd9c577257ee925f147b023b7b7c826d5b18d7641e731ed30'
end

default['gpg']['eporchsec']['url'] = '/tools/eporchsec.gpg'
default['gpg']['eporchsec']['hash'] = '761737916b87cb7e667a0e78d0d5d1f584f0967495c3f5380cbc3e8f41addeb0'
default['gpg']['eporchsec']['name'] = 'orchconfig'
