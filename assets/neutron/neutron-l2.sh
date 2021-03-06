#! /bin/bash

#deployment of network layer2-agent to every compute-relevant node 

apt -y install neutron-common neutron-plugin-ml2 neutron-linuxbridge-agent 

for var in CTRL_HOST_IP SERVPWD ADMPWD; do
  ReplVar $var $ASSETS/neutron/neutron-l2.conf
done
install -v -b -m 640 -g neutron -T $ASSETS/neutron/neutron-l2.conf  /etc/neutron/neutron.conf

install -v -b -m 640 -g neutron -t /etc/neutron/plugins/ml2         $ASSETS/neutron/ml2_conf.ini

ReplVar HOST_IP $ASSETS/neutron/linuxbridge_agent.ini
KeyDisable physical_interface_mappings $ASSETS/neutron/linuxbridge_agent.ini
install -v -b -m 640 -g neutron -t /etc/neutron/plugins/ml2  $ASSETS/neutron/linuxbridge_agent.ini

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
systemctl restart neutron-linuxbridge-agent
systemctl enable neutron-linuxbridge-agent