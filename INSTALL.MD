--------------------------------------------------
**Get script for install on Ubuntu 2X in venv**
--------------------------------------------------

Check if user has sudo access, if user is root skip this step:
```
sudo -v
```
If you don’t have sudo access, you will see the following output message. In the following message, <username> will be the username you have logged in as, and <host> will be the hostname or ip of your Linux system.

if client provide only password authentication you need create .ssh folder

if user is root skip this step:
```
mkdir ~/.ssh
```
Add your private and public key to the user's home folder in the .ssh folder and set permissions to 600 on the keys:
```
sudo chmod 600 ~/.ssh/id_rsa*
```
if user is root skip this step:
```
sudo chmod 700 ~/.ssh
```
if user is root skip this step, otherwise replace **$OE_USER** with system username:
```
sudo chown -R $OE_USER:$OE_USER ~/.ssh/id_rsa*
```
Add host to known_hosts to get file in non-interactive mode:
```
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
```
Replace **$TOKEN** with your token:
```
curl --header "PRIVATE-TOKEN: $TOKEN" "https://.../odoo_install_ubuntu_venv.sh/raw?ref=main" -o odoo_install_ubuntu_venv.sh
```
Make the file executable:
```
sudo chmod +x odoo_install_ubuntu_venv.sh
```
Before running the script, change the value in the installation script!!! change the value of **$OE_USER** to the username provided by the client, or replace the username with the odoo:
```
nano ./odoo_install_ubuntu_venv.sh
```
Execute the script to install Odoo:
```
sh ./odoo_install_ubuntu_venv.sh
```
--------------------------------------------------
**Manual minimal installation odoo-server on Ubuntu 2X - host installation**
--------------------------------------------------

These variables will need to be replaced with your own data in the installation commands:
- **$TOKEN** - provided token value
- **$OE_USER** - odoo if setup under root or custom user name from client
- **$OE_PORT** - 8069 or custom
- **$GEVENT_PORT** - 8072 or custom

NGINX and CERTBOT install (if need)
- **$WEBSITE_NAME** - replace with domain name (need for nginx setup)
- **$ADMIN_EMAIL** - replace with your email (need for certbot install https)

MONITORING
- **$ENABLE_MONITORING** - will install services fail2ban / node_exporter / blackbox / promtail

POSTGRESQL
- **$INSTALL_POSTGRESQL_V14** - install 14 version or default  ubuntu postgresql version

Check if user has sudo access, if user is root skip this step:
```
sudo -v
```
If you don’t have sudo access, you will see the following output message. In the following message, <username> will be the username you have logged in as, and <host> will be the hostname or ip of your Linux system.

if client provide only password authentication you need create .ssh folder if root user - skip it:
```
mkdir ~/.ssh
```
add your private and public key to user home in .ssh folder and make right 600 to keys:
```
sudo chmod 600 ~/.ssh/id_rsa*
```
if root user - skip it:
```
sudo chmod 700 ~/.ssh
```
if user is root skip next step, else:
```
sudo chown -R $OE_USER:$OE_USER ~/.ssh/id_rsa*
```
```
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
```
Replace **$TOKEN** to your token:
```
curl --header "PRIVATE-TOKEN: $TOKEN" "https://.../odoo_install_ubuntu_venv.sh/raw?ref=main" -o odoo_install_ubuntu_venv.sh
```
Make the file executable:
```
sudo chmod +x odoo_install_ubuntu_venv.sh
```
Before run script modify value in setup script!!!
```
nano ./odoo_install_ubuntu_venv.sh
```
Execute the script to install Odoo:
```
bash ./odoo_install_ubuntu_venv.sh
```
--------------------------------------------------
**Update Server**
--------------------------------------------------
```
sudo apt install software-properties-common -y
```
```
sudo add-apt-repository ppa:linuxuprising/libpng12 -y
```
```
sudo apt-get update
```
```
sudo apt-get upgrade -y
```
```
sudo apt install htop mc -y
```
--------------------------------------------------
**Set TimeZone Europe/Kyiv**
--------------------------------------------------
```
sudo timedatectl set-timezone 'Europe/Kyiv'
```
```
sudo dpkg-reconfigure --frontend noninteractive tzdata
```
--------------------------------------------------
**Install PostgreSQL Server**
--------------------------------------------------
```
sudo curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
```
```
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```
```
sudo apt-get update
```
```
sudo apt-get install postgresql-14 -y
```
--------------------------------------------------
**Install Dependencies - Remember about default python3 version dependent on linux version**
--------------------------------------------------
```
sudo apt-get install git python3 python3-pip build-essential wget python3-dev python3-venv python3-wheel python3-testresources libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libpng12-0 libjpeg-dev gdebi -y
```
```
sudo apt-get install -y --no-install-recommends fonts-noto-cjk libssl-dev python3-num2words python3-pdfminer python3-phonenumbers python3-pyldap python3-qrcode python3-slugify python3-watchdog python3-xlrd python3-xlwt
```
```
sudo -H pip3 install -r https://github.com/odoo/odoo/raw/17.0/requirements.txt
```
```
sudo apt-get install nodejs npm -y
```
--------------------------------------------------
**Install Wkhtmltopdf**
--------------------------------------------------
```
sudo wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.focal_amd64.deb
```
```
sudo gdebi --n `basename wkhtmltox_0.12.5-1.focal_amd64.deb`
```
```
sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
```
```
sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
```
```
sudo rm -f wkhtmltox_0.12.5-1.*.deb
```
--------------------------------------------------
**Install ODOO**
--------------------------------------------------
```
sudo adduser --system --quiet --shell=/bin/bash --home=/home/$OE_USER --gecos 'ODOO' --group $OE_USER
```
```
sudo adduser $OE_USER sudo
```
```
sudo mkdir /opt/odoo
```
```
sudo chown -R $OE_USER:$OE_USER /opt/odoo
```
```
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
```
```
git clone {ODOO_REPO} /opt/odoo
```
```
cd /opt/odoo
```
```
git submodule foreach -q --recursive 'branch="main"; git checkout main'
```
```
sudo pip3 install -r /opt/odoo/extra_requirements.txt
```
```
find /opt/odoo -name '.git' -exec bash -c 'git config --global --add safe.directory ${0%/.git}' {} \;
```
```
cp /opt/odoo/config/odoo.conf /opt/odoo/config/odoo-server.conf
```
```
sudo nano /opt/odoo/config/odoo-server.conf
```
change value for parameter if you need admin_passwd (password database manager) / auth_admin_passkey_password (password for login under user)

if **$OE_USER** not odoo - remove comment in db_user and add custom user name

--------------------------------------------------
**Adding ODOO as a deamon (systemd)**
--------------------------------------------------
```
cd ~
```
```
sudo touch odoo-server.service
```
```
sudo nano odoo-server.service
```
Copy and put text below:
```
[Unit]
Description=odoo-server
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=odoo-server
PermissionsStartOnly=true
User=$OE_USER
Group=$OE_USER
ExecStart=/opt/odoo/odoo-bin -c /opt/odoo/config/odoo-server.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
```
```
sudo mv ~/odoo-server.service /etc/systemd/system/odoo-server.service
```
```
sudo chmod 644 /etc/systemd/system/odoo-server.service
```
```
sudo chown root: /etc/systemd/system/odoo-server.service
```
```
sudo systemctl enable odoo-server.service
```
--------------------------------------------------
**Install Nginx if needed**
--------------------------------------------------
```
sudo apt install nginx -y
```
```
sudo touch odoo.conf
```
```
sudo nano odoo.conf
```
Copy and put text below:
```
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
```
```
sudo mv ~/odoo.conf /etc/nginx/sites-available/
```
```
sudo ln -s /etc/nginx/sites-available/odoo.conf /etc/nginx/sites-enabled/odoo.conf
```
```
sudo rm /etc/nginx/sites-enabled/default
```
```
sudo service nginx reload
```
--------------------------------------------------
**Enable ssl with certbot**
--------------------------------------------------
```
sudo apt install snapd -y
```
```
sudo snap install core; sudo snap refresh core
```
```
sudo snap install --classic certbot
```
```
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```
```
sudo certbot --nginx -d $WEBSITE_NAME --noninteractive --agree-tos --email $ADMIN_EMAIL --redirect
```
```
sudo service nginx reload
```
--------------------------------------------------
**Start Odoo**
--------------------------------------------------
```
sudo service odoo-server start
```
