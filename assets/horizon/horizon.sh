apt -y install openstack-dashboard 

install -v -m 640 -g horizon -t /etc/openstack-dashboard /tmp/assets/horizon/local_settings.py
sed -i "s/CTRL_HOST_IP/$CTRL_HOST_IP/g" /etc/openstack-dashboard/local_settings.py

install -v -m 640 -g nova -t /etc/nova /tmp/assets/horizon/policy.json

systemctl restart nova-api