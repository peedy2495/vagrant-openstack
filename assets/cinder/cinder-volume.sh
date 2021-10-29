#!/bin/bash

# Exists a pysical volume mapping for this host?
if [ ! -f "/tmp/assets/cinder/mappings/$HOSTNAME.map" ]; then
    >&2 echo "Volume mapping /tmp/assets/cinder/mappings/$HOSTNAME.map not found!"
    exit 1
fi

apt install -y lvm2

# create lvm pvs for existing devices in mapfile
for dev in $(cat /tmp/assets/cinder/mappings/$HOSTNAME.map); do
    if [ -e "/dev/$dev" ]; then
        pvcreate /dev/$dev
        pvs+="/dev/$dev "
    fi
done

# Ooops?! check your mapfile!
if [ -z "$pvs" ]; then
    >&2 echo "no physical devices defined in /tmp/assets/cinder/mappings/$HOSTNAME.map found!"
    exit 1
fi

# create default volumegroup for cinder with prepared pvs
vgcreate cinder-volumes $pvs

# wait for cinder api
WaitForHost $CTRL_HOST_IP 8776 tcp 'cinder-api@'

apt -y install cinder-volume python3-mysqldb

for var in CTRL_HOST_IP HOST_IP ADMPWD SERVPWD GLANCE_IP; do
    ReplVar $var /tmp/assets/cinder/cinder.conf
done
install -v -b -m 640 -g cinder -t /etc/cinder              /tmp/assets/cinder/cinder.conf
systemctl restart cinder-volume
systemctl enable cinder-volume