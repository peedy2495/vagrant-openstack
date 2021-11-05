#!/bin/bash

## This host will be mainly prepared as control-node

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

# basics rollout: database, rabbitmq and memcached
source $ASSETS/base-services/base-services.sh

# keystone rollout
source $ASSETS/keystone/keystone.sh

# glance prepare service
# for development or productive environments, it's recommended to save images in a separate partition.
# take a look for filesystem_store_datadir in glance.api.conf
source $ASSETS/glance/glance.sh

# glance rollout: api
IMGDEV='/dev/vdj'
source $ASSETS/glance/glance-service.sh

# nova rollout: api, conductor, scheduler, novncproxy, compute, compute-kvm
source $ASSETS/nova/nova.sh

# neutron rollout: server, l2, l3, linuxbridge, dhcp, metadata 
#NETDEV='eth2'
#source $ASSETS/neutron/neutron.sh

# ovn-neutron append neutron-part to all nova-relevant nodes
source $ASSETS/ovn/all.nova.sh

# ovn network node rollout: northd
source $ASSETS/ovn/northd.ovn.sh 

# horizon rollout: dashboard
source $ASSETS/horizon/horizon.sh

# cinder rollout: api, scheduler
source $ASSETS/cinder/cinder.sh

# heat prepare service
source $ASSETS/heat/heat-prep.sh

# heat rollout: api engine
# separated from prep to be able to choose another host
source $ASSETS/heat/heat.sh

# barbican rollout: api
source $ASSETS/barbican/barbican.sh

# swift prepare service
source $ASSETS/swift/swift-prep.sh

# swift volume rollout: account, container, object
STOR_DEV='/dev/vdf'
source $ASSETS/swift/swift-storage.sh

# manila rollout: api, scheduler, client
source $ASSETS/manila/manila.sh

# maila rollout: share
source $ASSETS/manila/manila-storagenode.sh

# designate prepare service
source $ASSETS/designate/designate-prep.sh

# designate rollout: api central worker producer mdns
source $ASSETS/designate/designate.sh

# octavia prepare service
source $ASSETS/octavia/octavia-prep.sh

# octavia rollout: api central worker producer mdns
source $ASSETS/octavia/octavia.sh