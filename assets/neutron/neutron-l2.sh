#! /bin/bash

#deployment of network layer2-agent to every compute-relevant node 

apt -y install neutron-common neutron-plugin-ml2 neutron-linuxbridge-agent 

for var in CTRL_HOST_IP SERVPWD ADMPWD; do
  ReplVar $var /tmp/assets/neutron/neutron-l2.conf
done
install -v -m 640 -g neutron -T /etc/neutron/neutron.conf /tmp/assets/neutron/neutron-l2.conf

install -v -m 640 -g neutron -t /etc/neutron/plugins/ml2  /tmp/assets/neutron/ml2_conf.ini

ReplVar HOST_IP /tmp/assets/neutron/linuxbridge_agent.ini
KeyDisable physical_interface_mappings /tmp/assets/neutron/linuxbridge_agent.ini
install -v -m 640 -g neutron -t /etc/neutron/plugins/ml2  /tmp/assets/neutron/linuxbridge_agent.ini


PlaceBefore '\[api\]' '# Neutron usage' /etc/nova/nova.conf
PlaceBefore '\[api\]' ' use_neutron = True' /etc/nova/nova.conf
PlaceBefore '\[api\]' ' vif_plugging_is_fatal = True' /etc/nova/nova.conf
PlaceBefore '\[api\]' ' vif_plugging_timeout = 300\n' /etc/nova/nova.conf

for var in CTRL_HOST_IP SERVPWD ADMPWD; do
  ReplVar $var /tmp/assets/neutron/nova.conf.part.neutron
done
cat /tmp/assets/neutron/nova.conf.part.neutron >>/etc/nova/nova.conf

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
systemctl restart nova-compute neutron-linuxbridge-agent
systemctl enable neutron-linuxbridge-agent