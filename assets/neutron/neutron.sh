#!/bin/bash

## install neutron

openstack user create --domain default --project service --password $SERVPWD neutron
openstack role add --project service --user neutron admin

openstack service create --name neutron --description "OpenStack Networking service" network

openstack endpoint create --region RegionOne network public http://$controller:9696
openstack endpoint create --region RegionOne network internal http://$controller:9696
openstack endpoint create --region RegionOne network admin http://$controller:9696

# neutron: add user and database

ReplVar ADMPWD $ASSETS/neutron/neutron.sql
mysql --user=root < $ASSETS/neutron/neutron.sql

apt -y install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent python3-neutronclient

touch /etc/neutron/fwaas_driver.ini


for var in CTRL_HOST_IP SERVPWD ADMPWD; do
  ReplVar $var $ASSETS/neutron/neutron.conf
done
install -v -b -m 640 -g neutron -t /etc/neutron              $ASSETS/neutron/neutron.conf


install -v -b -m 640 -g neutron -t /etc/neutron              $ASSETS/neutron/l3_agent.ini

install -v -b -m 640 -g neutron -t /etc/neutron              $ASSETS/neutron/dhcp_agent.ini

ReplVar CTRL_HOST_IP $ASSETS/neutron/metadata_agent.ini
ReplVar ADMPWD $ASSETS/neutron/metadata_agent.ini
install -v -b -m 640 -g neutron -t /etc/neutron              $ASSETS/neutron/metadata_agent.ini

install -v -b -m 640 -g neutron -t /etc/neutron/plugins/ml2  $ASSETS/neutron/ml2_conf.ini

ReplVar HOST_IP $ASSETS/neutron/linuxbridge_agent.ini
ReplVar NETDEV $ASSETS/neutron/linuxbridge_agent.ini
install -v -b -m 640 -g neutron -t /etc/neutron/plugins/ml2  $ASSETS/neutron/linuxbridge_agent.ini

PlaceBefore '\[api\]' '# Neutron usage' /etc/nova/nova.conf
PlaceBefore '\[api\]' ' use_neutron = True' /etc/nova/nova.conf
PlaceBefore '\[api\]' ' vif_plugging_is_fatal = True' /etc/nova/nova.conf
PlaceBefore '\[api\]' ' vif_plugging_timeout = 300\n' /etc/nova/nova.conf

for var in CTRL_HOST_IP SERVPWD ADMPWD; do
  ReplVar $var $ASSETS/neutron/nova.conf.part.neutron
done
cat $ASSETS/neutron/nova.conf.part.neutron >>/etc/nova/nova.conf

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini 
su -s /bin/bash neutron -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head" 

install -v -b -m 640 -g neutron -t /etc/neutron              $ASSETS/neutron/dnsmasq-neutron.conf

for service in server l3-agent dhcp-agent metadata-agent linuxbridge-agent; do
  systemctl restart neutron-$service
  systemctl enable neutron-$service
done


systemctl restart nova-api nova-compute

# prepare neutron networking

tee -a /etc/systemd/network/${NETDEV}.network >/dev/null <<EOF 
[Match]
Name=${NETDEV}

[Network]
LinkLocalAddressing=no
IPv6AcceptRA=no
EOF

ip link set ${NETDEV} up

PlaceAfter '\[ml2_type_flat\]' 'flat_networks = physnet1\n' /etc/neutron/plugins/ml2/ml2_conf.ini
PlaceAfter '\[linux_bridge\]' "physical_interface_mappings = physnet1:'${NETDEV}'\n" /etc/neutron/plugins/ml2/linuxbridge_agent.ini

systemctl restart neutron-linuxbridge-agent

openstack router create router01

# create internal network
openstack network create private --provider-network-type vxlan

INTERNAL_NET=$(GetNetwork $INTERNAL_NET_GW $INTERNAL_NET_MASK)

# create subnet for internal network
openstack subnet create private-subnet \
  --network private \
  --subnet-range $INTERNAL_NET/$INTERNAL_NET_MASK \
  --gateway $INTERNAL_NET_GW \
  --dns-nameserver $INFRA_DNS

# set subnet to the router above
openstack router add subnet router01 private-subnet

# create external network
openstack network create \
  --provider-physical-network physnet1 \
  --provider-network-type flat \
  --external public

# create subnet for external network
INFRA_NET=$(GetNetwork $INFRA_GW $INFRA_MASK)
openstack subnet create public-subnet \
  --network public \
  --subnet-range "$INFRA_NET"/"$INFRA_MASK" \
  --allocation-pool start="$INFRA_DHCP_START",end="$INFRA_DHCP_END" \
  --gateway "$INFRA_GW" \
  --dns-nameserver "$INFRA_DNS" \
  --no-dhcp

openstack router set router01 --external-gateway public