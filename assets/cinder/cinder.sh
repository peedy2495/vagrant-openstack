#!/bin/bash

# wait for nova api
WaitForHost $CTRL_HOST_IP 5000 tcp 'keystone@'

openstack user create --domain default --project service --password $SERVPWD cinder
openstack role add --project service --user cinder admin 
openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

export controller=$CINDER_IP
openstack endpoint create --region RegionOne volumev3 public http://$controller:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://$controller:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://$controller:8776/v3/%\(tenant_id\)s

ReplVar ADMPWD $ASSETS/cinder/cinder.sql
mysql --user=root < $ASSETS/cinder/cinder.sql

apt -y install cinder-api cinder-scheduler python3-cinderclient

for var in CTRL_HOST_IP HOST_IP ADMPWD SERVPWD GLANCE_IP; do
    ReplVar $var $ASSETS/cinder/cinder.conf
done

install -v -b -m 640 -g cinder -t /etc/cinder              $ASSETS/cinder/cinder.conf

su -s /bin/bash cinder -c "cinder-manage db sync"
systemctl restart cinder-scheduler 
systemctl enable cinder-scheduler 

echo -e  "\nexport OS_VOLUME_API_VERSION=3" >> ~/keystonerc
source ~/keystonerc
