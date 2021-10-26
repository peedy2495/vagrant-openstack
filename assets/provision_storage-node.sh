#!/bin/bash

HOST_IP="$1"
CTRL_HOST_IP="$2"
INFRA_NTP="$3"
GLANCE_IP="$4"

# include toolboxes(functions)
source /tmp/assets/tbx_configs.sh
source /tmp/assets/tbx_network.sh

# get passwords for OpenStack environment 
source /tmp/assets/credentials

# prepare OpenStack repo and configure NTP
source /tmp/assets/fundamental/fundamental.sh

# migrate into neutron networking
source /tmp/assets/neutron/neutron-l2.sh

# cinder, prepare physical devices and rollout: volume
# IMPORTANT! define physical devices in a mapfile called [hostname].map in ./assets/cinder/mappings
# define only devicenames without path
source /tmp/assets/cinder/cinder-node.sh