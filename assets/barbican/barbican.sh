#!/bin/bash

openstack user create --domain default --project service --password $SERVPWD barbican
openstack role add --project service --user barbican admin

openstack service create --name barbican --description "OpenStack Key Manager" key-manager

export controller=$HOST_IP
openstack endpoint create --region RegionOne key-manager public http://$controller:9311
openstack endpoint create --region RegionOne key-manager internal http://$controller:9311
openstack endpoint create --region RegionOne key-manager admin http://$controller:9311

ReplVar ADMPWD /tmp/assets/barbican/barbican.sql
mysql --user=root < /tmp/assets/barbican/barbican.sql

apt -y install barbican-api

for var in CTRL_HOST_IP HOST_IP ADMPWD SERVPWD; do
    ReplVar $var /tmp/assets/barbican/barbican.conf
done
install -v -b -m 640 -g barbican -t /etc/barbican              /tmp/assets/barbican/barbican.conf

su -s /bin/bash barbican -c "barbican-manage db upgrade"
systemctl restart apache2