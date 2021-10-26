#!/bin/bash

HOST_IP="$1"
CTRL_HOST_IP="$2"
INFRA_NTP="$3"

# include toolboxes(functions)
source /tmp/assets/tbx_configs.sh
source /tmp/assets/tbx_network.sh

# get passwords for OpenStack environment 
source /tmp/assets/credentials

# prepare OpenStack repo and configure NTP
source /tmp/assets/fundamental/fundamental.sh

# nova rollout: compute
source /tmp/assets/nova-compute/nova-compute.sh
