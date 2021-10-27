apt -y install openstack-dashboard 

ReplVar CTRL_HOST_IP /tmp/assets/horizon/local_settings.py
install -v -b -m 640 -g horizon -t /etc/openstack-dashboard /tmp/assets/horizon/local_settings.py

install -v -b -m 640 -g nova -t /etc/nova /tmp/assets/horizon/policy.json

systemctl restart nova-api