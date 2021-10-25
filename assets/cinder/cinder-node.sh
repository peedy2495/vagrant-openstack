#!/bin/bash
source /tmp/assets/cfgtools.sh

apt -y install cinder-volume python3-mysqldb

ReplVar HOST_IP /tmp/assets/cinder/cinder.conf.org
ReplVar CTRL_HOST_IP /tmp/assets/cinder/cinder.conf.org
ReplVar ADMPWD /tmp/assets/cinder/cinder.conf.org
ReplVar SERVPWD /tmp/assets/cinder/cinder.conf.org
install -v -m 640 -g cinder -t /etc/cinder              /tmp/assets/cinder/cinder.conf.org

systemctl restart cinder-volume
systemctl enable cinder-volume