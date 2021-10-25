#!/bin/bash

openstack user create --domain default --project service --password $SERVPWD cinder
openstack role add --project service --user cinder admin 
openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

export controller=$CTRL_HOST_IP
openstack endpoint create --region RegionOne volumev3 public http://$controller:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://$controller:8776/v3/%\(tenant_id\)
openstack endpoint create --region RegionOne volumev3 admin http://$controller:8776/v3/%\(tenant_id\)s

sed -i "s/ADMPWD/$ADMPWD/g" /tmp/assets/cinder/cinder.sql
mysql --user=root < /tmp/assets/cinder/cinder.sql

apt -y install cinder-api cinder-scheduler python3-cinderclient

ReplVar HOST_IP /tmp/assets/cinder/cinder.conf.org
ReplVar CTRL_HOST_IP /tmp/assets/cinder/cinder.conf.org
ReplVar ADMPWD /tmp/assets/cinder/cinder.conf.org
ReplVar SERVPWD /tmp/assets/cinder/cinder.conf.org
install -v -m 640 -g cinder -t /etc/cinder              /tmp/assets/cinder/cinder.conf.org

su -s /bin/bash cinder -c "cinder-manage db sync"
systemctl restart cinder-scheduler 
systemctl enable cinder-scheduler 

echo "export OS_VOLUME_API_VERSION=3" >> ~/keystonerc
source ~/keystonerc
