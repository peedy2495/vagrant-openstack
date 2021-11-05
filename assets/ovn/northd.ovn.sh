#!/bin/bash

# configure neutron
openstack user create --domain default --project service --password $SERVPWD neutron
openstack role add --project service --user neutron admin

openstack service create --name neutron --description "OpenStack Networking service" network

openstack endpoint create --region RegionOne network public http://$controller:9696
openstack endpoint create --region RegionOne network internal http://$controller:9696
openstack endpoint create --region RegionOne network admin http://$controller:9696

# neutron: add user and database
ReplVar ADMPWD $ASSETS/ovn/neutron.sql
mysql --user=root < $ASSETS/ovn/neutron.sql

apt -y install neutron-server neutron-plugin-ml2 python3-neutronclient ovn-central openvswitch-switch

for var in CTRL_HOST_IP SERVPWD ADMPWD; do
  ReplVar $var $ASSETS/ovn/northd.neutron.conf
done
install -v -b -m 640 -g neutron   -T $ASSETS/ovn/northd.neutron.conf  /etc/neutron/neutron.conf

ReplVar NET_HOST_IP $ASSETS/ovn/northd.ml2_conf.ini
install -v -b -m 640 -g neutron   -T $ASSETS/ovn/northd.ml2_conf.ini  /etc/neutron/ml2_conf.ini

key=$(echo -e "\"--ovsdb-server-options='--remote=ptcp:6640:127.0.0.1'\"")
KeySet OVS_CTL_OPTS "${key}" /etc/default/openvswitch-switch

systemctl restart openvswitch-switch

ovs-vsctl add-br br-int

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
su -s /bin/bash neutron -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head"

systemctl restart ovn-central ovn-northd

ovn-nbctl set-connection ptcp:6641:$NET_HOST_IP -- set connection . inactivity_probe=60000
ovn-sbctl set-connection ptcp:6642:$NET_HOST_IP -- set connection . inactivity_probe=60000

systemctl restart neutron-server