#!/bin/bash

apt -y install neutron-common neutron-plugin-ml2 neutron-ovn-metadata-agent ovn-host openvswitch-switch 

for var in CTRL_HOST_IP SERVPWD ADMPWD; do
  ReplVar $var $ASSETS/ovn/compute.neutron.conf
done
install -v -b -m 640 -g neutron -T /etc/neutron/neutron.conf     $ASSETS/ovn/compute.neutron.conf

ReplVar NET_HOST_IP $ASSETS/neutron/compute.ml2_conf.ini
install -v -b -m 640 -g neutron -T /etc/neutron/ml2_conf.ini     $ASSETS/ovn/compute.ml2_conf.ini

PlaceAfter '\[DEFAULT\]' "metadata_proxy_shared_secret = metadata_secret" /etc/neutron/neutron_ovn_metadata_agent.ini
PlaceAfter '\[DEFAULT\]' "nova_metadata_host = $CTRL_HOST_IP" /etc/neutron/neutron_ovn_metadata_agent.ini
KeySet ovsdb_connection 'tcp:127.0.0.1:6640' /etc/neutron/neutron_ovn_metadata_agent.ini

ReplVar NET_HOST_IP $ASSETS/ovn/compute.part.neutron_ovn_metadata_agent.ini
cat $ASSETS/ovn/compute.part.neutron_ovn_metadata_agent.ini >>/etc/neutron/neutron_ovn_metadata_agent.ini

key=$(echo -e "\"--ovsdb-server-options='--remote=ptcp:6640:127.0.0.1'\"")
KeySet OVS_CTL_OPTS "${key}" /etc/default/openvswitch-switch

PlaceAfter '\[DEFAULT\]' 'use_neutron = True' /etc/nova/nova.conf
PlaceAfter '\[DEFAULT\]' 'vif_plugging_is_fatal = True' /etc/nova/nova.conf
PlaceAfter '\[DEFAULT\]' 'vif_plugging_timeout = 300' /etc/nova/nova.conf

systemctl restart openvswitch-switch ovn-controller ovn-host

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
systemctl restart neutron-ovn-metadata-agent
systemctl restart nova-compute

ovs-vsctl set open . external-ids:ovn-remote=tcp:$NET_HOST_IP:6642
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
ovs-vsctl set open . external-ids:ovn-encap-ip=$HOST_IP