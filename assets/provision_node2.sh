#!/bin/bash

# get initial asset-path fom hypervisor
ASSETS=$1

#load static variables 
source $ASSETS/global.rb
#load aggregated variables
source $ASSETS/global.sh

HOST_IP=$(hostname -I | cut -d: -f2 | awk '{print $2}')

# include toolboxes(functions)
source $ASSETS/gitrepos/shell-toolz/toolz_configs.sh
source $ASSETS/gitrepos/shell-toolz/toolz_network.sh

# get passwords for OpenStack environment 
source $ASSETS/credentials

# prepare OpenStack repo and configure NTP
source $ASSETS/fundamental/fundamental.sh

# nova rollout: compute
source $ASSETS/nova-compute/nova-compute.sh

# migrate into neutron networking
source $ASSETS/neutron/neutron-l2.sh

# ovn-neutron append neutron-part to all nova-relevant nodes
source $ASSETS/ovn/all.nova.sh

# cinder, prepare physical devices and rollout: volume
# IMPORTANT! define physical devices in a mapfile called [hostname].map in ./assets/cinder/mappings
# define only devicenames without path
source $ASSETS/cinder/cinder-volume.sh

# swift volume rollout: account, container, object
STOR_DEV='/dev/vdf'
source $ASSETS/swift/swift-storage.sh

# maila rollout: share
source $ASSETS/manila/manila-storagenode.sh