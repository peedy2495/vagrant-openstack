#!/bin/bash

#load static variables 
source /tmp/assets/global.rb
#load aggregated variables
source /tmp/assets/global.sh

HOST_IP=$(hostname -I | cut -d: -f2 | awk '{print $2}')

# include toolboxes(functions)
source /tmp/assets/tbx_configs.sh
source /tmp/assets/tbx_network.sh

# get passwords for OpenStack environment 
source /tmp/assets/credentials

# prepare OpenStack repo and configure NTP
source /tmp/assets/fundamental/fundamental.sh

# nova rollout: compute
source /tmp/assets/nova-compute/nova-compute.sh

# migrate into neutron networking
source /tmp/assets/neutron/neutron-l2.sh

# cinder, prepare physical devices and rollout: volume
# IMPORTANT! define physical devices in a mapfile called [hostname].map in ./assets/cinder/mappings
# define only devicenames without path
source /tmp/assets/cinder/cinder-volume.sh

# swift rollout: account, container, object
STOR_DEV='/dev/vdf'
source /tmp/assets/swift/swift-storage.sh