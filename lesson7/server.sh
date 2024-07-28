#!/bin/bash
sudo apt update -y
sudo apt upgrade -y

sudo apt install -y nginx apache2
sudo systemctl enable nginx;

echo '' > /etc/apache2/ports.conf
sudo rm -rf /etc/apache2/sites-enabled/*
sudo rm -rf /etc/nginx/sites-enabled/*

sudo systemctl start apache2
sudo systemctl start nginx;

sudo mkdir -p /opt/apache/www
sudo mkdir -p /opt/nginx/www

sudo tee /opt/apache/www/test.html &>/dev/null <<EOF
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Apache</title>
</head>
<body>
    <h1>Apache</h1>
</body>
</html>
EOF

sudo tee /opt/nginx/www/test.html &>/dev/null <<EOF
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Nginx</title>
</head>
<body>
    <h1>Nginx</h1>
</body>
</html>
EOF

sudo chown -R www-data:www-data /opt/nginx
sudo chown -R www-data:www-data /opt/apache

sudo find /opt/apache -type d -exec chmod 0755 {} \;
sudo find /opt/apache -type f -exec chmod 0644 {} \;
sudo find /opt/nginx -type d -exec chmod 0755 {} \;
sudo find /opt/nginx -type f -exec chmod 0644 {} \;

sudo tee /etc/nginx/sites-available/my &>/dev/null <<EOF
server {
  listen 8085;
  root /opt/nginx/www;
  server_name _;
  index test.html;
  
  location / {
    try_files \$uri \$uri/ =404;
  } 
}
EOF

sudo ln -s /etc/nginx/sites-available/my /etc/nginx/sites-enabled/;
sudo systemctl reload nginx;

sudo tee /etc/apache2/sites-available/my.conf &>/dev/null <<EOF
Listen 8084

<VirtualHost *:8084>
  DocumentRoot /opt/apache/www
  DirectoryIndex test.html
  
  <Directory /opt/apache/www>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
  </Directory>
</VirtualHost>
EOF

sudo ln -s /etc/apache2/sites-available/my.conf /etc/apache2/sites-enabled/;
sudo systemctl reload apache2

