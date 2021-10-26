#!/bin/bash

HOST_IP="$1"
CTRL_HOST_IP="$1"
INFRA_GW="$2"
INFRA_MASK="$3"
INFRA_DNS="$4"
INFRA_DHCP_START="$5"
INFRA_DHCP_END="$6"
INFRA_NTP="$7"
GLANCE_IP="$8"

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

# glance rollout: server
# for development or productive environments, it's recommended to save images in a separate partition.
# take a look for filesystem_store_datadir in glance.api.conf
source /tmp/assets/glance/glance.sh

# nova rollout: api, conductor, scheduler, novncproxy, compute, compute-kvm
source /tmp/assets/nova/nova.sh

# neutron rollout: server, l2, l3, linuxbridge, dhcp, metadata 
NETDEV='eth2'
source /tmp/assets/neutron/neutron.sh

# horizon rollout: dashboard
source /tmp/assets/horizon/horizon.sh

# cinder rollout: api, scheduler
source /tmp/assets/cinder/cinder.sh