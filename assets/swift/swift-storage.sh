#! /bin/bash

apt -y install swift swift-account swift-container swift-object xfsprogs 

# wait for swift proxy
WaitForHost $CTRL_HOST_IP 8080 'swift-proxy@'

mkfs.xfs -i size=1024 -s size=4096 $STOR_DEV
mkdir -p /srv/node/device
mount -o noatime,nodiratime $STOR_DEV /srv/node/device
chown -R swift. /srv/node

echo -e "\n$STOR_DEV               /srv/node/device       xfs     noatime,nodiratime 0 0" >>/etc/fstab

scp /etc/swift/*.gz $SWIFT_PROXY:/etc/swift/
chown swift. /etc/swift/*.gz

### uncompleted! ... modify/deploy relevant configs