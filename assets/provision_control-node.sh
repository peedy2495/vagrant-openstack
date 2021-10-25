#!/bin/bash

CTRL_HOST_IP="$1"
INFRA_GW="$2"
INFRA_MASK="$3"
INFRA_DNS="$4"
INFRA_DHCP_START="$5"
INFRA_DHCP_END="$6"
INFRA_NTP="$7"

main() {

  source /tmp/assets/credentials

  source /tmp/assets/fundamental/fundamental.sh
  
  source /tmp/assets/base-services/base-services.sh

  source /tmp/assets/keystone/keystone.sh
  
  source /tmp/assets/glance/glance.sh
  
  source /tmp/assets/nova/nova.sh
  
  NETDEV='eth2'
  source /tmp/assets/neutron/neutron.sh

  source /tmp/assets/horizon/horizon.sh
}

main