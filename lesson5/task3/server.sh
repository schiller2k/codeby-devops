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
#sudo ./easyrsa gen-crl
#sudo ./easyrsa gen-req server nopass
#sudo ./easyrsa sign-req server serverspace

sudo ./easyrsa build-server-full server nopass

cp ./pki/ca.crt ./pki/ta.key ./pki/issued/server.crt ./pki/private/server.key /etc/openvpn/server
cp ./pki/dh.pem /etc/openvpn/server/dh2048.pem

zcat /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | sudo tee /etc/openvpn/server/server.conf
sudo sed -i 's/;push "redirect-gateway def1 bypass-dhcp"/push "redirect-gateway def1 bypass-dhcp"/' /etc/openvpn/server/server.conf
sudo sed -i 's/;push "dhcp-option DNS 208.67.222.222"/push "dhcp-option DNS 8.8.8.8"/' /etc/openvpn/server/server.conf
sudo sed -i 's/;push "dhcp-option DNS 208.67.220.220"/push "dhcp-option DNS 8.8.4.4"/' /etc/openvpn/server/server.conf
sudo sed -i 's#ca ca.crt#ca /etc/openvpn/server/ca.crt#' /etc/openvpn/server/server.conf
sudo sed -i 's#cert server.crt#cert /etc/openvpn/server/server.crt#' /etc/openvpn/server/server.conf
sudo sed -i 's#dh dh2048.pem#dh /etc/openvpn/server/dh2048.pem#' /etc/openvpn/server/server.conf
sudo sed -i 's#key server.key#key /etc/openvpn/server/server.key#' /etc/openvpn/server/server.conf
sudo sed -i 's#tls-auth ta.key 0#tls-auth /etc/openvpn/server/ta.key 0#' /etc/openvpn/server/server.conf
sudo sed -i 's#;comp-lzo#comp-lzo#' /etc/openvpn/server/server.conf
sudo sed -i 's#^;log#log#' /etc/openvpn/server/server.conf
sudo ln -s /etc/openvpn/server/server.conf /etc/openvpn/server.conf

sudo systemctl enable openvpn@server
sudo systemctl start openvpn@server
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -p

#ip -br a
sudo iptables -I FORWARD -i tun0 -o enp0s8 -j ACCEPT
sudo iptables -I FORWARD -i enp0s8 -o tun0 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

sudo ./easyrsa build-client-full client nopass
sudo mkdir -p /etc/openvpn/clients

CLIENT=/etc/openvpn/client

cd /etc/openvpn/easy-rsa/pki
cp ca.crt ta.key ./issued/client.crt ./private/client.key $CLIENT
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf $CLIENT/client.conf

sudo sed -i 's/remote my-server-1 1194/remote 192.168.56.34 1194/' $CLIENT/client.conf
sudo sed -i 's/#comp-lzo/comp-lzo/' $CLIENT/client.conf

cp -r $CLIENT /vagrant

