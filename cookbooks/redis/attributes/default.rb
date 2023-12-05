override['redisio']['default_settings'] = {
  'requirepass'                => lazy { node['metadata']['redis']['password'] },
  'masterauth'                 => lazy { node['metadata']['redis']['password'] },
  'address'                    => '0.0.0.0',
}