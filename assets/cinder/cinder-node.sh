#!/bin/bash

# Exists a pysical volume mapping for this host?
if [ ! -f "/tmp/assets/$HOSTNAME.map" ]; then
    >&2 echo "Volume mapping /tmp/assets/$HOSTNAME.map not found!"
    exit 1
fi

# create lvm pvs for existing devices in mapfile
for dev in $(cat /tmp/assets/$HOSTNAME.map); do
    if [ -f "/dev/$dev" ]; then
        pvcreate /dev/$dev
        pvs="$pvs /dev/$dev"
    fi
done

# Ooops?! check your mapfile!
if [ -z "$pvs" ]; then
    >&2 echo "no physical devices defined in /tmp/assets/$HOSTNAME.map found!"
    exit 1
fi

# create default volumegroup for cinder with prepared pvs
vgcreate cinder-volumes $pvs

apt -y install cinder-volume python3-mysqldb

for var in HOST_IP CTRL_HOST_IP ADMPWD SERVPWD GLANCE_IP; do
    ReplVar $var /tmp/assets/cinder/cinder.conf.org
done
install -v -m 640 -g cinder -t /etc/cinder              /tmp/assets/cinder/cinder.conf.org

systemctl restart cinder-volume
systemctl enable cinder-volume