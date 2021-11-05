## recommended basic services

apt install -y mariadb-server

# remove test databases and limit credentials
mysql --user=root < $ASSETS/base-services/db-prep.sql
# 2Do, when provision finished: ALTER USER 'root'@'localhost' IDENTIFIED BY '${ADMPWD}';

# install node0
apt -y install rabbitmq-server memcached python3-pymysql

# configure rabbitmq
rabbitmqctl add_user openstack ${ADMPWD}
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

# deploy configs preserving destinationfile attributes
install -v -b -m 640 -t /etc $ASSETS/base-services/memcached.conf
install -v -b -m 640 -t /etc/mysql/mariadb.conf.d $ASSETS/base-services/50-server.cnf

# make changes working
systemctl restart mariadb rabbitmq-server memcached