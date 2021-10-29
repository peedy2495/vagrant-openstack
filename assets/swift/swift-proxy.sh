#!/bin/bash

apt -y install swift swift-proxy python3-swiftclient python3-keystonemiddleware python3-memcache 

# wait for nova api
WaitForHost $CTRL_HOST_IP 8774 'nova-api@'

for var in CTRL_HOST_IP SERVPWD; do
    ReplVar $var /tmp/assets/swift/proxy-server.conf
done
install -v -b -m 640 -g swift -t /etc/swift              /tmp/assets/swift/proxy-server.conf

install -v -b -m 640 -g swift -t /etc/swift              /tmp/assets/swift/swift.conf

swift-ring-builder /etc/swift/account.builder create 12 3 1
swift-ring-builder /etc/swift/container.builder create 12 3 1 
swift-ring-builder /etc/swift/object.builder create 12 3 1 

swift-ring-builder /etc/swift/account.builder add r0z0-OBJ_NODE1:6002/device 100
swift-ring-builder /etc/swift/container.builder add r0z0-OBJ_NODE1:6001/device 100 
swift-ring-builder /etc/swift/object.builder add r0z0-OBJ_NODE1:6000/device 100
swift-ring-builder /etc/swift/account.builder add r1z1-OBJ_NODE2:6002/device 100
swift-ring-builder /etc/swift/container.builder add r1z1-OBJ_NODE2:6001/device 100 
swift-ring-builder /etc/swift/object.builder add r1z1-OBJ_NODE2:6000/device 100
swift-ring-builder /etc/swift/account.builder add r2z2-OBJ_NODE3:6002/device 100
swift-ring-builder /etc/swift/container.builder add r2z2-OBJ_NODE3:6001/device 100
swift-ring-builder /etc/swift/object.builder add r2z2-OBJ_NODE3:6000/device 100 

swift-ring-builder /etc/swift/account.builder rebalance
swift-ring-builder /etc/swift/container.builder rebalance
swift-ring-builder /etc/swift/object.builder rebalance 

chown swift. /etc/swift/*.gz 
systemctl restart swift-proxy 