#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt -y install manila-share python3-pymysql python3-mysqldb 

# wait for manila api
WaitForHost $SHARE_IP 8786 tcp 'manila-api@'

for var in CTRL_HOST_IP HOST_IP ADMPWD SERVPWD; do
    ReplVar $var $ASSETS/manila/manila.conf
done
install -v -b -m 640 -g manila -t /etc/manila              $ASSETS/manila/manila.conf

install -v -b -m 640 -g manila -t /etc/manila              /usr/lib/python3/dist-packages/manila/tests/policy.yaml

systemctl restart manila-share
systemctl enable manila-share