create database cinder;
grant all privileges on cinder.* to cinder@'localhost' identified by 'ADMPWD';
grant all privileges on cinder.* to cinder@'%' identified by 'ADMPWD';
flush privileges;