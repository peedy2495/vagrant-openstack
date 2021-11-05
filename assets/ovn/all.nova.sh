#!/bin/bash

# append neutron-part to all nova-relevant nodes
if [ -f /etc/nova/nova.conf ];then
    if ! grep -Fxq "[neutron]" /etc/nova/nova.conf; then
        for var in CTRL_HOST_IP SERVPWD; do
            ReplVar $var $ASSETS/ovn/all.part.nova.conf
        done
        cat $ASSETS/ovn/all.part.nova.conf >>/etc/nova/nova.conf
        # restart nova-api, if it's present on this node
        if systemctl --all --type service | grep -q "nova-api";then
            systemctl restart nova-api
        fi
    fi
fi