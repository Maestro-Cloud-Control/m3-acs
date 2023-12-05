default['mongodb']['package_version'] = '4.4.0'

default['mongodb']['config']['mongod']['net']['bindIp'] = '0.0.0.0'
default['mongodb']['config']['mongod']['replication']['replSetName'] ='MyCluster'
default['mongodb']['config']['mongod']['security']['keyFile'] = '/var/lib/mongodb/keyfile.txt'
default['mongodb']['config']['auth'] = true

override['mongodb']['authentication']['password'] = lazy { node['metadata']['mongodb']['mongodb_user_password'] }

node.override['mongodb']['admin'] = {
  'username' => 'admin',
  'password' => lazy { node['metadata']['mongodb']['mongodb_user_password'] },
  'roles' => %w(userAdminAnyDatabase dbAdminAnyDatabase clusterAdmin),
  'database' => 'admin',
}

default['mongodb']['cluster_name'] = 'MyCluster'

default['mongodb']['key_file_content'] = <<-EOF
luH8PoVZe76kFuqhHQ14hNXcb3++23OgY4ylTuT0f06FgoT3i4j7sh+PeQQqWoNf
dbHVhKUfBnrXQdwe6dvCmNAKJHZt7PxHVml9yxy00FSzGoKwgVILYKCUj2eZUSSB
7b3db8zGWTRdZpafcV/GwefF1WkechEMwLd2uSuqKunuE4rHTC1TN1pSJ9FgaCrd
aiSmB1aMTpDnnyBa1vMcFVjuMAsFuKC84NRM02unWXjThV8zGp0XZtoYhcaVs3Wm
sZ5meUUcgcjUPmzLGfwWGCZd3YL6xeEvQwnS/bEl//1LpEyHwSK5T9lVL58XRO0W
tC+sFjh29yumeG+WqG5LPVpChTsvwu89PMJdODUSjbJ/xTQ0EqkXGT3ZuHWj6jFx
KGbX7MQDSfDnxz2zwcTFmljtwz0Db4yXgdinMs96/Vp2V1DIbjamHJQ9VHChDVJ9
GmnjpqF9Y9h2O7DqlKcggDHiyzPB6nqXoB2P8h9Sa0MLqjEJxEFDh0E/EDJh/QTQ
H5Nocv5x5KOSJEGSDx7BHF1ZMQ7VraxAp2RIUCA5eBwHYwaNsTd/30w6p4GB4FgM
tFrzOid5rEf9qwLYJ01XI1rdgMEp1WDM0qWWOKTpD/WiGKDrTgE9znpcNkS4X2vJ
kc0LOn8LUqahJdqDCu74wSU3v/2QnOCZPffDbAjIyCI5mKoNeoB1a/Pd3OaRhbge
9gJcovq0JUxKME8tSUwD4H4skKXV55ugd9i2VTNaQMZQawPVl6N2n/gGA1J81GVT
qp+eZrWgIyblvxXN1T9yZgOGJGuRw7YY5lq8Kfo0jvKUjfLFQMl2RJAfNRSLdBy2
QcFf0Oy0vOUiuhmWQtbdqIOcBHlzI5dEQ0g1Qa4qIrdEEPXl22fJ8ebu+n34ZMhp
sdq4N4phNsiwEjxauGejNmxPgGVAY6FUdxyWUdmjGaWSl5VSes5XsBvkZ1G6jK6j
NhQ2FRPjStcB26mQQYPBdgPj0+hz/YzYTzojoiu+L6kU7OlQWz+NmF4qtVYVNZvK
EOF

