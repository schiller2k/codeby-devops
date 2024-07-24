#!/bin/bash
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y openssh-server

DIR=/home/vagrant/.ssh

ssh-keygen -t ed25519 -C "test@test.com" -f $DIR/id_rsa -N ""

chown -R vagrant:vagrant $DIR

cp $DIR/id_rsa.pub /vagrant/authorized_keys

echo -e "\n192.168.56.34 server\n" >> /etc/hosts
