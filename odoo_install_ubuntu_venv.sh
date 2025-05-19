#!/bin/bash
################################################################################
# Make a new file:
# sudo nano odoo_install_ubuntu_venv.sh
# Place this content in it and then make the file executable:
# sudo chmod +x odoo_install_ubuntu_venv.sh
# Execute the script to install Odoo:
# ./odoo_install_ubuntu_venv
################################################################################

# if there is only a root user on the server, then it is correct to create a separate user, add the password to the sudo group, and then perform all actions under it,
# when setting up under root, you can immediately specify this user in the OE_USER variable, for this user, during the installation process, access keys to the code repository will also be added
# when the setup is already under the user, it must be specified in the OE_USER variable
OE_USER="odoo"
OE_HOME="/home/${OE_USER}"
# The default port where this Odoo instance will run under (provided you use the command -c in the terminal)
# Set to true if you want to install it, false if you don't need it or have it already installed.
INSTALL_WKHTMLTOPDF="True"
# Set the default Odoo port (you still have to use -c /opt/odoo/config/odoo.conf for example to use this.)
OE_PORT="8069"
# Choose the Odoo version which you want to install. For example: 17.0.
# IMPORTANT! This script contains extra libraries that are specifically needed for Odoo 17.0
OE_VERSION="16.0"
# Installs postgreSQL V14 instead of defaults (e.g V12 for Ubuntu 20/22) - this improves performance
INSTALL_POSTGRESQL_V14="True"
# Set this to True if you want to install Nginx!
INSTALL_NGINX="True"
# Set the superadmin password - if GENERATE_RANDOM_PASSWORD is set to "True" we will automatically generate a random password, otherwise we use this one
OE_SUPERADMIN="" # SET PASSWORD!!!
# Set to "True" to generate a random password, "False" to use the variable in OE_SUPERADMIN
GENERATE_RANDOM_PASSWORD="True"
OE_CONFIG="odoo-server"
# Set the website name
WEBSITE_NAME="_" # SET DOMAIN!!!
# Set the default Odoo gevent port (you still have to use -c /opt/odoo/config/odoo.conf for example to use this.)
GEVENT_PORT="8072"
# Set to "True" to install certbot and have ssl enabled, "False" to use http
ENABLE_SSL="True"
# Provide Email to register ssl certificate
ADMIN_EMAIL="odoo@example.com" # email
# Provide Password for Auth Admin Password module
OE_OAUTHADMIN="" # SET PASSWORD!!!
# Set to "True" to install monitoring tools
ENABLE_MONITORING="False" # May be true
# Provide name for hostname in monitoring tools and change 127.0.0.1 in clients sections to related monitoring ip-addressMONITORING_HOST="odooserver"
MONITORING_HOST="odooserver"
# Repo
ODOO_REPO="" # SET REPO!!!

##
###  WKHTMLTOPDF download links
## === Ubuntu Trusty x64 & x32 === (for other distributions please replace these two links,
## in order to have correct version of wkhtmltopdf installed, for a danger note refer to
## https://github.com/odoo/odoo/wiki/Wkhtmltopdf ):
## https://www.odoo.com/documentation/17.0/administration/install.html

# Check if the operating system is Ubuntu 22.04
if [ $(lsb_release -r -s) = "22.04" ] || [ $(lsb_release -r -s) = "24.04" ]; then
    WKHTMLTOX_X64="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb"
    WKHTMLTOX_X32="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb"
    #No Same link works for both 64 and 32-bit on Ubuntu 22.04
else
    # For older versions of Ubuntu
    WKHTMLTOX_X64="https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.$(lsb_release -c -s)_amd64.deb"
    WKHTMLTOX_X32="https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.$(lsb_release -c -s)_i386.deb"
fi

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
# install packages for contabo hosting
# sudo apt install software-properties-common -y
# libpng12-0 dependency for wkhtmltopdf
# sudo add-apt-repository ppa:linuxuprising/libpng12 -y
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install mc -y
sudo apt-get install libpq-dev -y
sudo locale-gen uk_UA.UTF-8
sudo update-locale

echo -e "\n---- Set TimeZone Europe/Kyiv ----"
sudo timedatectl set-timezone 'Europe/Kyiv'
sudo dpkg-reconfigure --frontend noninteractive tzdata

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
if [ $INSTALL_POSTGRESQL_V14 = "True" ]; then
    echo -e "\n---- Installing postgreSQL V14 due to the user it's choise ----"
    sudo curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    sudo apt-get update
    sudo apt-get install postgresql-14 -y
else
    echo -e "\n---- Installing the default postgreSQL version based on Linux version ----"
    sudo apt-get install postgresql postgresql-server-dev-all -y
fi

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n--- Installing Python 3 + pip3 --"
sudo apt-get install python3 python3-pip -y
# For other versions Odoo - Check
sudo apt-get install git python3-cffi build-essential wget python3-dev python3-venv python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libpng-dev libjpeg-dev gdebi -y

#echo -e "\n---- Install python packages/requirements ----"
#sudo -H pip3 install -r https://github.com/odoo/odoo/raw/${OE_VERSION}/requirements.txt

echo -e "\n---- Installing nodeJS NPM and rtlcss for LTR support ----"
sudo apt-get install nodejs npm -y
sudo npm install -g rtlcss # Not usual

#--------------------------------------------------
# Install Wkhtmltopdf if needed
#--------------------------------------------------
if [ $INSTALL_WKHTMLTOPDF = "True" ]; then
  echo -e "\n---- Install wkhtml and place shortcuts on correct place for ODOO 17 ----"
  #pick up correct one from x64 & x32 versions:
  if [ "`getconf LONG_BIT`" = "64" ];then
      _url=$WKHTMLTOX_X64
  else
      _url=$WKHTMLTOX_X32
  fi
  sudo wget $_url

  if [ $(lsb_release -r -s) = "22.04" ] || [ $(lsb_release -r -s) = "24.04" ]; then
    # Ubuntu 22.04 / 24.04 LTS
    sudo gdebi --n `basename $_url`
  else
      # For older versions of Ubuntu
    sudo gdebi --n `basename $_url`
  fi

  sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
  sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
else
  echo "Wkhtmltopdf isn't installed due to the choice of the user!"
fi

echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER
#The user should also be added to the sudo'ers group.
sudo adduser $OE_USER sudo

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server ===="
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
sudo git clone ${ODOO_REPO} /opt/odoo

sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git

cd /home/${OE_USER}

sudo -u ${OE_USER} bash -c "curl https://pyenv.run | bash"

sudo -u ${OE_USER} bash -c 'touch ~/.bashrc'
sudo -u ${OE_USER} bash -c 'echo "export PYENV_ROOT=\$HOME/.pyenv" >> ~/.bashrc'
sudo -u ${OE_USER} bash -c 'echo "export PATH=\$PYENV_ROOT/bin:\$PATH" >> ~/.bashrc'
sudo -u ${OE_USER} bash -c 'echo -e "if command -v pyenv 1>/dev/null 2>&1; then\n eval \"\$(pyenv init -)\"\nfi" >> ~/.bashrc'
sudo -u ${OE_USER} bash -c 'echo "eval \"\$(pyenv virtualenv-init -)\"" >> ~/.bashrc'

sudo chown -R ${OE_USER}:${OE_USER} /opt/odoo
cd /opt/odoo
sudo -u ${OE_USER} bash -lc 'source ~/.bashrc && pyenv install 3.10.13'
sudo -u ${OE_USER} bash -lc 'source ~/.bashrc && pyenv virtualenv 3.10.13 odoo-3.10'
sudo -u ${OE_USER} bash -lc 'source ~/.bashrc && pyenv local 3.10.13/envs/odoo-3.10'

sudo -u ${OE_USER} bash -lc "source ~/.bashrc && pyenv activate odoo-3.10 && pip install --upgrade pip"
sudo -u ${OE_USER} bash -lc "source ~/.bashrc && pyenv activate odoo-3.10 && pip install -r /opt/odoo/extra_requirements.txt"
sudo -u ${OE_USER} bash -lc "source ~/.bashrc && pyenv activate odoo-3.10 && pip install -e ." # for click-odoo-contrib
sudo -u ${OE_USER} bash -lc "source ~/.bashrc && pyenv activate odoo-3.10 && pip install click-odoo-contrib"

sudo find /opt/odoo -name '.git' -exec bash -c 'git config --global --add safe.directory ${0%/.git}' {} \;

echo -e "* Create server config file"
sudo cp /opt/odoo/config/odoo.conf /opt/odoo/config/$OE_CONFIG.conf
DBUSER_FULL="db_user = ${OE_USER}"
ADMIN_PASSWORD_FULL="admin_passwd = ${OE_SUPERADMIN}"
OAUTH_ADMIN_PASSWORD_FULL="auth_admin_passkey_password = ${OE_OAUTHADMIN}"
if [ $GENERATE_RANDOM_PASSWORD = "True" ]; then
    echo -e "* Generating random admin password"
    OE_SUPERADMIN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    ADMIN_PASSWORD_FULL="admin_passwd = ${OE_SUPERADMIN}"
    sed -i -e "s/admin_passwd.*/$ADMIN_PASSWORD_FULL/g" /opt/odoo/config/$OE_CONFIG.conf
fi
sed -i -e "s/admin_passwd.*/$ADMIN_PASSWORD_FULL/g" /opt/odoo/config/$OE_CONFIG.conf
if [ $GENERATE_RANDOM_PASSWORD = "True" ]; then
    echo -e "* Generating random auth admin password"
    OE_OAUTHADMIN=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
    OAUTH_ADMIN_PASSWORD_FULL="auth_admin_passkey_password = ${OE_OAUTHADMIN}"
    sed -i -e "s/auth_admin_passkey_password.*/$OAUTH_ADMIN_PASSWORD_FULL/g" /opt/odoo/config/$OE_CONFIG.conf
fi
sed -i -e "s/auth_admin_passkey_password.*/$OAUTH_ADMIN_PASSWORD_FULL/g" /opt/odoo/config/$OE_CONFIG.conf
sed -i -e "s/.*db_user.*/$DBUSER_FULL/g" /opt/odoo/config/$OE_CONFIG.conf

echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER /opt/odoo

#--------------------------------------------------
# Create logrotate ODOO log file
#--------------------------------------------------
echo -e "\n---- Create Logrotate ----"
sudo touch /opt/odoo/$OE_CONFIG.log
sudo cp /opt/odoo/$OE_CONFIG.log /var/log/odoo/$OE_CONFIG.log
sudo chown $OE_USER:$OE_USER /opt/odoo/$OE_CONFIG.log
sudo ln -sf /var/log/odoo/$OE_CONFIG.log /opt/odoo/$OE_CONFIG.log
sudo cat <<EOF > /etc/logrotate.d/odoo
/var/log/odoo/$OE_CONFIG.log
{
    daily
    rotate 30
    missingok
    notifempty
    compress
    delaycompress
    create 0644 odoo odoo
}
EOF

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------
cd ~
echo -e "* Create daemon service file"
cat <<EOF > ~/$OE_CONFIG
[Unit]
Description=$OE_CONFIG
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=$OE_CONFIG
PermissionsStartOnly=true
User=$OE_USER
Group=$OE_USER
ExecStart=/home/odoo/.pyenv/versions/odoo-3.10/bin/python /opt/odoo/odoo-bin -c /opt/odoo/config/$OE_CONFIG.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF

echo -e "* Security SystemD File"
sudo mv ~/$OE_CONFIG /etc/systemd/system/$OE_CONFIG.service
sudo chmod 755 /etc/systemd/system/$OE_CONFIG.service
sudo chown root: /etc/systemd/system/$OE_CONFIG.service

echo -e "* Start ODOO on Startup"
sudo systemctl enable $OE_CONFIG.service

#--------------------------------------------------
# Install Nginx if needed
#--------------------------------------------------
if [ $INSTALL_NGINX = "True" ]; then
  echo -e "\n---- Installing and setting up Nginx ----"
  sudo apt install nginx -y
  cat <<EOF > ~/odoo.conf
upstream odoo {
  server 127.0.0.1:$OE_PORT;
}
upstream odoochat {
  server 127.0.0.1:$GEVENT_PORT;
}
map \$http_upgrade \$connection_upgrade {
  default upgrade;
  ''      close;
}

server {
  listen 80;

  # set proper server name after domain set
  server_name $WEBSITE_NAME;

  #   odoo    log files
  access_log  /var/log/nginx/$OE_USER-access.log;
  error_log   /var/log/nginx/$OE_USER-error.log;

  #   increase    proxy   buffer  size
  proxy_buffers   16  64k;
  proxy_buffer_size   128k;

  proxy_read_timeout 720s;
  proxy_connect_timeout 720s;
  proxy_send_timeout 720s;

  #   force   timeouts    if  the backend dies
  proxy_next_upstream error   timeout invalid_header  http_500    http_502
  http_503;

  types {
  text/less less;
  text/scss scss;
  }

  #   enable  data    compression
  gzip    on;
  gzip_min_length 1100;
  gzip_buffers    4   32k;
  gzip_types  text/css text/less text/plain text/xml application/xml application/json application/javascript application/pdf image/jpeg image/png;
  gzip_vary   on;
  client_header_buffer_size 4k;
  large_client_header_buffers 4 64k;
  client_max_body_size 0;

  # Redirect requests to odoo backend server
  location / {
    # Add Headers for odoo proxy mode
    proxy_set_header X-Forwarded-Host \$http_host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_redirect off;
    proxy_pass http://odoo;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
#    proxy_cookie_flags session_id samesite=lax secure;  # requires nginx 1.19.8
  }

  # Redirect websocket requests to odoo gevent port
  location /websocket {
    proxy_pass http://odoochat;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;
    proxy_set_header X-Forwarded-Host \$http_host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Real-IP \$remote_addr;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
#    proxy_cookie_flags session_id samesite=lax secure;  # requires nginx 1.19.8
  }

  location ~* .(js|css|png|jpg|jpeg|gif|ico)$ {
    expires 30d;
    proxy_pass http://odoo;
    add_header Cache-Control "public, no-transform";
  }

  # cache some static data in memory for 60mins.
  location ~ /[a-zA-Z0-9_-]*/static/ {
    proxy_cache_valid 200 302 60m;
    proxy_cache_valid 404 1m;
    proxy_buffering on;
    expires 864000;
    proxy_pass http://odoo;
  }

#  location /web/database/manager {
#    proxy_pass http://odoo;
#    satisfy all;
#    auth_basic "Restricted Content";
#    auth_basic_user_file /etc/nginx/.htpasswd;
#  }

  location @odoo {
    # copy-paste the content of the / location block
  }

  # Serve static files right away
  location ~ ^/[^/]+/static/.+$ {
    # root and try_files both depend on your addons paths
    proxy_pass http://odoo;
    root /opt/odoo/odoo;
    try_files /opt/odoo/odoo/addons\$uri /opt/odoo/extra_addons/custom_addons\$uri @odoo;
    expires 24h;
#    add_header Content-Security-Policy \$content_type_csp;
  }

  location /web/filestore {
    proxy_pass http://odoo;
    internal;
    alias /opt/odoo/.local/filestore;
  }
}
EOF

  sudo mv ~/odoo.conf /etc/nginx/sites-available/
  sudo ln -s /etc/nginx/sites-available/odoo.conf /etc/nginx/sites-enabled/odoo.conf
  sudo rm /etc/nginx/sites-enabled/default
  sudo service nginx reload
  echo "Done! The Nginx server is up and running. Configuration can be found at /etc/nginx/sites-available/odoo"
else
  echo "Nginx isn't installed due to choice of the user!"
fi

#--------------------------------------------------
# Enable ssl with certbot
#--------------------------------------------------

if [ $INSTALL_NGINX = "True" ] && [ $ENABLE_SSL = "True" ] && [ $ADMIN_EMAIL != "odoo@example.com" ]  && [ $WEBSITE_NAME != "_" ];then
  sudo apt-get update -y
  sudo apt install snapd -y
  sudo snap install core; snap refresh core
  sudo snap install --classic certbot
  sudo apt-get install python3-certbot-nginx -y
  sudo certbot --nginx -d $WEBSITE_NAME --noninteractive --agree-tos --email $ADMIN_EMAIL --redirect
  sudo service nginx reload
  echo "SSL/HTTPS is enabled!"
else
  echo "SSL/HTTPS isn't enabled due to choice of the user or because of a misconfiguration!"
  if $ADMIN_EMAIL = "odoo@example.com";then
    echo "Certbot does not support registering odoo@example.com. You should use real e-mail address."
  fi
  if $WEBSITE_NAME = "_";then
    echo "Website name is set as _. Cannot obtain SSL Certificate for _. You should use real website address."
  fi
fi

#--------------------------------------------------
# Install Fail2Ban Service
#--------------------------------------------------
sudo apt-get install fail2ban -y
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

#--------------------------------------------------
# Enable Monitoring Tools: Node Explorer
#--------------------------------------------------
#if [ $ENABLE_MONITORING = "True" ]; then
#  echo -e "* Install Node Explorer"
#  curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
#  tar -xvf node_exporter-1.8.1.linux-amd64.tar.gz
#  sudo mv node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/
#  sudo useradd -rs /bin/false node_exporter
#
#  echo -e "\n---- Create Node Exporter Service ----"
#  sudo touch /etc/systemd/system/node_exporter.service
#sudo cat <<EOF > /etc/systemd/system/node_exporter.service
#[Unit]
#Description=Node Exporter
#After=network.target
#
#[Service]
#User=node_exporter
#Group=node_exporter
#Type=simple
#ExecStart=/usr/local/bin/node_exporter
#
#[Install]
#WantedBy=multi-user.target
#EOF
#
#  sudo systemctl daemon-reload
#  sudo systemctl start node_exporter
#
#  sudo systemctl enable node_exporter
#
#fi
#echo "-----------------------------------------------------------"

#--------------------------------------------------
# Enable Monitoring Tools: Promtail  # Not Now
#--------------------------------------------------

#if [ $ENABLE_MONITORING = "True" ]; then
#  echo -e "\n---- Install Promtail----"
#  curl -O -L "https://github.com/grafana/loki/releases/download/v2.9.8/promtail-linux-amd64.zip"
#  sudo unzip "promtail-linux-amd64.zip"
#  sudo chmod a+x "promtail-linux-amd64"
#
#  sudo mv promtail-linux-amd64 /usr/local/bin/promtail
#  sudo rm promtail-linux-amd64.zip
#
#  sudo mkdir -p /etc/promtail /etc/promtail/logs
#  sudo touch /etc/promtail/promtail-config.yaml
#  sudo cat <<EOF > /etc/promtail/promtail-config.yaml
#server:
#  http_listen_port: 9080
#  grpc_listen_port: 0
#
#positions:
#  filename: /tmp/positions.yaml
#
#clients:
#  - url: 'http://127.0.0.1:3100/loki/api/v1/push'
#
#scrape_configs:
#  - job_name: system
#    static_configs:
#      - targets:
#          - localhost
#        labels:
#          job: varlogs
#          hostname: $MONITORING_HOST
#          __path__: /var/log/*log
#
#  - job_name: nginx
#    static_configs:
#      - targets:
#          - localhost
#        labels:
#          job: nginx
#          hostname: $MONITORING_HOST
#          __path__: /var/log/nginx/*log
#
#  - job_name: postgresql
#    static_configs:
#      - targets:
#          - localhost
#        labels:
#          job: postgresql
#          hostname: $MONITORING_HOST
#          __path__: /var/log/postgresql/*log
#
#  - job_name: odoo
#    static_configs:
#      - targets:
#          - localhost
#        labels:
#          job: odoo
#          hostname: $MONITORING_HOST
#          __path__: /var/log/odoo/*log
#
#  - job_name: apt
#    static_configs:
#      - targets:
#          - localhost
#        labels:
#          job: apt
#          hostname: $MONITORING_HOST
#          __path__: /var/log/apt/*log
#
#  - job_name: letsencrypt
#    static_configs:
#      - targets:
#          - localhost
#        labels:
#          job: letsencrypt
#          hostmaster: $MONITORING_HOST
#          __path__: /var/log/letsencrypt/*log
#EOF
#
#  sudo useradd --system promtail
#  sudo usermod -a -G adm promtail
#
#  sudo touch /etc/systemd/system/promtail.service
#  sudo cat <<EOF > /etc/systemd/system/promtail.service
#[Unit]
#Description=Promtail service
#After=network.target
#
#[Service]
#Type=simple
#User=promtail
#ExecStart=/usr/local/bin/promtail -config.expand-env=true -config.file /etc/promtail/promtail-config.yaml
#Restart=on-failure
#RestartSec=20
#StandardOutput=append:/etc/promtail/logs/promtail.log
#StandardError=append:/etc/promtail/logs/promtail.log
#
#[Install]
#WantedBy=multi-user.target
#EOF
#
#  sudo systemctl daemon-reload
#  sudo service promtail start
#  sudo service promtail status
#
#fi
#echo "-----------------------------------------------------------"

#--------------------------------------------------
# Enable Monitoring Tools: Blackbox  # Not Now
#--------------------------------------------------

#if [ $INSTALL_NGINX = "True" ] && [ $ENABLE_MONITORING = "True" ];then
#  echo -e "* Install Blackbox Explorer"
#  wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.25.0/blackbox_exporter-0.25.0.linux-amd64.tar.gz
#  tar -xvf blackbox_exporter-0.25.0.linux-amd64.tar.gz
#  sudo mkdir /etc/blackbox
#
#  sudo cp blackbox_exporter-0.25.0.linux-amd64/blackbox_exporter /usr/local/bin/
#  sudo cp blackbox_exporter-0.25.0.linux-amd64/blackbox.yml /etc/blackbox/
#
#  sudo touch /etc/blackbox/blackbox.yml
#sudo cat <<EOF > /etc/blackbox/blackbox.yml
#modules:
#  http_prometheus:
#    prober: http
#    timeout: 60s
#    http:
#      method: GET
#      valid_http_versions: ["HTTP/1.1", "HTTP/2"]
#      fail_if_ssl: false
#      fail_if_not_ssl: false
#EOF
#  sudo useradd --no-create-home blackbox
#  sudo chown blackbox:blackbox /usr/local/bin/blackbox_exporter
#  sudo chown -R blackbox:blackbox /etc/blackbox/*
#
#  sudo touch /etc/systemd/system/blackbox.service
#sudo cat <<EOF > /etc/systemd/system/blackbox.service
#[Unit]
#Description=Blackbox
#Wants=network-online.target
#After=network-online.target
#
#[Service]
#User=blackbox
#Group=blackbox
#Type=simple
#ExecStart=/usr/local/bin/blackbox_exporter --config.file=/etc/blackbox/blackbox.yml --web.listen-address="0.0.0.0:9115"
#
#[Install]
#WantedBy=multi-user.target
#EOF
#
#  sudo systemctl daemon-reload
#  sudo systemctl enable blackbox
#  sudo systemctl start blackbox
#
#fi
echo "-----------------------------------------------------------"

echo -e "\n---- Starting Odoo Service----"
sudo su root -c "sudo service $OE_CONFIG start"
echo "-----------------------------------------------------------"
echo "Done! The Odoo server is up and running. Specifications:"
echo "Port: $OE_PORT"
echo "User service: $OE_USER"
echo "Configuraton file location: /opt/odoo/config/$OE_CONFIG.conf"
echo "User PostgreSQL: $OE_USER"
echo "Code location: $OE_USER"
echo "Password superadmin (database): $OE_SUPERADMIN"
echo "Password oauth admin (login different user): $OE_OAUTHADMIN"
echo "Log file: /opt/odoo/odoo-server.log"
echo "Venv path: /opt/odoo; Venv user: odoo"
echo "Odoo core modules path: /opt/odoo/odoo"
echo "Odoo custom modules path: /opt/odoo/extra_addons"
echo "Start Odoo service: sudo service $OE_CONFIG start"
echo "Stop Odoo service: sudo service $OE_CONFIG stop"
echo "Restart Odoo service: sudo service $OE_CONFIG restart"
if [ $INSTALL_NGINX = "True" ]; then
  echo "Nginx configuration file: /etc/nginx/sites-available/odoo.conf"
fi
if [ $ENABLE_MONITORING = "True" ]; then
  echo "Node Explorer restart service: sudo systemctl restart node_exporter"
  echo "Promtail restart service: sudo systemctl restart promtail"
fi
if [ $INSTALL_NGINX = "True" ] && [ $ENABLE_MONITORING = "True" ]; then
  echo "Blackbox Explorer restart service: sudo systemctl restart blackbox"
fi
echo "-----------------------------------------------------------"
