# move to metadata
# default['git']['repo'] = 'https://github.com/FaztWeb/php-mysql-crud.git'
# default['git']['branch'] = 'master'

default['apache']['listen_ports'] = '81'
default['apache2']['dir'] = '/var/www/html'
default['apache2']['conf_file'] = '/etc/apache2/sites-available/apache_app.conf'

default['mysql']['host'] = 'localhost'
default['mysql']['script_create_table'] = 'CREATE TABLE IF NOT EXISTS task(id INT(11) PRIMARY KEY AUTO_INCREMENT, title VARCHAR(255) NOT NULL, description TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);'
