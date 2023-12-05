default['corretto-java']['version'] = '8'
default['corretto-java']['javahome'] = ''

default['corretto-java']['8']['download_url'] = value_for_platform_family(
  'rhel' => 'https://d3pxv6yz143wms.cloudfront.net/8.232.09.1/java-1.8.0-amazon-corretto-devel-1.8.0_232.b09-1.x86_64.rpm',
  'amazon' => 'https://d3pxv6yz143wms.cloudfront.net/8.232.09.1/java-1.8.0-amazon-corretto-devel-1.8.0_232.b09-1.x86_64.rpm',
  'debian' => 'https://d3pxv6yz143wms.cloudfront.net/8.232.09.1/java-1.8.0-amazon-corretto-jdk_8.232.09-1_amd64.deb',
  'windows' => 'https://d3pxv6yz143wms.cloudfront.net/8.232.09.1/amazon-corretto-8.232.09.1-windows-x64.msi'
)
default['corretto-java']['8']['package_checksum'] = value_for_platform_family(
  'rhel' => 'e33fb508894e9728cea20d9da375e3ea57f6a05a6e1dfef4aa39e0528600d894',
  'amazon' => 'e33fb508894e9728cea20d9da375e3ea57f6a05a6e1dfef4aa39e0528600d894',
  'debian' => '6d6e520555e32f5de6f1d5944560096b46658ee8383bb28f718f688d1d41e76e',
  'windows' => 'ee43f6a800d82c63ba0aa2acba55ca58659ba8cfb46c2c61ceed9ba4a5c6e618'
)
default['corretto-java']['8']['package_name'] = value_for_platform_family(
  'amazon' => 'java-1.8.0-amazon-corretto-devel-1.8.0_232.b09-1.x86_64.rpm',
  'rhel' => 'java-1.8.0-amazon-corretto-devel-1.8.0_232.b09-1.x86_64.rpm',
  'debian' => 'java-1.8.0-amazon-corretto-jdk_8.232.09-1_amd64.deb',
  'windows' => 'amazon-corretto-8.232.09.1-windows-x64.msi'
)
default['corretto-java']['11']['download_url'] = value_for_platform_family(
  'amazon' => 'https://d3pxv6yz143wms.cloudfront.net/11.0.4.11.1/java-11-amazon-corretto-devel-11.0.4.11-1.x86_64.rpm',
  'rhel' => 'https://d3pxv6yz143wms.cloudfront.net/11.0.4.11.1/java-11-amazon-corretto-devel-11.0.4.11-1.x86_64.rpm',
  'debian' => 'https://d3pxv6yz143wms.cloudfront.net/11.0.4.11.1/java-11-amazon-corretto-jdk_11.0.4.11-1_amd64.deb',
  'windows' => 'https://corretto.aws/downloads/latest/amazon-corretto-11-x64-windows-jdk.msi'
)
default['corretto-java']['11']['package_checksum'] = value_for_platform_family(
  'amazon' => 'c6a31650bb2cf5f7248d74f19e258db645cc7433c27b0ae3287170144f232e0d',
  'rhel' => 'c6a31650bb2cf5f7248d74f19e258db645cc7433c27b0ae3287170144f232e0d',
  'debian' => 'f47c77f8f9ee5a80804765236c11dc749d351d3b8f57186c6e6b58a6c4019d3e',
  'windows' => '82919a51b21453a79c68d9a5fda651f4c1bdd330f7778e3074ea32b72bca80ac'
)
default['corretto-java']['11']['package_name'] = value_for_platform_family(
  'amazon' => 'java-11-amazon-corretto-devel-11.0.4.11-1.x86_64.rpm',
  'rhel' => 'java-11-amazon-corretto-devel-11.0.4.11-1.x86_64.rpm',
  'debian' => 'java-11-amazon-corretto-jdk_11.0.4.11-1_amd64.deb',
  'windows' => 'amazon-corretto-11.0.6.10.1-1-windows-x64.msi'
)
default['corretto-java']['tmp_folder'] = value_for_platform_family(
  %w(rhel debian amazon) => '/tmp',
  'windows' => 'C:\Windows\Temp'
)
