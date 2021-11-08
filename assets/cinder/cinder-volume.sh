#!/bin/bash

# Exists a pysical volume mapping for this host?
if [ ! -f "$ASSETS/cinder/mappings/$HOSTNAME.map" ]; then
    >&2 echo "Volume mapping $ASSETS/cinder/mappings/$HOSTNAME.map not found!"
    exit 1
fi

apt install -y lvm2

# create lvm pvs for existing devices in mapfile
for dev in $(cat $ASSETS/cinder/mappings/$HOSTNAME.map); do
    if [ -e "/dev/$dev" ]; then
        pvcreate /dev/$dev
        pvs+="/dev/$dev "
    fi
done

# Ooops?! check your mapfile!
if [ -z "$pvs" ]; then
    >&2 echo "no physical devices defined in $ASSETS/cinder/mappings/$HOSTNAME.map found!"
    exit 1
fi

# create default volumegroup for cinder with prepared pvs
vgcreate cinder-volumes $pvs

apt -y install cinder-volume python3-mysqldb

# wait for cinder api
WaitForHost $CTRL_HOST_IP 8776 tcp 'cinder-api@'

for var in CTRL_HOST_IP HOST_IP ADMPWD SERVPWD GLANCE_IP; do
    ReplVar $var $ASSETS/cinder/cinder.conf
done
install -v -b -m 640 -g cinder -t /etc/cinder              $ASSETS/cinder/cinder.conf
systemctl restart cinder-volume
systemctl enable cinder-volume