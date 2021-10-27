#!/bin/bash

openstack user create --domain default --project service --password $SERVPWD cinder
openstack role add --project service --user cinder admin 
openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

export controller=$CTRL_HOST_IP
openstack endpoint create --region RegionOne volumev3 public http://$controller:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://$controller:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://$controller:8776/v3/%\(tenant_id\)s

sed -i "s/ADMPWD/$ADMPWD/g" /tmp/assets/cinder/cinder.sql
mysql --user=root < /tmp/assets/cinder/cinder.sql

apt -y install cinder-api cinder-scheduler python3-cinderclient

for var in CTRL_HOST_IP HOST_IP ADMPWD SERVPWD GLANCE_IP; do
    ReplVar $var /tmp/assets/cinder/cinder.conf
done

install -v -b -m 640 -g cinder -t /etc/cinder              /tmp/assets/cinder/cinder.conf

su -s /bin/bash cinder -c "cinder-manage db sync"
systemctl restart cinder-scheduler 
systemctl enable cinder-scheduler 

echo -e  "\nexport OS_VOLUME_API_VERSION=3" >> ~/keystonerc
source ~/keystonerc
