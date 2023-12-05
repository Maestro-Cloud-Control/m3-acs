Repo for Auto Configuration Service based on Chef Infra Server v13 and Chef Infra Client v15.

Manage chef-server
```bash
rm Berksfile.lock && berks install && berks upload

knife search 'role:docker_registry_node'
knife search node "role:k8s_master"

knife node delete $(knife node list | tr -d '\r') -y
knife client delete $(knife client list | tr -d '\r') -y
```

Deploy chef-server
```bash
# use --standalone mode from certbot; only get cert

# make sure that port 80 not used !!!
# This plugin needs to bind to port 80 in order to perform domain validation, so you may need to stop your existing webserver
ss -tuln
netstat -tulpn  | grep --color :80 || apt install net-tools && netstat -tulpn | grep --color :80

# install certbot
snap install core && snap refresh core
apt-get remove certbot
snap install --classic certbot

# insure that the certbot command can be run.
ln -s /snap/bin/certbot /usr/bin/certbot

# certbot certonly --standalone --domains acs.maestro3.tools --dry-run
certbot certonly --standalone --domains ${EQDN} --register-unsafely-without-email || certbot certonly --webroot

# store here
# /etc/letsencrypt/live/chef.mdkzrnd.com/fullchain.pem
# /etc/letsencrypt/live/chef.mdkzrnd.com/privkey.pem

# auto update cert
chef-server-ctl stop
certbot renew

certbot renew --dry-run
sh -c 'printf "#!/bin/sh\nservice haproxy stop\n" > /etc/letsencrypt/renewal-hooks/pre/haproxy.sh'
sh -c 'printf "#!/bin/sh\nservice haproxy start\n" > /etc/letsencrypt/renewal-hooks/post/haproxy.sh'
chmod 755 /etc/letsencrypt/renewal-hooks/pre/haproxy.sh
chmod 755 /etc/letsencrypt/renewal-hooks/post/haproxy.sh

# ========= #
# preconfig #
# ========= #

useradd -m -s /bin/bash administrator
sudo -iu administrator
mkdir /home/administrator/.chef
# provide key to git

# ============ #
# install chef #
# ============ #

# curl https://www.opscode.com/chef/install.sh | sudo bash
curl https://packages.chef.io/files/stable/chef-server/13.2.0/ubuntu/22.04/chef-server-core_13.2.0-1_amd64.deb \
    -o chef-server-core_13.2.0-1_amd64.deb \
    && dpkg -i chef-server-core_13.2.0-1_amd64.deb
  
yes | chef-server-ctl reconfigure 

# ========= #
# conf chef #
# ========= #

# example cat /etc/opscode/chef-server.rb
# api_fqdn ""
# nginx['ssl_certificate'] = "/var/opt/opscode/nginx/ca/fullchain.pem"
# nginx['ssl_certificate_key'] = "/var/opt/opscode/nginx/ca/privkey.pem"
# nginx['ssl_protocols'] = "TLSv1.2"
# addons['install'] = false
       

cat <<EOF > /etc/opscode/chef-server.rb
api_fqdn "$FQDN"
nginx['ssl_certificate'] = "/etc/letsencrypt/live/$FQDN/fullchain.pem"
nginx['ssl_certificate_key'] = "/etc/letsencrypt/live/$FQDN/privkey.pem"
nginx['ssl_protocols'] = "TLSv1.2"
addons['install'] = false
EOF

chef-server-ctl reconfigure

chef-server-ctl org-create "${STAND_ID}" -f /home/administrator/.chef/validator.pem

# Create administrator user. It will be used for local managing.
# chef-server-ctl user-create administrator Local Admin admin@example.com -p -f /home/administrator/.chef/administrator.key
chef-server-ctl user-create $USER_NAME $USER_NAME $USER_NAME@...com -p -f /home/administrator/$USER_NAME.pem

#
chef-server-ctl org-user-add $USER_NAME --admin

# Create orchestrator user. It will be used for orchestrator app.
chef-server-ctl user-create orchestrator Orch App orch@example.com -p -f /home/administrator/.chef/orchestrator.key
chef-server-ctl org-user-add  orchestrator --admin

```

Deploy cinc-server
```bash
# useradd administrator
# mkdir -p /home/administrator/.cinc
# echo 'administrator ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers
# sudo -iu administrator

curl -L https://omnitruck.cinc.sh/install.sh | sudo bash -s -- -P cinc-server -v 15.8
cinc-server-ctl reconfigure

cat <<EOF > /etc/cinc-project/cinc-server.rb
api_fqdn "[instance fqdn name goes here]"
nginx['ssl_certificate'] = "/path/to/fullchain.pem"
nginx['ssl_certificate_key'] = "/path/to/privkey.pem"
nginx['ssl_protocols'] = "TLSv1.2"
addons['install'] = false
EOF

cinc-server-ctl org-create  "" -f /home/administrator/.chef/validator.pem
cinc-server-ctl user-create administrator Local Admin admin@example.com -p -f /home/administrator/.chef
/administrator.key
cinc-server-ctl org-user-add  administrator --admi
```