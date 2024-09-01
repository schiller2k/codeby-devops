#!/bin/bash
sudo apt update -y
sudo apt upgrade -y

DIR=/home/vagrant/.ssh

cat /vagrant/authorized_keys >> $DIR/authorized_keys

chown -R vagrant:vagrant $DIR
chmod 600 $DIR/authorized_keys
chmod 700 $DIR

sudo systemctl restart ssh

STORE=/opt/store/mysql

sudo mkdir -p $STORE
chown -R vagrant:vagrant $STORE

