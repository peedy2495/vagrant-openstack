#! /bin/bash

apt -y install swift swift-account swift-container swift-object xfsprogs 

# wait for swift proxy
WaitForHost $SWIFT_PROXY 8080 tcp 'swift-proxy@'

mkfs.xfs -i size=1024 -s size=4096 $STOR_DEV
mkdir -p /srv/node/device
mount -o noatime,nodiratime $STOR_DEV /srv/node/device
chown -R swift /srv/node

echo -e "$STOR_DEV               /srv/node/device       xfs     noatime,nodiratime 0 0\n" >>/etc/fstab

#Original doesn't make any sense
#scp /etc/swift/*.gz $SWIFT_PROXY:/etc/swift/
scp -o StrictHostKeyChecking=no $SWIFT_PROXY:/etc/swift/*.gz /etc/swift/

chown swift /etc/swift/*.gz

install -v -b -m 640 -g swift -t /etc/swift     $ASSETS/swift/swift.conf

KeySet bind_ip '0.0.0.0' /etc/swift/object-server.conf
KeySet bind_port '6000' /etc/swift/object-server.conf

KeySet bind_ip '0.0.0.0' /etc/swift/container-server.conf
KeySet bind_port '6001' /etc/swift/container-server.conf

KeySet bind_ip '0.0.0.0' /etc/swift/account-server.conf
KeySet bind_port '6002' /etc/swift/account-server.conf

ReplVar HOST_IP $ASSETS/swift/rsyncd.conf
install -v -b -m 644 -g swift -t /etc           $ASSETS/swift/rsyncd.conf

KeySet RSYNC_ENABLE 'true' /etc/default/rsync

systemctl restart rsync \
    swift-account-auditor \
    swift-account-replicator \
    swift-account \
    swift-container-auditor \
    swift-container-replicator \
    swift-container-updater \
    swift-container \
    swift-object-auditor \
    swift-object-replicator \
    swift-object-updater \
    swift-object

systemctl enable rsync \
    swift-account-auditor \
    swift-account-replicator \
    swift-account \
    swift-container-auditor \
    swift-container-replicator \
    swift-container-updater \
    swift-container \
    swift-object-auditor \
    swift-object-replicator \
    swift-object-updater \
    swift-object
