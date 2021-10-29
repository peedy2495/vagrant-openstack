## deploying glance

openstack user create --domain default --project service --password $SERVPWD glance
openstack role add --project service --user glance admin 

openstack service create --name glance --description "OpenStack Image service" image
openstack endpoint create --region RegionOne image public http://$controller:9292
openstack endpoint create --region RegionOne image internal http://$controller:9292 
openstack endpoint create --region RegionOne image admin http://$controller:9292

# glance: add user and database

sed -i "s/ADMPWD/$ADMPWD/g" /tmp/assets/glance/glance.sql
mysql --user=root < /tmp/assets/glance/glance.sql 