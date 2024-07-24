# Flush existing rules
sudo iptables -F
sudo iptables -X

# Set default policies
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT DROP

# Allow loopback traffic
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related Connections
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow OpenVPN traffic
sudo iptables -A INPUT -s 192.168.56.34 -p udp --sport 1194 -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.56.34 -p udp --dport 1194 -j ACCEPT

# Allow incoming SSH connection
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow all traffic through tun0
sudo iptables -A INPUT -i tun0 -j ACCEPT
sudo iptables -A OUTPUT -o tun0 -j ACCEPT

# Reject all other outgoing traffic (if not using tun0)
sudo iptables -A OUTPUT -j REJECT

