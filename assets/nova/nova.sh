## install nova

openstack user create --domain default --project service --password $SERVPWD nova 
openstack role add --project service --user nova admin

openstack user create --domain default --project service --password $SERVPWD placement
openstack role add --project service --user placement admin 

openstack service create --name nova --description "OpenStack Compute service" compute
openstack service create --name placement --description "OpenStack Compute Placement service" placement 

openstack endpoint create --region RegionOne compute public http://$controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://$controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://$controller:8774/v2.1/%\(tenant_id\)s 
openstack endpoint create --region RegionOne placement public http://$controller:8778 
openstack endpoint create --region RegionOne placement internal http://$controller:8778 
openstack endpoint create --region RegionOne placement admin http://$controller:8778

# nova: add user and database

sed -i "s/ADMPWD/$ADMPWD/g" /tmp/assets/nova/nova.sql
mysql --user=root < /tmp/assets/nova/nova.sql

apt -y install nova-api nova-conductor nova-scheduler nova-novncproxy placement-api python3-novaclient 

for var in CTRL_HOST_IP SERVPWD ADMPWD; do
  ReplVar $var /tmp/assets/nova/nova.conf
done
install -v -m 640 -g nova -t /etc/nova /tmp/assets/nova/nova.conf

for var in CTRL_HOST_IP SERVPWD ADMPWD; do
  ReplVar $var /tmp/assets/nova/placement.conf
done
install -v -m 640 -g placement -t /etc/placement /tmp/assets/nova/placement.conf

su -s /bin/bash placement -c "placement-manage db sync" 
su -s /bin/bash nova -c "nova-manage api_db sync"
su -s /bin/bash nova -c "nova-manage cell_v2 map_cell0" 
su -s /bin/bash nova -c "nova-manage db sync"
su -s /bin/bash nova -c "nova-manage cell_v2 create_cell --name cell1"

systemctl restart apache2 

for service in api conductor scheduler; do
  systemctl restart nova-$service
done

apt -y install nova-compute nova-compute-kvm

systemctl restart nova-compute nova-novncproxy

su -s /bin/bash nova -c "nova-manage cell_v2 discover_hosts"