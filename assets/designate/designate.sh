#!/bin/bash

apt -y install designate-api designate-central designate-worker designate-producer designate-mdns python3-designateclient bind9 bind9utils 

rndc-confgen -a -k designate -c /etc/bind/designate.key
chown bind:designate /etc/bind/designate.key
chmod 640 /etc/bind/designate.key

INFRA_NET=$(echo $INFRA_DNS | cut -d"." -f1-3).0
ReplVar INFRA_NET /tmp/assets/designate/named.conf.options.org
install -v -b -m 644 -o bind -t /etc/bind              /tmp/assets/designate/named.conf.options.org

systemctl restart bind9

for var in CTRL_HOST_IP HOST_IP ADMPWD SERVPWD; do
    ReplVar $var /tmp/assets/designate/designate.conf
done
install -v -b -m 640 -g designate -t /etc/designate     /tmp/assets/designate/designate.conf

su -s /bin/sh -c "designate-manage database sync" designate

systemctl restart designate-central designate-api
systemctl enable designate-central designate-api

ReplVar INFRA_NET /tmp/assets/designate/pools.yaml
install -v -b -m 640 -g designate -t /etc/designate     /tmp/assets/designate/pools.yaml

su -s /bin/sh -c "designate-manage pool update" designate 

systemctl restart designate-worker designate-producer designate-mdns
systemctl enable designate-worker designate-producer designate-mdns
