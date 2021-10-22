#!/bin/bash

REPO_IP="$1"
REPO_PORT="$2"

# Use local Nexus apt-proxy
cp /tmp/assets/base/sources.list /etc/apt/sources.list
sed -i "s/REPO_IP/$REPO_IP/g" /etc/apt/sources.list
sed -i "s/REPO_PORT/$REPO_PORT/g" /etc/apt/sources.list

# Push system into latest
apt update
apt install -y avahi-daemon libnss-mdns
apt -y upgrade
apt -y dist-upgrade