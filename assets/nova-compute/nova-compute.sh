# wait for nova api
WaitForHost $CTRL_HOST_IP 8774 tcp 'nova-api@'

apt -y install nova-compute nova-compute-kvm qemu-system-data

for var in CTRL_HOST_IP HOST_IP SERVPWD ADMPWD GLANCE_IP; do
  ReplVar $var /tmp/assets/nova-compute/nova.conf
done
install -v -b -m 640 -g nova -t /etc/nova /tmp/assets/nova-compute/nova.conf

tee -a /etc/nova/nova.conf >/dev/null <<EOF  

[cinder]
os_region_name = RegionOne
EOF

systemctl restart nova-compute