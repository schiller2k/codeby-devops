#!/bin/bash
sudo apt update -y
sudo apt upgrade -y

sudo apt install -y openvpn screen iptables
cp -r /vagrant/client /etc/openvpn

sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -p

