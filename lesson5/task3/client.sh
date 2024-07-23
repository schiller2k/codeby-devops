#!/bin/bash
sudo apt update -y
sudo apt upgrade -y

sudo apt install -y openvpn
cp -r /vagrant/client /etc/openvpn
#sudo openvpn /etc/openvpn/client/client.conf

