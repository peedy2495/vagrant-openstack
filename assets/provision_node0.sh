#!/bin/bash

## This host will be mainly prepared as control-node

# get initial asset-path fom hypervisor
ASSETS=$1

mkdir /var/log/deployment

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

# basics rollout: database, rabbitmq and memcached
source $ASSETS/base-services/base-services.sh > >(tee -a /var/log/deployment/base-services.log) 2> >(tee -a /var/log/deployment/base-services.err >&2)

# keystone rollout
source $ASSETS/keystone/keystone.sh > >(tee -a /var/log/deployment/keystone.log) 2> >(tee -a /var/log/deployment/keystone.err >&2)

# glance prepare service
# for development or productive environments, it's recommended to save images in a separate partition.
# take a look for filesystem_store_datadir in glance.api.conf
source $ASSETS/glance/glance.sh > >(tee -a /var/log/deployment/glance.log) 2> >(tee -a /var/log/deployment/glance.err >&2)

# glance rollout: api
IMGDEV='/dev/vdj'
source $ASSETS/glance/glance-api.sh > >(tee -a /var/log/deployment/glance.log) 2> >(tee -a /var/log/deployment/glance.err >&2)

# nova rollout: api, conductor, scheduler, novncproxy, compute, compute-kvm
source $ASSETS/nova/nova.sh > >(tee -a /var/log/deployment/nova.log) 2> >(tee -a /var/log/deployment/nova.err >&2)

# neutron rollout: server, l2, l3, linuxbridge, dhcp, metadata 
#NETDEV='eth2'
#source $ASSETS/neutron/neutron.sh

# ovn-neutron append neutron-part to all nova-relevant nodes
source $ASSETS/ovn/all.nova.sh > >(tee -a /var/log/deployment/ovn.log) 2> >(tee -a /var/log/deployment/ovn.err >&2)

# ovn network node rollout: northd
source $ASSETS/ovn/northd.ovn.sh > >(tee -a /var/log/deployment/ovn.log) 2> >(tee -a /var/log/deployment/ovn.err >&2)

# horizon rollout: dashboard
source $ASSETS/horizon/horizon.sh > >(tee -a /var/log/deployment/horizon.log) 2> >(tee -a /var/log/deployment/horizon.err >&2)

# cinder rollout: api, scheduler
source $ASSETS/cinder/cinder.sh > >(tee -a /var/log/deployment/cinder.log) 2> >(tee -a /var/log/deployment/cinder.err >&2)

# heat prepare service
source $ASSETS/heat/heat-prep.sh > >(tee -a /var/log/deployment/heat.log) 2> >(tee -a /var/log/deployment/heat.err >&2)

# heat rollout: api engine
# separated from prep to be able to choose another host
source $ASSETS/heat/heat.sh > >(tee -a /var/log/deployment/heat.log) 2> >(tee -a /var/log/deployment/heat.err >&2)

# barbican rollout: api
source $ASSETS/barbican/barbican.sh > >(tee -a /var/log/deployment/heat.log) 2> >(tee -a /var/log/deployment/heat.err >&2)

# swift prepare service
source $ASSETS/swift/swift-prep.sh > >(tee -a /var/log/deployment/swift.log) 2> >(tee -a /var/log/deployment/swift.err >&2)

# swift volume rollout: account, container, object
STOR_DEV='/dev/vdf'
source $ASSETS/swift/swift-storage.sh > >(tee -a /var/log/deployment/swift.log) 2> >(tee -a /var/log/deployment/swift.err >&2)

# manila rollout: api, scheduler, client
source $ASSETS/manila/manila.sh > >(tee -a /var/log/deployment/manila.log) 2> >(tee -a /var/log/deployment/manila.err >&2)

# maila rollout: share
source $ASSETS/manila/manila-storagenode.sh > >(tee -a /var/log/deployment/manila-storage.log) 2> >(tee -a /var/log/deployment/manila-storage.err >&2)

# designate prepare service
source $ASSETS/designate/designate-prep.sh > >(tee -a /var/log/deployment/designate.log) 2> >(tee -a /var/log/deployment/designate.err >&2)

# designate rollout: api central worker producer mdns
source $ASSETS/designate/designate.sh > >(tee -a /var/log/deployment/designate.log) 2> >(tee -a /var/log/deployment/designate.err >&2)

# octavia prepare service
source $ASSETS/octavia/octavia-prep.sh > >(tee -a /var/log/deployment/octavia.log) 2> >(tee -a /var/log/deployment/octavia.err >&2)

# octavia rollout: api central worker producer mdns
source $ASSETS/octavia/octavia.sh > >(tee -a /var/log/deployment/octavia.log) 2> >(tee -a /var/log/deployment/octavia.err >&2)