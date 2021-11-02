#!/bin/bash

apt -y install manila-share python3-pymysql python3-mysqldb 

for var in CTRL_HOST_IP HOST_IP ADMPWD SERVPWD; do
    ReplVar $var /tmp/assets/manila/manila.conf
done
install -v -b -m 640 -g manila -t /etc/manila              /tmp/assets/manila/manila.conf

install -v -b -m 640 -g manila -t /etc/manila              /usr/lib/python3/dist-packages/manila/tests/policy.yaml

systemctl restart manila-share
systemctl enable manila-share