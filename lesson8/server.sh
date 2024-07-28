#!/bin/bash
sudo apt update -y
sudo apt upgrade -y

sudo apt install -y apache2
sudo a2enmod ssl
sudo a2enmod rewrite
sudo systemctl restart apache2

sudo echo "192.168.56.34 test.local www.test.local" >> /etc/hosts

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=test.local" -addext "subjectAltName=DNS:www.test.local" -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt

sudo tee /etc/apache2/sites-available/test.local.conf &>/dev/null <<EOF
<VirtualHost *:80>
  ServerName test.local
  ServerAlias www.test.local
  Redirect permanent / https://test.local/
</VirtualHost>

<VirtualHost *:443>
  ServerName test.local
  ServerAlias www.test.local

  RewriteEngine On
  RewriteCond %{HTTP_HOST} !^www\. [NC]
  RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]

  DocumentRoot /var/www/html
  DirectoryIndex index.html

  SSLEngine on
  SSLCertificateFile /etc/ssl/certs/selfsigned.crt
  SSLCertificateKeyFile /etc/ssl/private/selfsigned.key
  
  <Directory /var/www/html>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
  </Directory>
</VirtualHost>
EOF

sudo systemctl reload apache2

cp /etc/ssl/certs/selfsigned.crt /vagrant

