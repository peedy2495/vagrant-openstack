#!/bin/bash

apt -y install octavia-api octavia-health-manager octavia-housekeeping octavia-worker python3-ovn-octavia-provider

# get default working directory
dwd="$PWD"

cd $ASSETS/gitrepos/octavia/bin
./create_dual_intermediate_CA.sh

# return to default working directory
cd $dwd

mkdir -p /etc/octavia/certs/private

cp -p $ASSETS/gitrepos/octavia/bin/dual_ca/etc/octavia/certs/server_ca.cert.pem /etc/octavia/certs/
cp -p $ASSETS/gitrepos/octavia/bin/dual_ca/etc/octavia/certs/server_ca-chain.cert.pem /etc/octavia/certs/
cp -p $ASSETS/gitrepos/octavia/bin/dual_ca/etc/octavia/certs/server_ca.key.pem /etc/octavia/certs/private/
cp -p $ASSETS/gitrepos/octavia/bin/dual_ca/etc/octavia/certs/client_ca.cert.pem /etc/octavia/certs/
cp -p $ASSETS/gitrepos/octavia/bin/dual_ca/etc/octavia/certs/client.cert-and-key.pem /etc/octavia/certs/private/
chown -R octavia /etc/octavia/certs

for var in CTRL_HOST_IP HOST_IP ADMPWD SERVPWD; do
    ReplVar $var $ASSETS/octavia/octavia.conf
done
install -v -b -m 640 -g octavia -t /etc/octavia     $ASSETS/octavia/octavia.conf

install -v -b -m 640 -g octavia -t /etc/octavia     $ASSETS/octavia/policy.yaml

su -s /bin/bash octavia -c "octavia-db-manage --config-file /etc/octavia/octavia.conf upgrade head"

systemctl restart octavia-api octavia-health-manager octavia-housekeeping octavia-worker