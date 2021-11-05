# vagrant-openstack
Vagrant deployment of an OpenStack environment 

## !!! IMPORTANT - UNDER CONSTRUCTION !!!

This deployment is based on  
https://www.server-world.info/en/note?os=Ubuntu_20.04&p=openstack_xena  
Refer this link for usage and testing beside official OpenStack documentation.

Repository-sources will be configured to pull all required packages from a cached nexus-proxy
For using repositories without proxy, replace assets/base/sources.list with original URLs

Outside of vagrant-provisioning e.g. on bare-metal define the real assets folder-location/mount in assets/global.rb

Overview of Services:

| Node0 | Node1     | Node2      |
|--------------|-----------|------------|
| Ctrl-Node Basics |  |  |
| - MariaDB |  |  |
| - Memcached |  |  |
| - Keystone |  |  |
| - httpd |  |  |
| - RabbitMQ |  |  |
| nova-api | nova-compute | nova-compute |
| glance-api |  |  |
| neutron-server |  |  |
| ovn-northd | ovn-controller | ovn-controller |
|  | ovn metadata agent | ovn metadata agent |
| neutron-metadata |  |  |
| cinder-api |  |  |
| cinder-volume | cinder-volume | cinder-volume |
| heat-api |  |  |
| barbican-api |  |  |
|  | swift-proxy |  |
| swift-account | swift-account | swift-account |
| swift-container | swift-container | swift-container |
| swift-object | swift-object | swift-object |
| manila-api  |  |  |
| manila-share | manila-share | manila-share |
| designate |  |  |
| octavia |  |  |
