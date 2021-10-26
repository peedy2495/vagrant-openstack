apt -y install nova-compute nova-compute-kvm qemu-system-data

for var in CTRL_HOST_IP SERVPWD ADMPWD; do
  ReplVar $var /tmp/assets/nova-compute/nova.conf
done
install -v -m 640 -g nova -t /etc/nova /tmp/assets/nova-compute/nova.conf

systemctl restart nova-compute