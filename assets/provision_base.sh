#!/bin/bash

# get initial asset-path fom hypervisor
ASSETS=$1

mkdir /var/log/deployment

# load static variables 
source "$ASSETS/global.rb" > >(tee -a /var/log/deployment/os-basic.log) 2> >(tee -a /var/log/deployment/os-basic.err >&2)
# load aggregated variables
source "$ASSETS/global.sh" > >(tee -a /var/log/deployment/os-basic.log) 2> >(tee -a /var/log/deployment/os-basic.err >&2)

# include toolbox for config manipulations
source $ASSETS/gitrepos/shell-toolz/toolz_configs.sh > >(tee -a /var/log/deployment/toolz.log) 2> >(tee -a /var/log/deployment/toolz.err >&2)

# Use local Nexus apt-proxy
ReplVar REPO_IP $ASSETS/base/sources.list
ReplVar REPO_PORT $ASSETS/base/sources.list
cp $ASSETS/base/sources.list /etc/apt/sources.list

# Push system into latest
apt update  > >(tee -a /var/log/deployment/os-basic.log) 2> >(tee -a /var/log/deployment/os-basic.err >&2)
apt install -y avahi-daemon libnss-mdns   > >(tee -a /var/log/deployment/os-basic.log) 2> >(tee -a /var/log/deployment/os-basic.err >&2)
apt -y upgrade  > >(tee -a /var/log/deployment/os-basic.log) 2> >(tee -a /var/log/deployment/os-basic.err >&2)
apt -y dist-upgrade  > >(tee -a /var/log/deployment/os-basic.log) 2> >(tee -a /var/log/deployment/os-basic.err >&2)

# passwordless root access for guests vice versa
mkdir /root/.ssh
cp $ASSETS/base/id_rsa* /root/.ssh/
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
KeyEnable PubkeyAuthentication /etc/ssh/sshd_config
systemctl restart sshd