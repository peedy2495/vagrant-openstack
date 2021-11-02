#!/bin/bash

# load static variables 
source /tmp/assets/global.rb
# load aggregated variables
source /tmp/assets/global.sh

# passwordless root access for guests vice versa
cp /tmp/assets/base/id_rsa* /root
KeyEnable PubkeyAuthentication /etc/ssh/sshd_config

# Use local Nexus apt-proxy
cp /tmp/assets/base/sources.list /etc/apt/sources.list
sed -i "s/REPO_IP/$REPO_IP/g" /etc/apt/sources.list
sed -i "s/REPO_PORT/$REPO_PORT/g" /etc/apt/sources.list

# Push system into latest
apt update
apt install -y avahi-daemon libnss-mdns
apt -y upgrade
apt -y dist-upgrade