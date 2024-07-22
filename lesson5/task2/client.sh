#!/bin/bash
sudo apt update -y
sudo apt upgrade -y

DIR=/home/vagrant/.ssh

cp /vagrant/authorized_keys $DIR/authorized_keys

chown -R vagrant:vagrant $DIR
chmod 600 $DIR/authorized_keys
chmod 700 $DIR

sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
echo "AllowUsers vagrant@192.168.56.34" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart ssh

