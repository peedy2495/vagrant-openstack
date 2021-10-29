#!/bin/bash

openstack user create --domain default --project service --password servicepassword swift
openstack role add --project service --user swift admin

openstack service create --name swift --description "OpenStack Object Storage" object-store

export swift_proxy=$HOST_IP
openstack endpoint create --region RegionOne object-store public http://$swift_proxy:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne object-store internal http://$swift_proxy:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne object-store admin http://$swift_proxy:8080/v1