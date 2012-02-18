#! /bin/bash

#sudo cp -f /media/Home/dmn/Projects/resolv.freenet.io.conf /etc/resolv.conf

S="\nnameserver"

# local dns
cat /etc/resolv.conf | grep 'nameserver' | grep -v 127.0.0.1  | cat > /tmp/resolv.conf

# lanet: 87.99.33.5 87.99.33.159 87.99.33.160

# list of dns (http://code.google.com/p/namebench/)
echo -e "$S 194.204.152.34 $S 212.87.0.71 $S 87.99.33.160 $S 217.17.34.10 " \
	> /tmp/resolv.conf

echo 'nameserver 127.0.0.1' | sudo tee /etc/resolv.conf
cat /tmp/resolv.conf | sudo tee -a /etc/resolv.conf
rm -f /tmp/resolv.conf
#ssh dmn@atom -p 11322 -t sudo dnsmasq -d -C /etc/dnsmasq.freenet.io.conf

cat > /tmp/dnsmasq.conf << EOF
cache-size=500
address=/me/127.0.0.1
address=/freenet.io/127.0.0.1
address=/nomiddy.pl/127.0.0.1
log-queries
EOF

sudo /etc/rc.d/dnsmasq stop
sudo killall dnsmasq

sudo dnsmasq -d -C /tmp/dnsmasq.conf
