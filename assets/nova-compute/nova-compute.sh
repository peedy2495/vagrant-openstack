# wait for nova api
apt -y install qemu-kvm libvirt-daemon-system libvirt-daemon virtinst bridge-utils libosinfo-bin libguestfs-tools virt-top 

WaitForHost $CTRL_HOST_IP 8774 tcp 'nova-api@'

apt -y install nova-compute nova-compute-kvm qemu-system-data

for var in CTRL_HOST_IP HOST_IP SERVPWD ADMPWD GLANCE_IP; do
  ReplVar $var $ASSETS/nova-compute/nova.conf
done
install -v -b -m 640 -g nova -t /etc/nova $ASSETS/nova-compute/nova.conf

tee -a /etc/nova/nova.conf >/dev/null <<EOF  

[cinder]
os_region_name = RegionOne
EOF

systemctl restart nova-compute