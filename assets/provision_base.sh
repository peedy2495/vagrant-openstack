#!/bin/bash

# get initial asset-path fom hypervisor
ASSETS=$1

# load static variables 
source "$ASSETS/global.rb"
# load aggregated variables
source "$ASSETS/global.sh"

# include toolbox for config manipulations
source $ASSETS/gitrepos/shell-toolz/toolz_configs.sh

# Use local Nexus apt-proxy
ReplVar REPO_IP $ASSETS/base/sources.list
ReplVar REPO_PORT $ASSETS/base/sources.list
cp $ASSETS/base/sources.list /etc/apt/sources.list

# Push system into latest
apt update
apt install -y avahi-daemon libnss-mdns
apt -y upgrade
apt -y dist-upgrade

# passwordless root access for guests vice versa
mkdir /root/.ssh
cp $ASSETS/base/id_rsa* /root/.ssh/
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
KeyEnable PubkeyAuthentication /etc/ssh/sshd_config
systemctl restart sshd