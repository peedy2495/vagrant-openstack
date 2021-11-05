#!/bin/bash

# wait for nova api
WaitForHost $CTRL_HOST_IP 5000 tcp 'keystone@'

apt -y install heat-api heat-api-cfn heat-engine python3-heatclient python3-vitrageclient python3-zunclient 

for var in CTRL_HOST_IP HOST_IP ADMPWD SERVPWD; do
    ReplVar $var $ASSETS/heat/heat.conf
done
install -v -b -m 640 -g heat -t /etc/heat              $ASSETS/heat/heat.conf

su -s /bin/bash heat -c "heat-manage db_sync"
systemctl restart heat-api heat-api-cfn heat-engine