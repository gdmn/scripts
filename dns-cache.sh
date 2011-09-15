#! /bin/bash

#sudo cp -f /media/Home/dmn/Projects/resolv.freenet.io.conf /etc/resolv.conf
cat /etc/resolv.conf | grep -v 127.0.0.1  | cat > /tmp/resolv.conf
echo 'nameserver 127.0.0.1' | sudo tee /etc/resolv.conf
cat /tmp/resolv.conf | sudo tee -a /etc/resolv.conf
rm -f /tmp/resolv.conf
#ssh dmn@atom -p 11322 -t sudo dnsmasq -d -C /etc/dnsmasq.freenet.io.conf

cat > /tmp/dnsmasq.conf << EOF
cache-size=500
address=/me/127.0.0.1
address=/freenet.io/127.0.0.1
EOF

sudo dnsmasq -d -C /tmp/dnsmasq.conf
