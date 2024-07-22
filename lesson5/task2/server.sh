#!/bin/bash
sudo apt update -y
sudo apt upgrade -y

sudo apt install -y iptables
sudo iptables -A INPUT -p icmp -j DROP

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get -y install iptables-persistent
sudo iptables-save > /etc/iptables/rules.v4

sudo apt install -y openssh-server

DIR=/home/vagrant/.ssh

ssh-keygen -t ed25519 -C "test@test.com" -f $DIR/id_rsa -N ""

chown -R vagrant:vagrant $DIR

cp $DIR/id_rsa.pub /vagrant/authorized_keys

echo -e "\n192.168.56.33 client\n" >> /etc/hosts
