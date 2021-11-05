#!/bin/bash

# get initial asset-path fom hypervisor
ASSETS=$1

#load static variables 
source $ASSETS/global.rb > >(tee -a /var/log/deployment/base.log) 2> >(tee -a /var/log/deployment/base.err >&2)
#load aggregated variables
source $ASSETS/global.sh > >(tee -a /var/log/deployment/base.log) 2> >(tee -a /var/log/deployment/base.err >&2)

HOST_IP=$(hostname -I | cut -d: -f2 | awk '{print $2}')

# include toolboxes(functions)
source $ASSETS/gitrepos/shell-toolz/toolz_configs.sh > >(tee -a /var/log/deployment/toolz.log) 2> >(tee -a /var/log/deployment/toolz.err >&2)
source $ASSETS/gitrepos/shell-toolz/toolz_network.sh > >(tee -a /var/log/deployment/toolz.log) 2> >(tee -a /var/log/deployment/toolz.err >&2)

# get passwords for OpenStack environment 
source $ASSETS/credentials > >(tee -a /var/log/deployment/base.log) 2> >(tee -a /var/log/deployment/base.err >&2)

# prepare OpenStack repo and configure NTP
source $ASSETS/fundamental/fundamental.sh > >(tee -a /var/log/deployment/base.log) 2> >(tee -a /var/log/deployment/base.err >&2)

# nova rollout: compute
source $ASSETS/nova-compute/nova-compute.sh > >(tee -a /var/log/deployment/nova-compute.log) 2> >(tee -a /var/log/deployment/nova-compute.err >&2)

# migrate into neutron networking
#source $ASSETS/neutron/neutron-l2.sh

# ovn-neutron append neutron-part to all nova-relevant nodes
source $ASSETS/ovn/all.nova.sh > >(tee -a /var/log/deployment/ovn.log) 2> >(tee -a /var/log/deployment/ovn.err >&2)

# ovn compute node rollout
source $ASSETS/ovn/compute.ovn.sh > >(tee -a /var/log/deployment/ovn.log) 2> >(tee -a /var/log/deployment/ovn.err >&2)

# cinder, prepare physical devices and rollout: volume
# IMPORTANT! define physical devices in a mapfile called [hostname].map in ./assets/cinder/mappings
# define only devicenames without path
source $ASSETS/cinder/cinder-volume.sh > >(tee -a /var/log/deployment/cinder-volume.log) 2> >(tee -a /var/log/deployment/cinder-volume.err >&2)

# swift volume rollout: account, container, object
STOR_DEV='/dev/vdf'
source $ASSETS/swift/swift-storage.sh > >(tee -a /var/log/deployment/swift-storage.log) 2> >(tee -a /var/log/deployment/swift-storage.err >&2)

# maila rollout: share
source $ASSETS/manila/manila-storagenode.sh > >(tee -a /var/log/deployment/manila-storage.log) 2> >(tee -a /var/log/deployment/manila-storage.err >&2)