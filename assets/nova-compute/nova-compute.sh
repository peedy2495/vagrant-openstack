apt -y install nova-compute nova-compute-kvm qemu-system-data

install -v -m 640 -g nova -t /etc/nova /tmp/assets/nova-compute/nova.conf
sed -i "s/CTRL_HOST_IP/$CTRL_HOST_IP/g" /etc/nova/nova.conf
sed -i "s/SERVPWD/$SERVPWD/g" /etc/nova/nova.conf
sed -i "s/ADMPWD/$ADMPWD/g" /etc/nova/nova.conf

systemctl restart nova-compute