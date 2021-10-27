# wait for nova api
WaitForHost $CTRL_HOST_IP 8774

apt -y install nova-compute nova-compute-kvm qemu-system-data

for var in CTRL_HOST_IP HOST_IP SERVPWD ADMPWD; do
  ReplVar $var /tmp/assets/nova-compute/nova.conf
done
install -v -b -m 640 -g nova -t /etc/nova /tmp/assets/nova-compute/nova.conf

systemctl restart nova-compute