name             'rds_acs'
maintainer       ''
maintainer_email ''
license          'All Rights Reserved'
description      'Installs/Configures RDB service'
version          '0.3.5'
chef_version     '>= 14.0'

depends 'mysql', '~> 11.1.0'
depends 'mariadb', '= 5.0.1'
depends 'postgresql', '= 11.6.3'
