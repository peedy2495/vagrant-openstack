#!/bin/bash

## This host will be mainly prepared as control-node

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

# basics rollout: database, rabbitmq and memcached
source /tmp/assets/base-services/base-services.sh

# keystone rollout
source /tmp/assets/keystone/keystone.sh

# glance prepare service
# for development or productive environments, it's recommended to save images in a separate partition.
# take a look for filesystem_store_datadir in glance.api.conf
source /tmp/assets/glance/glance.sh

# glance rollout: api
IMGDEV='/dev/vdj'
source /tmp/assets/glance/glance-service.sh

# nova rollout: api, conductor, scheduler, novncproxy, compute, compute-kvm
source /tmp/assets/nova/nova.sh

# neutron rollout: server, l2, l3, linuxbridge, dhcp, metadata 
NETDEV='eth2'
source /tmp/assets/neutron/neutron.sh

# horizon rollout: dashboard
source /tmp/assets/horizon/horizon.sh

# cinder rollout: api, scheduler
source /tmp/assets/cinder/cinder.sh

# heat prepare service
source /tmp/assets/heat/heat-prep.sh

# heat rollout: api engine
# separated from prep to be able to choose another host
source /tmp/assets/heat/heat.sh

# barbican rollout: api
source /tmp/assets/barbican/barbican.sh

# swift prepare service
source /tmp/assets/swift/swift-prep.sh

# swift volume rollout: account, container, object
STOR_DEV='/dev/vdf'
source /tmp/assets/swift/swift-storage.sh