#!/bin/bash

HOST_IP="$1"
CTRL_HOST_IP="$2"
INFRA_NTP="$3"

main() {
  source /tmp/assets/credentials
  source /tmp/assets/fundamental/fundamental.sh
  source /tmp/assets/cinder/cinder-node.sh
}

main