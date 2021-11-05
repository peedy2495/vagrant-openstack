#!/bin/bash

openstack user create --domain default --project service --password servicepassword octavia
openstack role add --project service --user octavia admin
openstack service create --name octavia --description "OpenStack LBaaS" load-balancer

export octavia_api="$LOADBALANCER_IP"
openstack endpoint create --region RegionOne load-balancer public http://$octavia_api:9876
openstack endpoint create --region RegionOne load-balancer internal http://$octavia_api:9876
openstack endpoint create --region RegionOne load-balancer admin http://$octavia_api:9876

ReplVar ADMPWD $ASSETS/octavia/octavia.sql
mysql --user=root < $ASSETS/octavia/octavia.sql