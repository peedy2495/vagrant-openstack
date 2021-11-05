#!/bin/bash

openstack user create --domain default --project service --password servicepassword manila
openstack role add --project service --user manila admin
openstack service create --name manilav2 --description "OpenStack Shared Filesystem V2" sharev2

export controller=$SHARE_IP
openstack endpoint create --region RegionOne sharev2 public http://$controller:8786/v2
openstack endpoint create --region RegionOne sharev2 internal http://$controller:8786/v2
openstack endpoint create --region RegionOne sharev2 admin http://$controller:8786/v2

ReplVar ADMPWD $ASSETS/manila/manila.sql
mysql --user=root < $ASSETS/manila/manila.sql

export DEBIAN_FRONTEND=noninteractive
apt -y install manila-api manila-scheduler python3-manilaclient

for var in CTRL_HOST_IP HOST_IP ADMPWD SERVPWD; do
    ReplVar $var $ASSETS/manila/manila.conf
done
install -v -b -m 640 -g manila -t /etc/manila              $ASSETS/manila/manila.conf

install -v -b -m 640 -g manila -t /etc/manila              /usr/lib/python3/dist-packages/manila/tests/policy.yaml

systemctl restart manila-api manila-scheduler
systemctl enable manila-api manila-scheduler