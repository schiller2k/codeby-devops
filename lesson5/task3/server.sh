#!/bin/bash
sudo apt update -y
sudo apt upgrade -y

sudo apt install -y openvpn easy-rsa haveged
sudo mkdir -p /etc/openvpn/easy-rsa
sudo cp -r /usr/share/easy-rsa /etc/openvpn/

sudo sed -i 's/RANDFILE/#RANDFILE/' /etc/openvpn/easy-rsa/openssl-easyrsa.cnf

tee /etc/openvpn/easy-rsa/vars &>/dev/null <<EOF
set_var EASYRSA_ALGO "ec"
set_var EASYRSA_DIGEST "sha512"
set_var EASYRSA_REQ_CN "Common Name"
set_var EASYRSA_BATCH "yes"
EOF

cd /etc/openvpn/easy-rsa/
sudo ./easyrsa init-pki
sudo ./easyrsa build-ca nopass
sudo ./easyrsa gen-dh
sudo openvpn --genkey --secret ./pki/ta.key
sudo ./easyrsa gen-crl

sudo ./easyrsa build-server-full server nopass
cp ./pki/ca.crt /etc/openvpn/ca.crt
cp ./pki/dh.pem /etc/openvpn/dh2048.pem
cp ./pki/crl.pem /etc/openvpn/crl.pem
cp ./pki/ta.key /etc/openvpn/ta.key
cp ./pki/issued/server.crt /etc/openvpn/server.crt
cp ./pki/private/server.key /etc/openvpn/server.key

zcat /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | sudo tee /etc/openvpn/server.conf
sudo sed -i 's/;push "dhcp-option DNS 208.67.222.222"/push "dhcp-option DNS 8.8.8.8"/' /etc/openvpn/server.conf
sudo sed -i 's/;push "dhcp-option DNS 208.67.220.220"/push "dhcp-option DNS 8.8.4.4"/' /etc/openvpn/server.conf

#sudo openvpn /etc/openvpn/server.conf
sudo systemctl start openvpn@server
sudo sysctl -w net.ipv4.ip_forward=1
sysctl -p

#ip -br a
sudo iptables -I FORWARD -i tun0 -o enp0s8 -j ACCEPT
sudo iptables -I FORWARD -i enp0s8 -o tun0 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

sudo ./easyrsa build-client-full client nopass
sudo mkdir -p /etc/openvpn/clients

CLIENT=/etc/openvpn/clients/client

sudo mkdir -p $CLIENT
cd $CLIENT
cp /etc/openvpn/easy-rsa/pki/ca.crt $CLIENT
cp /etc/openvpn/easy-rsa/pki/ta.key $CLIENT
cp /etc/openvpn/easy-rsa/pki/issued/client.crt $CLIENT
cp /etc/openvpn/easy-rsa/pki/private/client.key $CLIENT
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ./client.conf

sudo sed -i 's/remote my-server-1 1194/remote 192.168.56.34 1194/' ./client.conf

cp -r $CLIENT /vagrant/client

