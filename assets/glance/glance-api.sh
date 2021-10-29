#!/bin/bash

# wait for nova api
WaitForHost $CTRL_HOST_IP 8774 tcp 'nova-api@'

mkfs.ext4 $IMGDEV
mount -t ext4 $IMGDEV /var/lib/glance/images
echo "/dev/$IMGDEV    /var/lib/glance/images          ext4      rw,relatime,nodev,nosuid,noexec              0       1" >>/etc/fstab

apt -y install glance 

for var in CTRL_HOST_IP ADMPWD SERVPWD; do
    ReplVar $var /tmp/assets/glance/glance-api.conf
done
install -v -b -m 640 -g glance -t /etc/glance /tmp/assets/glance/glance-api.conf

su -s /bin/bash glance -c "glance-manage db_sync" 
systemctl restart glance-api
systemctl enable glance-api