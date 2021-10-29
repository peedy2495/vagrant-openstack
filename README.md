# vagrant-openstack
Vagrant deployment of an OpenStack environment 

## !!! IMPORTANT - UNDER CONSTRUCTION !!!

This deployment is based on  
https://www.server-world.info/en/note?os=Ubuntu_20.04&p=openstack_xena  
Refer this link for usage and testing beside official OpenStack documentation.



Overview of Services:

| Node0 | Node1     | Node2      |
|--------------|-----------|------------|
| Ctrl-Node Basics |  |  |
| - MariaDB |  |  |
| - Memcached |  |  |
| - Keystone |  |  |
| - httpd |  |  |
| - RabbitMQ |  |  |
| nova-api |  |  |
| nova-compute | nova-compute | nova-compute |
| glance-api |  |  |
| neutron-server |  |  |
| l3-agent |  |  |
| l2 (vxlan) | l2 (vxlan) | l2 (vxlan) |
| neutron-metadata |  |  |
| cinder-api |  |  |
| cinder-volume | cinder-volume | cinder-volume |
| heat-api |  |  |
| barbican-api |  |  |
|  | swift-proxy |  |
| swift-account | swift-account | swift-account |
| swift-container | swift-container | swift-container |
| swift-object | swift-object | swift-object |


2Do:
- Manila
- Designate