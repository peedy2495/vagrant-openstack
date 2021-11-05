## install keystone
ReplVar ADMPWD $ASSETS/keystone/keystone.sql
mysql --user=root < $ASSETS/keystone/keystone.sql

apt -y install keystone python3-openstackclient apache2 libapache2-mod-wsgi-py3 python3-oauth2client

ReplVar CTRL_HOST_IP $ASSETS/keystone/keystone.conf
ReplVar ADMPWD $ASSETS/keystone/keystone.conf
install -v -b -m 640 -o keystone -g keystone -t /etc/keystone $ASSETS/keystone/keystone.conf

ReplVar CTRL_HOST_IP $ASSETS/keystone/keystonerc
ReplVar ADMPWD $ASSETS/keystone/keystonerc
install -v -b -m 600 -o root -g root -t /root $ASSETS/keystone/keystonerc

echo "source ~/keystonerc " >> /root/.bashrc
source /root/keystonerc 

su -s /bin/bash keystone -c "keystone-manage db_sync"
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

export controller=$CTRL_HOST_IP

keystone-manage bootstrap --bootstrap-password ${ADMPWD} \
--bootstrap-admin-url http://$controller:5000/v3/ \
--bootstrap-internal-url http://$controller:5000/v3/ \
--bootstrap-public-url http://$controller:5000/v3/ \
--bootstrap-region-id RegionOne

openstack project create --domain default --description "Service Project" service 