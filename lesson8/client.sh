#!/bin/bash
sudo apt update -y
sudo apt upgrade -y

sudo echo "192.168.56.34 test.local www.test.local" >> /etc/hosts

sudo cp /vagrant/selfsigned.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

