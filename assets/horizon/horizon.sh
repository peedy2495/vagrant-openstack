apt -y install openstack-dashboard 

ReplVar CTRL_HOST_IP $ASSETS/horizon/local_settings.py
install -v -b -m 640 -g horizon -t /etc/openstack-dashboard $ASSETS/horizon/local_settings.py

install -v -b -m 640 -g nova -t /etc/nova $ASSETS/horizon/policy.json

systemctl restart nova-api