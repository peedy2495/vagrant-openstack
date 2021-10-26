## install keystone
sed -i "s/ADMPWD/$ADMPWD/g" /tmp/assets/keystone/keystone.sql
mysql --user=root < /tmp/assets/keystone/keystone.sql

apt -y install keystone python3-openstackclient apache2 libapache2-mod-wsgi-py3 python3-oauth2client

ReplVar CTRL_HOST_IP /tmp/assets/keystone/keystone.conf
ReplVar ADMPWD /tmp/assets/keystone/keystone.conf
install -v -m 640 -o keystone -g keystone -t /etc/keystone /tmp/assets/keystone/keystone.conf
#sed -i "s/CTRL_HOST_IP/$CTRL_HOST_IP/g" /etc/keystone/keystone.conf
#sed -i "s/ADMPWD/$ADMPWD/g" /etc/keystone/keystone.conf

ReplVar CTRL_HOST_IP /tmp/assets/keystone/keystonerc
ReplVar ADMPWD /tmp/assets/keystone/keystonerc
install -v -m 600 -o root -g root -t /root /tmp/assets/keystone/keystonerc
#sed -i "s/CTRL_HOST_IP/$CTRL_HOST_IP/g" /root/keystonerc
#sed -i "s/ADMPWD/$ADMPWD/g" /root/keystonerc

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