source /tmp/assets/cfgtools.sh

## install neutron

openstack user create --domain default --project service --password $SERVPWD neutron
openstack role add --project service --user neutron admin

openstack service create --name neutron --description "OpenStack Networking service" network

openstack endpoint create --region RegionOne network public http://$controller:9696
openstack endpoint create --region RegionOne network internal http://$controller:9696
openstack endpoint create --region RegionOne network admin http://$controller:9696

# neutron: add user and database

sed -i "s/ADMPWD/$ADMPWD/g" /tmp/assets/neutron/neutron.sql
mysql --user=root < /tmp/assets/neutron/neutron.sql

apt -y install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent python3-neutronclient

touch /etc/neutron/fwaas_driver.ini

ReplVar CTRL_HOST_IP /tmp/assets/neutron/neutron.conf
ReplVar SERVPWD /tmp/assets/neutron/neutron.conf
ReplVar ADMPWD /tmp/assets/neutron/neutron.conf
install -v -m 640 -g neutron -t /etc/neutron              /tmp/assets/neutron/neutron.conf
#sed -i "s/CTRL_HOST_IP/$CTRL_HOST_IP/g" /etc/neutron/neutron.conf
#sed -i "s/SERVPWD/$SERVPWD/g" /etc/neutron/neutron.conf
#sed -i "s/ADMPWD/$ADMPWD/g" /etc/neutron/neutron.conf


install -v -m 640 -g neutron -t /etc/neutron              /tmp/assets/neutron/l3_agent.ini

install -v -m 640 -g neutron -t /etc/neutron              /tmp/assets/neutron/dhcp_agent.ini

ReplVar CTRL_HOST_IP /tmp/assets/neutron/metadata_agent.ini
ReplVar ADMPWD /tmp/assets/neutron/metadata_agent.ini
install -v -m 640 -g neutron -t /etc/neutron              /tmp/assets/neutron/metadata_agent.ini
#sed -i "s/CTRL_HOST_IP/$CTRL_HOST_IP/g" /etc/neutron/metadata_agent.ini
#sed -i "s/ADMPWD/$ADMPWD/g" /etc/neutron/metadata_agent.ini

install -v -m 640 -g neutron -t /etc/neutron/plugins/ml2  /tmp/assets/neutron/ml2_conf.ini

ReplVar CTRL_HOST_IP /tmp/assets/neutron/linuxbridge_agent.ini
install -v -m 640 -g neutron -t /etc/neutron/plugins/ml2  /tmp/assets/neutron/linuxbridge_agent.ini
#sed -i "s/CTRL_HOST_IP/$CTRL_HOST_IP/g" /etc/neutron/plugins/ml2/linuxbridge_agent.ini

PlaceBefore '\[api\]' '# Neutron usage' /etc/nova/nova.conf
PlaceBefore '\[api\]' ' use_neutron = True' /etc/nova/nova.conf
PlaceBefore '\[api\]' ' vif_plugging_is_fatal = True' /etc/nova/nova.conf
PlaceBefore '\[api\]' ' vif_plugging_timeout = 300\n' /etc/nova/nova.conf
#sed -i '/\[api\]/i # Neutron usage' /etc/nova/nova.conf
#sed -i '/\[api\]/i use_neutron = True' /etc/nova/nova.conf
#sed -i '/\[api\]/i vif_plugging_is_fatal = True' /etc/nova/nova.conf
#sed -i '/\[api\]/i vif_plugging_timeout = 300\n' /etc/nova/nova.conf

ReplVar CTRL_HOST_IP /etc/nova/nova.conf
ReplVar SERVPWD /etc/nova/nova.conf
ReplVar ADMPWD /etc/nova/nova.conf
cat /tmp/assets/neutron/nova.conf.part.neutron >>/etc/nova/nova.conf
#sed -i "s/CTRL_HOST_IP/$CTRL_HOST_IP/g" /etc/nova/nova.conf
#sed -i "s/SERVPWD/$SERVPWD/g" /etc/nova/nova.conf
#sed -i "s/ADMPWD/$ADMPWD/g" /etc/nova/nova.conf

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini 
su -s /bin/bash neutron -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head" 

for service in server l3-agent dhcp-agent metadata-agent linuxbridge-agent; do
  systemctl restart neutron-$service
  systemctl enable neutron-$service
done

systemctl restart nova-api nova-compute

# prepare neutron networking

echo <<EOF >>/etc/systemd/network/${NETDEV}.network
[Match]
Name=${NETDEV}

[Network]
LinkLocalAddressing=no
IPv6AcceptRA=no
EOF

ip link set ${NETDEV} up

PlaceAfter '\[ml2_type_flat\]' 'flat_networks = physnet1\n' /etc/neutron/plugins/ml2/ml2_conf.ini
PlaceAfter '\[linux_bridge\]' "physical_interface_mappings = physnet1:'${NETDEV}'\n" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
#sed -i '/\[ml2_type_flat\]/aflat_networks = physnet1\n' /etc/neutron/plugins/ml2/ml2_conf.ini
#sed -i '/\[linux_bridge\]/aphysical_interface_mappings = physnet1:'${NETDEV}'\n' /etc/neutron/plugins/ml2/linuxbridge_agent.ini

systemctl restart neutron-linuxbridge-agent

#create virtual network

projectID=$(openstack project list | grep service | awk '{print $2}')

openstack network create --project $projectID \
  --share \
  --provider-network-type flat \
  --provider-physical-network physnet1 sharednet1

INFRA_NET=$(echo $INFRA_GW | cut -d"." -f1-3).0

openstack subnet create subnet1 \
  --network sharednet1 \
  --project $projectID \
  --subnet-range $INFRA_NET/$INFRA_MASK \
  --allocation-pool start=$INFRA_DCHP_START,end=$INFRA_DHCP_END \
  --gateway $INFRA_GW --dns-nameserver $INFRA_DNS 