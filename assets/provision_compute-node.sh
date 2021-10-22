#!/bin/bash

CTRL_HOST_IP="$1"
INFRA_NTP="$2"

main() {
  source /tmp/assets/credentials
  source /tmp/assets/fundamental/fundamental.sh
  source /tmp/assets/nova-compute/nova-compute.sh
}

main