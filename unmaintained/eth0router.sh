#https://wiki.archlinux.org/index.php/Internet_Share
#http://forum.manjaro.org/index.php?topic=1371.0
#http://ubuntuforums.org/showthread.php?t=1146048

ip link set down dev eth0
ip addr add 192.168.0.1/24 dev eth0
ip link set up dev eth0
ip route add 255.255.255.255 dev eth0
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sysctl net.ipv4.ip_forward=1

#sudo ufw allow from any port 68 to any port 67 proto udp
#sudo ufw allow 53

#sudo ufw allow in on eth3 to any
#sudo ufw allow out on eth3 to any

#sudo ufw allow from 10.10.20.0/24
#sudo ufw allow to 10.10.20.0/24

echo 'Do not forget:'
echo 'sudo ufw allow from 192.168.0.0/24'
echo 'edit /etc/default/ufw: DEFAULT_FORWARD_POLICY="ACCEPT"'
echo 'edit /etc/dnsmasq.conf:'
echo '	interface=eth0'
echo '	expand-hosts'
echo '	dhcp-range=192.168.0.50,192.168.0.150,255.255.255.0,12h'
echo 'and finally:'
echo 'systemctl restart dnsmasq; systemctl restart ufw'
echo ''
echo 'Client config:'
echo 'ip addr add 192.168.0.55/24 dev eth0'
echo 'ip link set up dev eth0'
echo 'ip route add default via 192.168.0.1 dev eth0'