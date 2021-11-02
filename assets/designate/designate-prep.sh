#!/bin/bash

openstack user create --domain default --project service --password servicepassword designate
openstack role add --project service --user designate admin

openstack service create --name designate --description "OpenStack DNS Service" dns

export designate_api=$INFRA_DNS
openstack endpoint create --region RegionOne dns public http://$designate_api:9001/
openstack endpoint create --region RegionOne dns internal http://$designate_api:9001/
openstack endpoint create --region RegionOne dns admin http://$designate_api:9001/

ReplVar ADMPWD /tmp/assets/designate/designate.sql
mysql --user=root < /tmp/assets/designate/designate.sql